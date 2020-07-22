#!/bin/bash
set -e

if [[ -z ${ISTIO_PROJECT} ]]; then
  ISTIO_PROJECT='istio-system'
fi

echo "Create istio project: ${ISTIO_PROJECT}"
oc new-project ${ISTIO_PROJECT} > /dev/null

echo 'Checking subscriptions...'

oc get sub jaeger-product -n openshift-operators >/dev/null
oc get sub kiali-ossm -n openshift-operators >/dev/null
oc get sub servicemeshoperator -n openshift-operators >/dev/null


echo 'Waiting for opertaors...'

for operator in jaeger-product kiali-ossm servicemeshoperator;do
while [[ $(oc get csv $(oc get packagemanifest $operator -n openshift-marketplace -o jsonpath='{.status.channels[].currentCSV}') -o jsonpath='{.status.phase}' 2>/dev/null) != 'Succeeded' ]];do
  sleep 1
done
echo $operator installed
done

echo 'Create Service Mesh Control Plane...'

oc create -f - << EOF
apiVersion: maistra.io/v1
kind: ServiceMeshControlPlane
metadata:
  name: basic-install
  namespace: ${ISTIO_PROJECT}
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

oc create -f - << EOF
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: ${ISTIO_PROJECT}
spec: {}
EOF

echo '** This is not a production grade control plane setup **'
echo "Use 'watch oc get pods -n ${ISTIO_PROJECT}' to watch the istio resources to be created"
