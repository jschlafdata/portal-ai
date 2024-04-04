import base64
import hvac
import json
import os
import psycopg2
import requests
import sys
import yaml
from dotenv import load_dotenv
from psycopg2.errors import DuplicateDatabase
from psycopg2 import sql
from portal_ai.settings.logger import LoggerConfig
import subprocess
from portal_ai.settings.logger import LoggerConfig
from portal_ai.settings.get_environment import get_project_env

from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)

from portal_ai.templating.yaml.yaml_manager import (
    JinjaRender,
    YmlManager,
    TemplateRenderer
)

# Utility functions
def load_yaml_file(path):
    with open(path, 'r') as file:
        return yaml.safe_load(file)

def read_and_encode(filepath):
    with open(os.path.expanduser(filepath), 'rb') as file:
        return base64.b64encode(file.read()).decode('utf-8')

# Database operations
class DatabaseOperations:
    def __init__(self, database=None, **kwargs):
            self.kwargs = kwargs
            self.database = database
            self.logger = LoggerConfig.get_logger(__name__)
    
    def get_pg_conn(self):

        database = self.database if self.database is not None else 'postgres'
        connection = psycopg2.connect(
            user=self.kwargs.get('rds_user'),
            password=self.kwargs.get('rds_pass'),
            host=self.kwargs.get('rds_host'),
            port=5432,
            database=database
                )
        return connection

    def create_database(self, database=None):

        conn = self.get_pg_conn()
        conn.autocommit = True  # Ensure that commands are committed without needing a transaction
        database = database if database is not None else self.kwargs.get('rds_database')

        with conn.cursor() as cur:
            # Create the new database
            # Use the `sql` module to avoid SQL injection
            try:
                sql_command = f"""CREATE DATABASE {database};"""
                self.logger.info(sql_command)
                cur.execute(sql.SQL(sql_command))
            except DuplicateDatabase as e:
                self.logger.info('database already exists!')
        conn.close()
        return

