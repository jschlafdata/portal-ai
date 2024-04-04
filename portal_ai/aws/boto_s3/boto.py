import boto3
from botocore.exceptions import ClientError
from portal_ai.settings.logger import LoggerConfig



class BotoS3:
    def __init__(self, aws_profile, aws_region, action):
        self.logger = LoggerConfig.get_logger(__name__)
        self.aws_profile = aws_profile
        self.aws_region = aws_region
        self.action = action
        self.s3_client = self.get_boto_s3_client()
        self.s3_resource = self.get_boto_s3_resource()

    def get_boto_session(self):
        session = boto3.Session(profile_name=self.aws_profile,
                                region_name=self.aws_region)
        return session

    def get_boto_s3_client(self):
        session = self.get_boto_session()
        s3 = session.client('s3')
        return s3

    def get_boto_s3_resource(self):
        session = self.get_boto_session()
        s3 = session.resource('s3')
        return s3

    def get_boto_elbv2_client(self):
        session = self.get_boto_session()
        elbv2_client = session.client('elbv2')
        return elbv2_client
    
    def bucket_exists(self, bucket_name):
        """
        Check if an S3 bucket exists.
        """
        try:
            self.s3_client.head_bucket(Bucket=bucket_name)
            return True
        except Exception as e:
            return False

    def create_s3_bucket(self, bucket_name):
        try:
            if self.bucket_exists(bucket_name):
                self.logger.info(f"Bucket {bucket_name} already exists.")
            else:
                try:
                    if self.aws_region == 'us-east-1':
                        self.s3_client.create_bucket(Bucket=bucket_name)
                    else:
                        self.s3_client.create_bucket(
                            Bucket=bucket_name,
                            CreateBucketConfiguration={'LocationConstraint': self.aws_region}
                        )
                    self.logger.info(f"Successfully created bucket: {bucket_name}")
                except ClientError as e:
                    if e.response['Error']['Code'] == 'BucketAlreadyOwnedByYou':
                        self.logger.info(f"Bucket already exists: {bucket_name}")
                    else:
                        self.logger.info(f"Error creating bucket: {e}")
        except Exception as e:
            self.logger.info(f"Uncaught error exception creating bucket: {e}")

    def update_bucket_policies(self, bucket_name):
        try:
            self.s3_client.put_public_access_block(
                Bucket=bucket_name,
                PublicAccessBlockConfiguration={
                    'BlockPublicAcls': False,
                    'IgnorePublicAcls': False,
                    'BlockPublicPolicy': False,
                    'RestrictPublicBuckets': False
                }
            )
            self.s3_client.put_bucket_ownership_controls(
                Bucket=bucket_name,
                OwnershipControls={
                    'Rules': [{'ObjectOwnership': 'BucketOwnerPreferred'}]
                }
            )
            self.logger.info(f"Updated policies for bucket: {bucket_name}")
        except ClientError as e:
            self.logger.info(f"Error updating policies for bucket {bucket_name}: {e}")

    def delete_all_objects(self, bucket_name):
        bucket = self.s3_resource.Bucket(bucket_name)
        bucket.objects.delete()
        try:
            bucket.delete()
            self.logger.info(f"Successfully deleted all objects in bucket: {bucket_name}")
        except ClientError as e:
            self.logger.info(f"Error occurred when deleting objects in bucket: {bucket_name}")
            self.logger.info(e)
