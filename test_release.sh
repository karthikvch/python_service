
local_path=$1
echo local_path is $local_path
###############################monarch-devops#############################
chmod -R 775 scripts/*.sh
pwd
cd ..

zip -r $local_path python-test

mv $local_path python-test

cd python-test

echo "done"