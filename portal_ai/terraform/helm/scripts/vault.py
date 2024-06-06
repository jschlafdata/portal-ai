import hvac 
import boto3
import random
import base64
from botocore.exceptions import ClientError
from kubernetes import client as k8s_client, config as k8s_config
import psycopg2
from psycopg2.errors import DuplicateDatabase
from psycopg2 import sql
import os
import json
import boto3
from botocore.exceptions import ClientError
import logging
import argparse


SECRETS = [
    'rds-password',
    'rds-endpoint',
    'rds-user',
    'rds-endpoint-port',
    'application-admin',
    'hf-token',
    'gh-token'
]

DATABASES = [
  'mageai',
  'metabase',
  'portalai',
  'grafana'
]

class LoggerConfig:
    configured = False
    @classmethod
    def configure_logger(cls):
        if not cls.configured:
            logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
            cls.configured = True
    @classmethod
    def get_logger(cls, name=__name__):
        cls.configure_logger()
        return logging.getLogger(name)

# Database operations
class DatabaseOperations:
    def __init__(self, project_name=None, database=None, **kwargs):
            self.kwargs = kwargs
            self.database = database
            self.project_name = project_name
            self.logger = LoggerConfig.get_logger(__name__)
    def get_pg_conn(self):
        database = self.database if self.database is not None else 'postgres'
        connection = psycopg2.connect(
            user=self.kwargs.get(f'{self.project_name}-rds-user'),
            password=self.kwargs.get(f'{self.project_name}-rds-password'),
            host=self.kwargs.get(f'{self.project_name}-rds-endpoint'),
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


class SecretsManager:
    def __init__(self, secret_names):
        self.secret_names = secret_names
        self.secrets_client = boto3.client('secretsmanager')
    def batch_get_secrets(self):
        """
        Retrieves secrets from AWS Secrets Manager in batch based on the list of secret names,
        assuming that the secret values are JSON strings that need to be parsed to access
        the actual secret values.
        :return: A dictionary where the keys are secret names and the values are the parsed secrets.
        """
        secrets = {}
        for name in self.secret_names:
            try:
                get_secret_value_response = self.secrets_client.get_secret_value(SecretId=name)
            except ClientError as e:
                print(f"Unable to retrieve secret {name}: {e}")
                secrets[name] = None
                continue
            # Secrets Manager decrypts the secret value using the associated KMS CMK
            # Depending on whether the secret is a string or binary, one of these fields will be populated
            if 'SecretString' in get_secret_value_response:
                secret_string = get_secret_value_response['SecretString']
                try:
                    # Attempt to parse the secret string as JSON
                    secret_data = json.loads(secret_string)
                    secrets[name] = secret_data['value']
                except json.JSONDecodeError:
                    # If the secret string is not JSON, store it directly
                    secrets[name] = secret_string
            else:
                # For binary secret, decoding is necessary
                binary_secret_data = base64.b64decode(get_secret_value_response['SecretBinary'])
                # Assuming the binary data is also JSON which might not be true, adjust accordingly
                try:
                    secret_data = json.loads(binary_secret_data.decode('utf-8'))
                    secrets[name] = secret_data['value']
                except json.JSONDecodeError:
                    secrets[name] = binary_secret_data
        return secrets


class VaultManager:
    VAULT_ADDR = 'http://vault.default.svc.cluster.local:8200'
    ESO_POLICY = """
    path "eso/*" {
        capabilities = ["read", "list"]
    }
    """

    def __init__(self, project_name, **kwargs):
        self.project_name = project_name
        self.client = None
        self.kwargs = kwargs

    @staticmethod
    def encode_base64(string):
        """Encodes a string to base64."""
        return base64.b64encode(string.encode('utf-8')).decode('utf-8')

    def get_hvac_client(self, token=None):
        """Returns an authenticated hvac.Client instance."""
        self.client = hvac.Client(url=self.VAULT_ADDR, token=token) if token else hvac.Client(url=self.VAULT_ADDR)
        return self.client

    def initialize_vault(self):
        """Initializes the Vault, returns root token and unseal keys."""
        if not self.client:
            self.get_hvac_client()
        if not self.client.sys.is_initialized():
            init_result = self.client.sys.initialize(secret_shares=5, secret_threshold=3)
            return init_result['root_token'], init_result['keys']
        raise Exception("Vault is already initialized.")

    @staticmethod
    def manage_aws_secret(secret_name, secret_value):
        """Creates or updates a secret in AWS Secrets Manager."""
        client = boto3.client('secretsmanager')
        try:
            client.create_secret(Name=secret_name, SecretString=secret_value)
            action = "created"
        except client.exceptions.ResourceExistsException:
            client.update_secret(SecretId=secret_name, SecretString=secret_value)
            action = "updated"
        except ClientError as error:
            print(f"Error handling secret {secret_name}: {error}")
        else:
            print(f"Secret {secret_name} {action} successfully.")

    def unseal_vault(self, root_token, unseal_keys):
        """Unseals the Vault with the given keys."""
        for key in unseal_keys:
            self.client.sys.submit_unseal_key(key=key)

    def store_in_aws_secrets_manager(self, root_token, unseal_keys):
        self.manage_aws_secret("vrtk", root_token)
        for idx, key in enumerate(unseal_keys):
            self.manage_aws_secret(f"usk_{idx}", self.encode_base64(key))

    def configure_vault_kubernetes_auth(self, token):
        """Configures Vault authentication with Kubernetes."""
        token_reviewer_jwt = self.read_file("/var/run/secrets/kubernetes.io/serviceaccount/token")
        kubernetes_ca_cert = self.read_file("/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
        kubernetes_host = os.getenv("KUBERNETES_SERVICE_HOST")
        self.get_hvac_client(token)
        if 'kubernetes/' not in self.client.sys.list_auth_methods():
            self.client.sys.enable_auth_method(method_type='kubernetes')
        self.client.auth.kubernetes.configure(kubernetes_host=kubernetes_host, kubernetes_ca_cert=kubernetes_ca_cert, token_reviewer_jwt=token_reviewer_jwt)

    @staticmethod
    def create_kubernetes_secret(secret):
        """Creates a Kubernetes secret with the given token."""
        k8s_config.load_incluster_config()
        api_instance = k8s_client.CoreV1Api()
        secret = k8s_client.V1Secret(metadata=k8s_client.V1ObjectMeta(name="vault-token"),
                                     data={"token": VaultManager.encode_base64(secret)}, type="Opaque")
        try:
            api_instance.create_namespaced_secret('default', secret)
        except k8s_client.ApiException as error:
            print(f"Exception when creating Kubernetes secret: {error}")

    @staticmethod
    def read_file(path):
        """Reads content from the given path."""
        with open(path, "r") as file:
            return file.read().strip()

    def enable_eso_engine(self, token):
        """Enables the ESO engine and returns a token."""
        self.get_hvac_client(token)
        self.client.sys.enable_secrets_engine(backend_type='kv', path="eso")
        self.client.sys.create_or_update_policy(name='eso', policy=self.ESO_POLICY)
        eso_token = self.client.auth.token.create(policies=["eso"])
        return eso_token['auth']['client_token']

    def eso_values(self, token):
        
        self.get_hvac_client(token)

        pg_user=self.kwargs.get(f'{self.project_name}-rds-user')
        pg_host=self.kwargs.get(f'{self.project_name}-rds-endpoint')
        pg_pass=self.kwargs.get(f'{self.project_name}-rds-password')
        hf_token=self.kwargs.get(f'{self.project_name}-hf-token')
        gh_token=self.kwargs.get(f'{self.project_name}-gh-token')
        app_admin=self.kwargs.get(f'{self.project_name}-application-admin')
        
        mageconnurl = f"postgresql+psycopg2://{pg_user}:{pg_pass}@{pg_host}:5432/mageai"

        create_response = self.client.secrets.kv.v1.create_or_update_secret(
                path='helm',
                secret=dict(pg_user=pg_user,
                            pg_host=pg_host,
                            pg_pass=pg_pass,
                            mageconnurl=mageconnurl,
                            hf_token=hf_token,
                            gh_token=gh_token,
                            app_admin=app_admin
                            ),
                mount_point='eso'
        )

    def main(self):
        try:
            root_token, unseal_keys = self.initialize_vault()
            self.unseal_vault(root_token, unseal_keys)
            self.store_in_aws_secrets_manager(root_token, unseal_keys)
            self.configure_vault_kubernetes_auth(root_token)
            secret = self.enable_eso_engine(root_token)
            self.create_kubernetes_secret(secret)
            self.eso_values(root_token)
        except Exception as error:
            print(f"An error occurred: {error}")


def secrets_updater(project_name):
    secrets_manager = SecretsManager(SECRETS)
    secrets = secrets_manager.batch_get_secrets()

    for db in DATABASES:
        DatabaseOperations(project_name=project_name, **secrets).create_database(db)
    return secrets

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Update secrets and manage the vault.')
    parser.add_argument('--project-name', '-p', type=str, help='Name of the project', required=True)

    args = parser.parse_args()

    SECRETS = [f'{args.project_name}-{sec}' for sec in SECRETS]

    secrets = secrets_updater(args.project_name)
    vault_manager = VaultManager(args.project_name, **secrets)
    vault_manager.main()
