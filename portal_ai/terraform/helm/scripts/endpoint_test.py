import requests
import time
import sys
import json
from portal_ai.settings.logger import LoggerConfig
from portal_ai.settings.load_settings import (
    ConfigReader,
    ConfigurationLoader
)

def hit_endpoint(url, max_retries=15, retry_interval=60):
    retries = 0
    while retries < max_retries:
        try:
            response = requests.get(url)
            if response.status_code == 200:
                return True
            else:
                logger.info(f"Received non-200 status code: {response.status_code}. Retrying...")
        except Exception as e:
            logger.error(f"Error occurred: {e}. Retrying...")
        
        retries += 1
        time.sleep(retry_interval)
    
    logger.error(f"Failed to get a valid response after {max_retries} retries.")
    return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: hit_endpoint.py <ingress_name>")
        sys.exit(1)
    
    ingress_name = sys.argv[1]

    logger = LoggerConfig.get_logger(__name__)
    loader = ConfigurationLoader(ConfigReader)
    deploment_configs = loader.generated_config_loader('aws_plus_global_base')

    domain = deploment_configs.get('dns').get('dns_domain')
    url = f"https://{ingress_name}.{domain}"

    response_data = hit_endpoint(url)

    if response_data:
        logger.info(f'This website is live: {url}')
        output = {'status': '200', 'message': f'This website is live: {url}'}
    else:
        logger.info("Failed to get a valid response.")
        sys.exit(1)
    
    print(json.dumps(output))  # Ensure this is the only print to stdout
