#!/bin/bash

CLUSTER=$(minikube status)
STATUS=$?
if [ "$STATUS" -lt 1 ]; then
  echo "Existing minikube detected.";
  minikube delete
else
  echo "Starting fresh!";
fi

minikube start --memory 8192



pwd=$(pwd)

minikube ssh "cd ${pwd} && ./bin/build.sh"
helm repo add prometheus https://prometheus-community.github.io/helm-charts
helm install prometheus --namespace "kube-system" prometheus/prometheus --set server.service.type=NodePort

kubectl apply -f infrastructure/grafana-configmap.yaml
kubectl apply -f infrastructure/grafana-deployment.yaml
kubectl apply -f infrastructure/grafana-service.yaml

kubectl apply -f infrastructure/es-statefulset.yaml
kubectl apply -f infrastructure/es-service.yaml

kubectl apply -f infrastructure/fluentd-es-configmap.yaml
kubectl apply -f infrastructure/fluentd-es-ds.yaml

kubectl apply -f infrastructure/kibana-deployment.yaml
kubectl apply -f infrastructure/kibana-service.yaml

kubectl apply -f infrastructure/consul-deployment.yaml
kubectl apply -f infrastructure/consul-service.yaml

kubectl apply -f infrastructure/slurmctld-deployment.yaml
kubectl apply -f infrastructure/slurmctld-service.yaml
kubectl apply -f infrastructure/slurmd-deployment.yaml

kubectl apply -f infrastructure/sshd-configmap.yaml
kubectl apply -f infrastructure/sshd-wrapper-configmap.yaml
kubectl apply -f infrastructure/sshd-deployment.yaml
kubectl apply -f infrastructure/sshd-service.yaml
