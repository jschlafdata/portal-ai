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
from tools.settings import BaseDir

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
                print(sql_command)
                cur.execute(sql.SQL(sql_command))
            except DuplicateDatabase as e:
                print('database already exists!')
        conn.close()
        return

class InitESOVault:
    def __init__(self, **kwargs):
            self.kwargs = kwargs
        
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

        ## this returns a 204 reposnse code;
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
                 global_settings_path
                ):
        self.environment = environment

        self.settings = load_yaml_file(global_settings_path)
        rds_token_path = self.settings.get('rds_token_path')
        rds_token_path = os.path.expanduser(rds_token_path)
        load_dotenv(rds_token_path)

        with open(rds_token_path, 'r') as file:
            rds = file.read()
            print(rds)
        # Attempt to print a specific environment variable to verify it's loaded
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
        db_ops = DatabaseOperations(**self.vars)
        db_ops.create_database()
        db_ops.create_database(database = 'metabase_backend')
        db_ops.create_database(database = 'portal_backend')

        InitESOVault(**self.vars).write_to_vault()



if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python init_backends.py <environment>")
        sys.exit(1)
    
    if not BaseDir().set_dir():
        sys.exit()

    environment = sys.argv[1]
    BackendInitializer(environment, f'./{environment}/rbac/input_configs/mage_rbac_configs.yml').initialize_backend()