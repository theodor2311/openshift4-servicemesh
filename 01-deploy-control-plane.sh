#!/bin/bash
set -e

if [[ -z ${ISTIO_PROJECT} ]]; then
  ISTIO_PROJECT='istio-system'
fi

if oc get project ${ISTIO_PROJECT} &>/dev/null; then
  echo "Creating istio project: ${ISTIO_PROJECT}"
  oc new-project ${ISTIO_PROJECT} > /dev/null
fi

echo 'Checking subscriptions...'

oc get sub jaeger-product -n openshift-operators >/dev/null
oc get sub kiali-ossm -n openshift-operators >/dev/null
oc get sub servicemeshoperator -n openshift-operators >/dev/null

echo 'Waiting for opertaors...'

for operator in Elasticsearch Jaeger Kiali servicemesh;do
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
  version: v2.1
  tracing:
    type: Jaeger
    sampling: 10000
  addons:
    jaeger:
      name: jaeger
      install:
        storage:
          type: Memory
    kiali:
      enabled: true
      name: kiali
    grafana:
      enabled: true
EOF

oc apply -f - << EOF
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: ${ISTIO_PROJECT}
spec: {}
EOF

echo '** This is not a production grade control plane setup **'
echo "Use 'watch oc get pods -n ${ISTIO_PROJECT}' to watch the istio resources to be created"
