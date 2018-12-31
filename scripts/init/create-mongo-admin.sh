#!/bin/bash

qrPod=$(kubectl get pods|grep "mongo-qr"|head -1|awk '{print $1}')
kubectl exec $qrPod -- mongo --eval "db.getSiblingDB(\"admin\").createUser({user: \"admin\", pwd: \"$ADMIN_PASSWORD\", roles: [ { role: \"root\", db: \"admin\" } ] });"