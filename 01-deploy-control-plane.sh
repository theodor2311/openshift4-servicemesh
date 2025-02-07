#!/bin/bash
set -e

if [[ -z ${ISTIO_PROJECT} ]]; then
  ISTIO_PROJECT='istio-system'
fi

if ! oc get project ${ISTIO_PROJECT} &>/dev/null; then
  echo "Creating istio project: ${ISTIO_PROJECT}"
  oc new-project ${ISTIO_PROJECT} > /dev/null
fi

echo 'Checking subscriptions...'

oc get sub kiali-ossm -n openshift-operators >/dev/null
oc get sub servicemeshoperator -n openshift-operators >/dev/null

echo 'Waiting for opertaors...'

for operator in Kiali servicemesh;do
while [[ $(oc get csv -n ${ISTIO_PROJECT} $(oc get csv -n ${ISTIO_PROJECT} |grep -i $operator | awk '{print $1}') -o jsonpath='{.status.phase}') != 'Succeeded' ]];do
  sleep 1
done
echo $operator installed
done

echo 'Creating Service Mesh Control Plane...'

oc create -f - << EOF
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: basic
  namespace: ${ISTIO_PROJECT}
spec:
  policy:
    type: Istiod
  addons:
    grafana:
      enabled: true
    kiali:
      enabled: true
    prometheus:
      enabled: true
  telemetry:
    type: Istiod
  version: v2.6
EOF

oc apply -f - << EOF
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: ${ISTIO_PROJECT}
spec: {}
EOF

echo 'Waiting for control plane to be ready'
oc wait --for condition=Ready -n ${ISTIO_PROJECT} smcp/basic --timeout 300s
echo '** This is not a production grade control plane setup **'
