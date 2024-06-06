import os

def get_project_env():
    environment = os.getenv('deployment-environment', 'dev')
    return environment