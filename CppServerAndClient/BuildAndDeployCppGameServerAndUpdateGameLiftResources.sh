#!/bin/bash

# Get the configuration variables
source ../configuration.sh

# Returns the status of a stack
getstatusofstack() {
	aws cloudformation describe-stacks --region $region --stack-name $1 --query Stacks[].StackStatus --output text 2>/dev/null
}

echo "Building the server"
cd Server
./build.sh
cd ..

# Deploy the build to GameLift 
echo "Deploying build to GameLift"
buildversion=$(date +%Y-%m-%d.%H:%M:%S)
aws gamelift upload-build --operating-system AMAZON_LINUX_2 --build-root ./ServerBuild/ --name "Cpp Game Server Example" --build-version $buildversion --region $region

# Get the build version for fleet deployment
query='Builds[?Version==`'
query+=$buildversion
query+='`].BuildId'
buildid=$(aws gamelift list-builds --query $query --output text --region $region)
echo $buildid

# Deploy rest of the resources with CloudFromation
stackstatus=$(getstatusofstack GameliftExampleResources)
if [ -z "$stackstatus" ]; then
  echo "Creating stack for example fleet (this will take some time)... NOTE: The waiter will likely time out as Cloud9 has a 15 minute expiration for AWS tokens. PLEASE CHECK that the stack is complete in CloudFormation before moving to the next step"
  aws cloudformation --region $region create-stack --stack-name GameliftExampleResources \
      --template-body file://../FleetDeployment/gamelift.yaml \
      --parameters ParameterKey=BuildId,ParameterValue=$buildid ParameterKey=SecondaryLocation,ParameterValue=$secondaryregion \
      --capabilities CAPABILITY_IAM
  aws cloudformation --region $region wait stack-create-complete --stack-name GameliftExampleResources
  echo "Done creating stack!"
else
  echo "Updating stack for example fleet (this will take some time)... NOTE: The waiter will likely time out as Cloud9 has a 15 minute expiration for AWS tokens. PLEASE CHECK that the stack is complete in CloudFormation before moving to the next step"
  aws cloudformation --region $region update-stack --stack-name GameliftExampleResources \
     --template-body file://../FleetDeployment/gamelift.yaml \
     --parameters ParameterKey=BuildId,ParameterValue=$buildid ParameterKey=SecondaryLocation,ParameterValue=$secondaryregion \
     --capabilities CAPABILITY_IAM
  aws cloudformation --region $region wait stack-update-complete --stack-name GameliftExampleResources
  echo "Done updating stack!"
fi