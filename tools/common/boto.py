import boto3
from botocore.exceptions import ClientError

class BotoS3:
    def __init__(self, aws_profile, aws_region, action):
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

    def create_s3_bucket(self, bucket_name):
        try:
            self.s3_client.create_bucket(Bucket=bucket_name, CreateBucketConfiguration={'LocationConstraint': self.aws_region})
            print(f"Successfully created bucket: {bucket_name}")
        except ClientError as e:
            if e.response['Error']['Code'] == 'BucketAlreadyOwnedByYou':
                print(f"Bucket already exists: {bucket_name}")
                print(f"S3 URL: https://{bucket_name}.s3.{self.aws_region}.amazonaws.com")
            else:
                print(f"Error creating bucket: {e}")

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
            print(f"Updated policies for bucket: {bucket_name}")
        except ClientError as e:
            print(f"Error updating policies for bucket {bucket_name}: {e}")

    def delete_all_objects(self, bucket_name):
        bucket = self.s3_resource.Bucket(bucket_name)
        bucket.objects.delete()
        try:
            bucket.delete()
            print(f"Successfully deleted all objects in bucket: {bucket_name}")
        except ClientError as e:
            print(f"Error occurred when deleting objects in bucket: {bucket_name}")
            print(e)