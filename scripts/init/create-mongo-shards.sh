#!/bin/bash

export shards=0
MONGO_SHARD_PATH="../resources/mongo-shard.yaml"
MONGO_SHARD_WORKING_DIR="../workingdir/"

mkdir -p $MONGO_SHARD_WORKING_DIR;

while [[ $shards -lt $SHARDCOUNT ]]
do
  internalSystemMessage "-> Creating mongo-shard$shards.."
  sed "s/shard0/shard$shards/g" $MONGO_SHARD_PATH > "$MONGO_SHARD_WORKING_DIR/mongo-shard$shards.yaml"
  kubectl apply -f "$MONGO_SHARD_WORKING_DIR/mongo-shard$shards.yaml"
  n=$(kubectl get pods|grep -w "mongo-shard$shards-."|grep Running|wc -l)
  wait=0

  internalSystemMessage "Waiting for pods to be ready.."
  while [ "$n" != "3" ]
  do
    sleep 5
    wait=1
    n=$(kubectl get pods|grep -w "mongo-shard$shards-."|grep Running|wc -l)
  done

  internalSystemMessage "Mongo shard$shards pods are up.. waiting a sec for them to initialize"
  if [[ $wait -eq 1 ]]; then 
    sleep 20; 
  fi

  nr=$(kubectl exec mongo-shard$shards-0 -- mongo --eval "rs.status();"|grep "NotYetInitialized"|wc -l)
  if [[ $nr -gt 0 ]]
  then
    internalSystemMessage "Replicaset not yet initialized, initializing"
    kubectl exec mongo-shard$shards-0 -- mongo --eval "rs.initiate({_id: \"shard$shards\", members: [ {_id: 0, host: \"mongo-shard$shards-0.mongo-shard$shards-svc.default.svc.cluster.local:27017\"}, {_id: 1, host: \"mongo-shard$shards-1.mongo-shard$shards-svc.default.svc.cluster.local:27017\"}, {_id: 2, host: \"mongo-shard$shards-2.mongo-shard$shards-svc.default.svc.cluster.local:27017\"} ]});"
    sleep 10
  else
    internalSystemMessage "Replicaset already initialized, skipping"
  fi

  shardIdRows=$(kubectl exec $qrPod -- mongo admin -u admin -p "$ADMIN_PASSWORD" --eval "sh.status();"|grep "shard$shards"|wc -l)
  if [[ $shardIdRows -gt 0 ]]
  then
    internalSystemMessage "Shard shard$shards is already added to mongos qr. Skipping addShard"
  else
    internalSystemMessage "Shard shard$shards is not yet added to mongos qr. Invoking addShard"
    kubectl exec $qrPod -- mongo admin -u admin -p "$ADMIN_PASSWORD" --eval "sh.addShard(\"shard$shards/mongo-shard$shards-0.mongo-shard$shards-svc.default.svc.cluster.local:27017\");"
  fi
  shards=$(($shards+1))
done