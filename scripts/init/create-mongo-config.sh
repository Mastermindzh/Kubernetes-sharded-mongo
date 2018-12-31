#!/bin/bash

kubectl apply -f ../resources/mongo-config.yaml

n=$(kubectl get pods|grep -w 'mongo-config-.'|grep Running|wc -l)

internalSystemMessage "Waiting for pods to be ready..."
while [ "$n" != "3" ]
do
  sleep 5
  n=$(kubectl get pods|grep -w 'mongo-config-.'|grep Running|wc -l)
done

internalSystemMessage "Checking replicaset..."
nr=$(kubectl exec mongo-config-0 -- mongo --eval "rs.status();"|grep "NotYetInitialized"|wc -l)

if [[ $nr -gt 0 ]]
then
  echo "Replicaset not yet initialized, initializing..."
  kubectl exec mongo-config-0 -- mongo --eval "rs.initiate({_id: \"crs\", configsvr: true, members: [ {_id: 0, host: \"mongo-config-0.mongo-config-svc.default.svc.cluster.local:27017\"}, {_id: 1, host: \"mongo-config-1.mongo-config-svc.default.svc.cluster.local:27017\"}, {_id: 2, host: \"mongo-config-2.mongo-config-svc.default.svc.cluster.local:27017\"} ]});"
else
  echo "Replicaset already initialized, skipping."
fi
