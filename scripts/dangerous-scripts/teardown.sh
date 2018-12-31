# delete configs
kubectl delete service mongo-config-svc
kubectl delete statefulset mongo-config

# Delete secrets
kubectl delete secrets/mongodb-key
kubectl delete secret mongodb-pwd

# Delete query router
kubectl delete service mongo-qr
kubectl delete deployment.apps/mongo-qr

# Delete shards
numberOfServices=$(kubectl get services | grep mongo-shard | wc -l)
numberOfShards=$(kubectl get pods| grep mongo-shard | awk '{if (NR!=1) {print substr($1, 1, length($1)-2)}}' | uniq | wc -l)

# delete shard services
COUNTER=0
while [  $COUNTER -lt $numberOfShards ]; do
    kubectl delete service/mongo-shard$COUNTER-svc
    let COUNTER=COUNTER+1 
done

# delete shards
COUNTER=0
while [  $COUNTER -lt $numberOfShards ]; do
    kubectl delete statefulset mongo-shard$COUNTER
    let COUNTER=COUNTER+1 
done

# Delete pv's
kubectl delete persistentvolumeclaim mongo-pv-claim
kubectl delete persistentvolume pv-volume