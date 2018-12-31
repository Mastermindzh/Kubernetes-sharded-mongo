#!/bin/bash

kubectl apply -f ../resources/mongo-qr.yaml

nqr=$(kubectl get pods|grep "mongo-qr"|grep "Running"|wc -l)
wait=0

internalSystemMessage "Waiting for pods to be ready..."
while [[ $nqr -lt 1 ]]
do
  sleep 1
  wait=1
  nqr=$(kubectl get pods|grep "mongo-qr"|grep "Running"|wc -l)
done

internalSystemMessage "Query router pods are up ($nqr)"

if [[ $wait -eq 1 ]]; then 
  internalSystemMessage "Waiting for routers to initialize" && sleep 30; 
fi
