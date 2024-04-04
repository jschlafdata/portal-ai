from kubernetes import client, config
import time
import sys
import json

from portal_ai.settings.logger import LoggerConfig
from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)

def log_to_stderr(message):
    sys.stderr.write(message + "\n")

def wait_for_pod_to_be_running(pod_name, logger, namespace='default', timeout=300):
    """
    Wait for a specific pod to be in the 'Running' state.
    
    Args:
        pod_name (str): The name of the pod to check.
        namespace (str): The namespace of the pod. Defaults to 'default'.
        timeout (int): How long to wait for the pod to be running, in seconds. Defaults to 300 seconds.
        
    Returns:
        bool: True if the pod is in 'Running' state within the timeout, False otherwise.
    """
    config.load_kube_config()  # Make sure your kubeconfig is correctly set up
    v1 = client.CoreV1Api()
    start_time = time.time()
    
    while True:
        try:
            pod = v1.read_namespaced_pod(name=pod_name, namespace=namespace)
            if pod.status.phase == 'Running':
                logger.info(f"{pod_name} is in Running state.")
                return True
        except client.exceptions.ApiException as e:
            logger.info(f"Error fetching pod info: {e}")
            return False
        
        if time.time() - start_time > timeout:
            logger.info(f"Timeout reached: {pod_name} is not in Running state after {timeout} seconds.")
            return False
        
        logger.info(f"Waiting for {pod_name} pod to be in Running state...")
        time.sleep(5)


if __name__ == "__main__":
    pod_name = 'vault-0'  # Pod name to check
    namespace = 'default'  # Namespace where the pod is deployed

    logger = LoggerConfig.get_logger(__name__)

    if wait_for_pod_to_be_running(pod_name, logger, namespace):
        output = {'status': '200', 'message': 'Vault is live boi'}
    else:
        sys.exit(1)

    print(json.dumps(output))  # Ensure this is the only print to stdout