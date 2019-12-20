#!/bin/bash
oc new-project istio-system

for operator in elasticsearch-operator jaeger-product kiali-ossm servicemeshoperator;do
while [[ $(oc get csv $(oc get packagemanifest $operator -n openshift-marketplace -o jsonpath='{.status.channels[].currentCSV}') -o jsonpath='{.status.reason}' 2>/dev/null) != 'Copied' ]];do
  sleep 1
done
echo $operator installed
done

oc create -f - << EOF
apiVersion: maistra.io/v1
kind: ServiceMeshControlPlane
metadata:
  name: basic-install
  namespace: istio-system
spec:
  istio:
    global:
      proxy:
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 128Mi
    gateways:
      istio-egressgateway:
        autoscaleEnabled: false
      istio-ingressgateway:
        autoscaleEnabled: false
    mixer:
      policy:
        autoscaleEnabled: false
      telemetry:
        autoscaleEnabled: false
        resources:
          requests:
            cpu: 100m
            memory: 1G
          limits:
            cpu: 500m
            memory: 4G
    pilot:
      autoscaleEnabled: false
      traceSampling: 100
    kiali:
      enabled: true
    grafana:
      enabled: true
    tracing:
      enabled: true
      jaeger:
        template: all-in-one
EOF

oc get pods -n istio-system -w
