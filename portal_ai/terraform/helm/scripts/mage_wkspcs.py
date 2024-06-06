if 'custom' not in globals():
    from mage_ai.data_preparation.decorators import custom
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

import requests
import os
import re
import yaml
import psycopg2
import json
from kubernetes import client, config


ENVS = [
    'DB_USER',
    'DB_PASS',
    'DB_NAME',
    'MAGE_DATABASE_CONNECTION_URL',
    'MANAGE_URL'
]


class MageOps:
    def __init__(self):
        pass

    @staticmethod
    def get_pg_conn(database=None, **kwargs):
        database = database if database is not None else 'postgres'
        connection = psycopg2.connect(
            user=kwargs.get('DB_USER'),
            password=kwargs.get('DB_PASS'),
            host=kwargs.get('DB_HOST'),
            port=5432,
            database=database,
        )
        return connection

    @staticmethod
    def pg_q(pg_conn, q):
        cursor = pg_conn.cursor()
        cursor.execute(q)
        pg_resp = cursor.fetchall()
        return pg_resp

    @staticmethod
    def load_yml(path):
        with open(path, 'r') as file:
            return yaml.safe_load(file)

    @staticmethod
    def get_pod_ip():
        config.load_incluster_config()
        api_instance = client.CoreV1Api()
        service = api_instance.read_namespaced_service(name='mageai', namespace='mageai')
        cluster_ip = service.spec.cluster_ip
        return cluster_ip

    @staticmethod
    def create_workspace(name, s, api_key, **kwargs):
        json_data = {
            'workspace': {
                'name': name,
                'namespace': kwargs.get('namespace'),
                'service_account_name': kwargs.get('service_account_name'),
                'ingress_name': kwargs.get('ingress_name'),
                'storage_class_name': kwargs.get('storage_class_name'),
                'storage_request_size': kwargs.get('storage_request_size'),
                'storage_access_mode': kwargs.get('storage_access_mode'),
                'pvc_retention_policy': kwargs.get('pvc_retention_policy'),
                'update_workspace_settings': False,
                'cluster_type': 'k8s',
                'lifecycle_config': {
                    'termination_policy': {
                        'enable_auto_termination': True,
                        'max_idle_seconds': kwargs.get('max_idle_seconds'),
                    },
                },
            },
            'api_key': api_key,
        }

        print(json.dumps(json_data))
        print('------------------')

        response = s.post(
            url=f'http://{MageOps.get_pod_ip()}:6789/api/workspaces',
            json=json_data,
        )
        return response

    @staticmethod
    def mage_session(**kwargs):
        oauth_q = """
            select 
                client_id
            from 
            public.oauth2_application
            where authorization_grant_type = 'AUTHORIZATION_CODE'
            and client_type = 'PUBLIC'
            and "name" = 'frontend'
            limit 1;
            """

        pg_conn = MageOps.get_pg_conn('mageai', **kwargs)
        tkn = MageOps.pg_q(pg_conn, oauth_q)[0][0]

        manage_url = kwargs.get('MANAGE_URL')
        email = 'admin@admin.com'
        pwd = 'admin'

        cookies = {
            'REQUIRE_USER_AUTHENTICATION': 'true',
            'REQUIRE_USER_PERMISSIONS': 'false',
        }

        params = {
            'api_key': tkn,
        }

        headers = {
            "Content-Type": "application/json",
            "X-API-KEY": tkn
        }

        json_data = {
            'session': {
                'email': email,
                'password': pwd,
            },
        }

        s = requests.Session()
        s.headers = headers

        r = s.post(
            url=f'http://{MageOps.get_pod_ip()}:6789/api/sessions',
            json=json_data,
        )

        if r.json().get('error'):
            raise ValueError(r.text)
        else:
            mage_session = r.json().get('session')
            token = mage_session.get('token')
            s.headers['Cookie'] = f'oauth_token={token}'
            return (s, tkn)


@custom
def transform_custom(*args, **kwargs):
    """
    args: The output from any upstream parent blocks (if applicable)

    Returns:
        Anything (e.g. data frame, dictionary, array, int, str, etc.)
    """
    mage_ops = MageOps()
    pg = {k: v for k, v in os.environ.items() if k in ENVS}
    pg['DB_HOST'] = re.split(':|@', pg.get('MAGE_DATABASE_CONNECTION_URL'))[-2]
    pg_conn = mage_ops.get_pg_conn(database=pg.get('DB_NAME'), **pg)
    (s, tkn) = mage_ops.mage_session(**pg)

    workspace_settings = mage_ops.load_yml('/home/src/aws_plus_global_settings_base_yml').get(
        'mageai_wkspcs'
    )
    spaces = workspace_settings.get('spaces')
    workspace_settings.pop('spaces')
    for spc in spaces:
        for name, sets in spc.items():
            settings = {**workspace_settings, **sets}
            response = mage_ops.create_workspace(name, s, tkn, **settings)
    return True


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
