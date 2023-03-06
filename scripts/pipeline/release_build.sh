#!/bin/bash
echo "in release_build.sh file"
token=$1
api_token=$2
appversion=$(cat version-release.json|grep unified_version|cut -d ":" -f2)
echo $appversion


unified_version=`jq '.unified_version' version-release.json`
echo $unified_version



name=`jq '.applications[0].name' version-release.json`
echo $name


tag=`jq '.applications[0].tag' version-release.json`
echo $tag



pwd
cd /tmp
pwd
echo "$appversion">version
sed -e 's/"//g' -i version
sed -e 's/,//g' -i version
build_version=$(cat version)
echo "build_versionL $build_version"
branch_version=$build_version.$(date +%H.%M.%S)

echo "branch_version $branch_version"


unified_version=`jq '.unified_version' version-release.json`
echo $unified_version



name=`jq '.applications[0].name' version-release.json`
echo $name


tag=`jq '.applications[0].tag' version-release.json`
echo $tag
