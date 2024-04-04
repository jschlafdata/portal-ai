from portal_ai.setup.init_global_settings import AWSConfigGenerator
from portal_ai.setup.key_gen import SSHKeyGenerator
from portal_ai.setup.tf_remote_states import RemoteS3Manager

def main():

    SSHKeyGenerator.generate_keys()
    AWSConfigGenerator.generate_configs()
    RemoteS3Manager().manage_s3_buckets()
    RemoteS3Manager().setup_tf_backend()

if __name__ == "__main__":
    main()
