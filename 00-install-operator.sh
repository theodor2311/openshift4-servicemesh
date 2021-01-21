#!/bin/bash
set -e

echo "Installing Operators..."

if ! oc get sub elasticsearch-operator -n openshift-operators-redhat >/dev/null 2>&1
then
if ! oc get project openshift-operators-redhat >/dev/null 2>&1
then
cat <<EOF | oc create -f -
apiVersion: v1
kind: Namespace
metadata:
  annotations:
    openshift.io/node-selector: ""
  labels:
    openshift.io/cluster-monitoring: "true"
  name: openshift-operators-redhat
EOF
fi
oc create -f - << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators-redhat
spec:
  channel: "$(oc get packagemanifest elasticsearch-operator -n openshift-marketplace -o jsonpath='{.status.defaultChannel}')"
  installPlanApproval: Automatic
  name: elasticsearch-operator
  source: "$(oc get packagemanifest elasticsearch-operator -n openshift-marketplace -o jsonpath='{.status.catalogSource}')"
  sourceNamespace: "$(oc get packagemanifest elasticsearch-operator -n openshift-marketplace -o jsonpath='{.status.catalogSourceNamespace}')"
EOF
else
  echo "elasticsearch-operator installed already."
fi


for OPERATOR in "jaeger-product" "kiali-ossm" "servicemeshoperator"
do
if ! oc get sub ${OPERATOR} -n openshift-operators >/dev/null 2>&1
then
oc create -f - << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ${OPERATOR}
  namespace: openshift-operators
spec:
  channel: "$(oc get packagemanifest ${OPERATOR} -n openshift-marketplace -o jsonpath='{.status.defaultChannel}')"
  installPlanApproval: Automatic
  name: ${OPERATOR}
  source: "$(oc get packagemanifest ${OPERATOR} -n openshift-marketplace -o jsonpath='{.status.catalogSource}')"
  sourceNamespace: "$(oc get packagemanifest ${OPERATOR} -n openshift-marketplace -o jsonpath='{.status.catalogSourceNamespace}')"
EOF
else
  echo "${OPERATOR} installed already."
fi
done

echo "Operators installation finished."
