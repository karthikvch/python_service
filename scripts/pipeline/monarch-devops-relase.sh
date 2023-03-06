AWS_S3_BUCKET=$1
S3_KEY=$2
AWS_ACCESS_KEY_ID=$3
AWS_SECRET_ACCESS_KEY=$4
local_path=$5


echo AWS_S3_BUCKET is $AWS_S3_BUCKET
echo S3_KEY is $S3_KEY
echo AWS_ACCESS_KEY_ID is $AWS_ACCESS_KEY_ID
echo AWS_SECRET_ACCESS_KEY is $AWS_SECRET_ACCESS_KEY
echo local_path is $local_path

# echo $appversion>version
# sed -e 's/"//g' -i version
# sed -e 's/,//g' -i version
# build_version=`cat version`
# branch_version=$build_version.`date +%H.%M.%S`
###############################monarch-devops#############################

chmod -R 775 scripts/*.sh
pwd
cd ..

zip -r $local_path monarch-devops

mv $local_path monarch-devops

cd monarch-devops

pip3 install setuptools
pip3 install boto3
# Run upload script
python3 scripts/pipeline/upload_file_to_s3.py $AWS_S3_BUCKET $S3_KEY $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY $local_path