class InitESOVault:
    def __init__(self, logger, **kwargs):
            self.logger = logger
            self.kwargs = kwargs
            

    def init_client(self):

        kwargs = self.kwargs
        
        self.client = hvac.Client(
            url=kwargs.get('vault_addr'),
            token=kwargs.get('vtkn')
        )

    def kubernetes_auth(self):
        self.init_client()
        auth_methods = self.client.sys.list_auth_methods()
        if not auth_methods.get('kubernetes/'):
            self.client.sys.enable_auth_method(
                method_type='kubernetes',
            )

        service_account_token = subprocess.getoutput("kubectl exec vault-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/token")
        kubernetes_host = subprocess.getoutput("kubectl get service kubernetes -o jsonpath='{.spec.clusterIP}'")
        kubernetes_ca_cert = subprocess.getoutput("kubectl exec vault-0 -- cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt")

        self.client.auth.kubernetes.configure(
            kubernetes_host=kubernetes_host,
            kubernetes_ca_cert=kubernetes_ca_cert,
            token_reviewer_jwt=service_account_token
        )
    
    def engine_match(self, engine):
        engine_exist = self.client.sys.list_mounted_secrets_engines().get(f"{engine}/")
        exists = False if not engine_exist else True
        return exists

    def mage_role(self, default_role='mageai'):

        policy_body = """
        path "mageai/data/data_engineering" { 
            capabilities = ["read"] 
        }
        """
        # Create the role

        if not self.engine_match(default_role):
            self.client.sys.enable_secrets_engine(
                backend_type='kv-v2',
                path=default_role,
            )

        try:
            # if not default_role in acl.get('data
            self.client.auth.kubernetes.create_role(
                    name=default_role,
                    bound_service_account_names=[default_role],
                    bound_service_account_namespaces=['default'],
                    ttl='24h',
                    policies=[default_role]
            )
        except:
            pass

        if not default_role in self.client.sys.list_policies().get('keys'):
            self.client.sys.create_or_update_policy(
                name=default_role,
                policy=policy_body,
            )
    
    def eso_role(self, default_role='eso'):

        policy_body = """
        path "eso/helm" { 
            capabilities = ["read"] 
        }
        """
        if not self.engine_match(default_role):
            self.client.sys.enable_secrets_engine(
                    backend_type='kv',
                    path=default_role,
            )

        self.client.sys.create_or_update_policy(
                name=default_role,
                policy=policy_body,
        )

        check_secret_command = "kubectl get secret vault-token"
        result = subprocess.run(check_secret_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        # If the secret does not exist, result.returncode will be non-zero
        if result.returncode != 0:
            token_response = self.client.auth.token.create(policies=[default_role], ttl='24h')
            token = token_response['auth']['client_token']
            command = f'kubectl create secret generic vault-token --from-literal=token="{token}"'
            store_token = subprocess.run(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            return
        else:
            return

    def write_to_vault(self):

        kwargs = self.kwargs
        client = hvac.Client(
            url=kwargs.get('vault_addr'),
            token=kwargs.get('vtkn')
        )
        
        create_response = client.secrets.kv.v1.create_or_update_secret(
              path='helm',
              secret=dict(pg_user=kwargs.get('rds_user'),
                          pg_host=kwargs.get('rds_host'),
                          pg_pass=kwargs.get('rds_pass'),
                          rds_database=kwargs.get('rds_database'),
                          mageconnurl=kwargs.get('mageconnurl'),
                          git_public_key=kwargs.get('git_public_key'),
                          git_private_key=kwargs.get('git_private_key')
                         ),
              mount_point='eso'
        )

        ## this returns a 204 reposnse code:
        client.secrets.kv.v2.configure(
                max_versions=10,
                mount_point='mageai',
            )
        
        create_response = client.secrets.kv.v2.create_or_update_secret(
              path='data_engineering',
              secret=dict(pg_user=kwargs.get('rds_user'),
                          pg_host=kwargs.get('rds_host'),
                          pg_pass=kwargs.get('rds_pass')
                         ),
              mount_point='mageai'
        )

        try:
            client.sys.enable_secrets_engine(
                backend_type='kv-v2',
                path='team',
            )
        except:
            pass
                ## this returns a 204 reposnse code;
        try:
            client.secrets.kv.v2.configure(
                    max_versions=10,
                    mount_point='team',
                )
        except Exception as e:
            pass
        
        create_response = client.secrets.kv.v2.create_or_update_secret(
              path='john',
              secret=dict(pg_user=kwargs.get('rds_user'),
                          pg_host=kwargs.get('rds_host'),
                          pg_pass=kwargs.get('rds_pass')
                         ),
              mount_point='team'
        )

        create_response = client.secrets.kv.v2.create_or_update_secret(
              path='kevin',
              secret=dict(pg_user=kwargs.get('rds_user'),
                          pg_host=kwargs.get('rds_host'),
                          pg_pass=kwargs.get('rds_pass')
                         ),
              mount_point='team'
        )
    

# Main operations
class BackendInitializer:
    def __init__(self, 
                 environment,
                 rbac_settings,
                 logger
                ):
        self.environment = environment
        self.logger = logger

        self.settings = rbac_settings
        rds_token_path = self.settings.get('rds_token_path')
        rds_token_path = os.path.expanduser(rds_token_path)
        load_dotenv(rds_token_path)

        with open(rds_token_path, 'r') as file:
            rds = file.read()
        self.vars = self.get_vars()

    def get_vars(self):
        vault_addr = self.settings.get('vault_addr')
        vault_key_path = os.path.expanduser(self.settings.get('vault_key_path'))

        with open(vault_key_path, 'r') as file:
            vtkn = json.load(file).get('root_token')
        
        git_public_key_path = os.path.expanduser(self.settings.get('git_public_key_path'))
        git_private_key_path = os.path.expanduser(self.settings.get('git_private_key_path'))
        rds_user = self.settings.get('rds_username')
        rds_host = self.settings.get('rds_instance_hostname').split(':')[0]
        rds_pass = os.getenv('DATABASE_PASSWORD')

        rds_database = 'mage_backend_db'
        git_public_key = read_and_encode(git_public_key_path)
        git_private_key = read_and_encode(git_private_key_path)

        mageconnurl = f"postgresql+psycopg2://{rds_user}:{rds_pass}@{rds_host}:5432/{rds_database}"

        return {
            'rds_host': rds_host,
            'rds_user': rds_user,
            'rds_pass': rds_pass,
            'rds_database': rds_database,
            'vault_addr': vault_addr,
            'git_public_key': git_public_key,
            'git_private_key': git_private_key,
            'vtkn': vtkn,
            'mageconnurl': mageconnurl
        }
    

    def initialize_backend(self):
        vault = InitESOVault(self.logger, **self.vars)
        vault.kubernetes_auth()
        vault.mage_role()
        vault.eso_role()
        vault.write_to_vault()

        db_ops = DatabaseOperations(**self.vars)
        db_ops.create_database()
        db_ops.create_database(database = 'metabase_backend')
        db_ops.create_database(database = 'portal_backend')


def main():
    environment = get_project_env()
    logger = LoggerConfig.get_logger(__name__)

    loader = ConfigurationLoader(ConfigReader)
    deploment_configs = loader.generated_config_loader('aws_plus_global_base')

    rbac_configs = TemplateRenderer(loader).render(deploment_configs, 'rbac_settings_base')
    logger.info("Rbac settings configurations gathered successfully.")

    BackendInitializer(environment, rbac_configs, logger).initialize_backend()
    output = {'status': '200', 'message': f'its a party in the backend.'}
    print(json.dumps(output))

if __name__ == "__main__":
    main()
