#!/bin/bash
set -e

echo "Installing Operators..."

for OPERATOR in "kiali-ossm" "servicemeshoperator"
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
