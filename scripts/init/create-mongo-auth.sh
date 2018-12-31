#!/bin/bash

# check whether we are sourced, if not check whether we can find config
if [ "$0" = "$BASH_SOURCE" ]; then
    if [ ! -f ../config.sh ]; then
        if [ ! -f "$PWD/config.sh" ]; then
            echo "can't find config.sh in ../config.sh or PWD"
            exit 1
        else
            source "$PWD/config.sh"
        fi  
    else
        source ../config.sh
    fi
fi

kubectl get secrets/mongodb-key

if [[ $? -ne 0 ]]
then
    echo "Creating mongodb-key..."
    openssl rand -base64 741 > ../$SECRET_KEY_PATH
    
    echo "Adding to kubebernetes secrets.."
    kubectl create secret generic mongodb-key --from-file="../$SECRET_KEY_PATH"
else
    echo "Keyfile exists..."
fi

echo ""
kubectl get secrets/mongodb-pwd

if [[ $? -ne 0 ]]
then
    echo "Creating mongodb-pwd.."
    kubectl create secret generic mongodb-pwd --from-literal=pwd="$ADMIN_PASSWORD"  
else
    echo "Admin password already exists..."
fi