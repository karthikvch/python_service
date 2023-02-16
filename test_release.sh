
local_path=$1
echo local_path is $local_path
###############################monarch-devops#############################
chmod -R 775  *.sh
pwd
cd ..

zip -r $local_path python_test

mv $local_path python_test

cd python_test

echo "done"
