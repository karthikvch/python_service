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

# ############################Indicator_Engine#################################################################
    cd /tmp
    build_version=`cat version`
    git clone https://x-access-token:$token@github.com/karthikvch/python_test.git
    curl --request PUT -H "Content-Type:application/json" -H "Authorization:$api_token" --data "{  \"software_version\": \"$build_version\", \"build_status\": \"inprogress\", \"remarks\": \"Indicator_Engine build is inprogress\"}" https://nexus-api.uat.monarchtractor.net/fleet/software/update-build-status
    cd Indicator-Engine
    git config --global user.email "koutilya.g@enlume.com"
    git config --global user.name "koutilya06"
    git checkout -b release-v$branch_version
    echo > VERSION
    echo $build_version > VERSION
    git add .
    git commit -m "Update release version $build_version"
    git push  origin release-v$branch_version
    git tag -a release/v$branch_version -m "Weekly release build"
    git push  origin release/v$branch_version
    sleep 20
    while [ "$(gh run list --workflow python-package.yml -R 'github.com/Monarch-Tractor/Indicator-Engine' | awk 'NR==1 {print $1}')" != "completed" ]
    do
        sleep 10
    done
    if [ "$(gh run list --workflow python-package.yml -R 'github.com/Monarch-Tractor/Indicator-Engine' | awk 'NR==1 {print $2}')" == "success" ]
    then
        Indicator_Engine_last_commit=$(git rev-parse HEAD);
        Indicator_Engine_duration="$(gh run list --workflow python-package.yml -R 'github.com/Monarch-Tractor/Indicator-Engine' --branch release/v$branch_version | awk 'NR=1 {print $(NF -1)}')"
        export Indicator_Engine_last_commit
        export Indicator_Engine_duration
        echo $Indicator_Engine_duration
        curl --request PUT -H "Content-Type:application/json" -H  "Authorization:$api_token" --data "{  \"software_version\": \"$build_version\", \"build_status\": \"inprogress\", \"remarks\": \"Indicator_Engine build is completed, git hash: $Indicator_Engine_last_commit, Duration: $Indicator_Engine_duration \"}" https://nexus-api.uat.monarchtractor.net/fleet/software/update-build-status
        echo '                {
                        "name":"Indicator-Engine",
                        "version":"'$build_version'"
                },' >> /tmp/release-version.json
    else
        echo "Your Indicator-Engine is failed, Please check all the repositories"
        curl --request PUT -H "Content-Type:application/json" -H  "Authorization:$api_token" --data "{  \"software_version\": \"$build_version\", \"build_status\": \"failed\", \"remarks\": \"Indicator_Engine build is failed\"}" https://nexus-api.uat.monarchtractor.net/fleet/software/update-build-status
        exit 1
    fi
