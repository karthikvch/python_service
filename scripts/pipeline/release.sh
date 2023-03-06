AWS_S3_BUCKET=$1
S3_KEY=$2
AWS_ACCESS_KEY_ID=$3
AWS_SECRET_ACCESS_KEY=$4
local_path=$5
json_file_path=$6
release_app_version=$7

echo AWS_S3_BUCKET is $AWS_S3_BUCKET
echo S3_KEY is $S3_KEY
echo AWS_ACCESS_KEY_ID is $AWS_ACCESS_KEY_ID
echo AWS_SECRET_ACCESS_KEY is $AWS_SECRET_ACCESS_KEY
echo local_path is $local_path
echo json_file_path is $json_file_path
# Remove any existing versions of a json
rm -rf $local_path
# Create a zip of the current directory.
cp $json_file_path  $local_path

#zip -r $local_path . -x .git/ .git/*** .github/workflows/release.yml scripts/pipeline/release.sh scripts/pipeline/upload_file_to_s3.py
# Install required dependencies for Python script to run.
pip3 install setuptools
pip3 install boto3
# Run upload script
python3 scripts/pipeline/upload_file_to_s3.py $AWS_S3_BUCKET $S3_KEY $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $local_path
