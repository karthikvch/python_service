#!/bin/bash
token=$1
api_token=$2
appversion=$(cat version-release.json|grep unified_version|cut -d ":" -f2)
cd /tmp
echo "$appversion">version
sed -e 's/"//g' -i version
sed -e 's/,//g' -i version
build_version=$(cat version)
branch_version=$build_version.$(date +%H.%M.%S)
echo '{
      "unified_version":"'$build_version'",' > /tmp/release-version.json
echo "$token" > /tmp/token
cat /tmp/token
gh auth login --with-token < /tmp/token
curl --request PUT -H "Content-Type:application/json" -H "Authorization:$api_token" --data "{  \"software_version\": \"$build_version\", \"build_status\": \"inprogress\", \"remarks\": \"Build is started\"}" https://nexus-api.uat.monarchtractor.net/fleet/software/update-build-status
sleep 60
curl --request PUT -H "Content-Type:application/json" -H "Authorization:$api_token" --data "{  \"software_version\": \"$build_version\", \"build_status\": \"inprogress\", \"remarks\": \"X6_WS build is inprogress\"}" https://nexus-api.uat.monarchtractor.net/fleet/software/update-build-status

#####################################tractor-migration-service#################################################
Pydbc2msg_build=builds/pydbc2msg/pydbc2msg-v$build_version.zip
pydbc2msg_success=$(aws s3 ls s3://monarch-tractor-releases/"$Pydbc2msg_build")
if [[ -n  "$pydbc2msg_success" ]]
then 
    cd /tmp
    git clone https://x-access-token:$token@github.com/Monarch-Tractor/tractor-migration-service.git
    curl --request PUT -H "Content-Type:application/json" -H "Authorization:$api_token" --data "{  \"software_version\": \"$build_version\", \"build_status\": \"inprogress\", \"remarks\": \"tractor-migration-service build is inprogress\"}" https://nexus-api.uat.monarchtractor.net/fleet/software/update-build-status
    build_version=$(cat version)
    cd tractor-migration-service
    git config --global user.email "koutilya.g@enlume.com"
    git config --global user.name "koutilya06"
    git checkout -b release-v"$branch_version"
    echo > VERSION
    echo "$build_version" > VERSION
    git add .
    git commit -m "Update release version $build_version"
    git push  origin release-v"$branch_version"
    git tag -a release/v"$branch_version" -m "Weekly release build"
    git push  origin release/v"$branch_version"
    sleep 20
    while [ "$(gh run list --workflow python-package.yml -R 'github.com/Monarch-Tractor/tractor-migration-service' | awk 'NR==1 {print $1}')" != "completed" ]
    do 
        sleep 10
    done
    if [ "$(gh run list --workflow python-package.yml -R 'github.com/Monarch-Tractor/tractor-migration-service' | awk 'NR==1 {print $2}')" == "success" ]
    then
        tractor_migration_service_last_commit=$(git rev-parse HEAD);
        tractor_migration_service_duration=$(gh run list --workflow python-package.yml -R 'github.com/Monarch-Tractor/tractor-migration-service' --branch release/v"$branch_version" | awk 'NR=1 {print $(NF -1)}')
        export tractor_migration_service_last_commit
        export tractor_migration_service_duration
        curl --request PUT -H "Content-Type:application/json" -H "Authorization:$api_token" --data "{ \"software_version\": \"$build_version\", \"build_status\": \"inprogress\", \"remarks\": \"tractor-migration-service build is completed, git hash: $tractor_migration_service_last_commit, Duration: $tractor_migration_service_duration\"}" https://nexus-api.uat.monarchtractor.net/fleet/software/update-build-status
        echo '                {
                        "name":"tractor-migration-service",
                        "version":"'$build_version'"
                },' >> /tmp/release-version.json
    else
        echo "Your tractor-migration-service is failed, Please check all the repositories"
        curl --request PUT -H "Content-Type:application/json" -H "Authorization:$api_token" --data "{  \"software_version\": \"$build_version\", \"build_status\": \"failed\", \"remarks\": \"tractor-migration-service build is failed, Please check all the repos\"}" https://nexus-api.uat.monarchtractor.net/fleet/software/update-build-status
        exit 1
    fi
else
    echo "Your pydbc2msg is failed, Please check all the repositories"
    curl --request PUT -H "Content-Type:application/json" -H "Authorization:$api_token" --data "{  \"software_version\": \"$build_version\", \"build_status\": \"failed\", \"remarks\": \"pydbc2msg build is failed, Please check all the repos\"}" https://nexus-api.uat.monarchtractor.net/fleet/software/update-build-status
    exit 1
fi
