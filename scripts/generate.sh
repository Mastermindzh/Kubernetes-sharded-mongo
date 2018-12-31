#!/bin/bash

# load in config values
source config.sh
source helpers/helpers.sh

# check whether the shardcount was provided, if so, use that instead of the preconfigured number
if [ -z "$1" ];
then
  echo
else
  SHARDCOUNT=$1
fi

if [[ $SHARDCOUNT -gt 1 ]]
then
  systemMessage "Number of shards set to: $SHARDCOUNT"
else
  errorMessage "Number of shards should be set to at least 2" && exit 1
fi

systemMessage "labeling the first node for the config pods..."
configPod=$(kubectl get nodes | grep Ready | awk 'NR==1{print $1}')
kubectl label nodes $configPod component=mongo-config

# Create persistent volumes
systemMessage "Creating mongo persistent volumes..." false
source init/create-mongo-pv.sh

# Check for cluster passwords
systemMessage "Checking for cluster passwords..." false
source init/create-mongo-auth.sh

# Set up mongo config containers
systemMessage "Setting up mongo config containers..."
source init/create-mongo-config.sh

# Set up the mongo routers
systemMessage "Setting up the mongos routers..."
source init/create-mongo-routers.sh

# Set up the mongo admin user
systemMessage "Creating mongo admin user..."
source init/create-mongo-admin.sh

# Spin up the mongo shards
systemMessage "Creating mongo shards..."
source init/create-mongo-shards.sh

# Expose mongo if dev mode is on
if [ "$DEV_MODE" = true ] ; then
  systemMessage "Setting up development port"
  kubectl expose deployment mongo-qr --type=NodePort

  DEVURL=$(minikube service mongo-qr --url)

  echo "Dev port set up succesfully"
  echo "- navigate to ${DEVURL}"
  echo "- connect with mongo: ${DEVURL/http:\/\//mongodb:\/\/user:pass\@}"    
fi
