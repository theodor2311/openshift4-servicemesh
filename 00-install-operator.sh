#!/bin/bash
set -e

echo "Creating subscriptions..."

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

oc create -f - << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-operators
spec:
  channel: "$(oc get packagemanifest jaeger-product -n openshift-marketplace -o jsonpath='{.status.defaultChannel}')"
  installPlanApproval: Automatic
  name: jaeger-product
  source: "$(oc get packagemanifest jaeger-product -n openshift-marketplace -o jsonpath='{.status.catalogSource}')"
  sourceNamespace: "$(oc get packagemanifest jaeger-product -n openshift-marketplace -o jsonpath='{.status.catalogSourceNamespace}')"
EOF

oc create -f - << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators
spec:
  channel: "$(oc get packagemanifest kiali-ossm -n openshift-marketplace -o jsonpath='{.status.defaultChannel}')"
  installPlanApproval: Automatic
  name: kiali-ossm
  source: "$(oc get packagemanifest kiali-ossm -n openshift-marketplace -o jsonpath='{.status.catalogSource}')"
  sourceNamespace: "$(oc get packagemanifest kiali-ossm -n openshift-marketplace -o jsonpath='{.status.catalogSourceNamespace}')"
EOF

oc create -f - << EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: "$(oc get packagemanifest servicemeshoperator -n openshift-marketplace -o jsonpath='{.status.defaultChannel}')"
  installPlanApproval: Automatic
  name: servicemeshoperator
  source: "$(oc get packagemanifest servicemeshoperator -n openshift-marketplace -o jsonpath='{.status.catalogSource}')"
  sourceNamespace: "$(oc get packagemanifest servicemeshoperator -n openshift-marketplace -o jsonpath='{.status.catalogSourceNamespace}')"
EOF
