import boto3
import sys
def main():
    if (len(sys.argv) < 6):
        print ('Error: Required 5 arguments.')
        # Checks for 6 because the script path is in position 0. So len is 6
        # for 5 arguments.
        sys.exit(1)
    AWS_S3_BUCKET=sys.argv[1]
    S3_KEY=sys.argv[2]
    AWS_ACCESS_KEY_ID=sys.argv[3]
    AWS_SECRET_ACCESS_KEY=sys.argv[4]
    local_path=sys.argv[5]
    session = boto3.Session(
        aws_access_key_id=AWS_ACCESS_KEY_ID,
        aws_secret_access_key=AWS_SECRET_ACCESS_KEY,
    )
    client = session.client('s3')
    response = client.upload_file(
        Filename=local_path,
        Bucket=AWS_S3_BUCKET,
        Key=S3_KEY
    )
    print ('Done uploading')
main()
