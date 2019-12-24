#!/bin/bash
set -e

oc get sub elasticsearch-operator -n openshift-operators >/dev/null
oc get sub jaeger-product -n openshift-operators >/dev/null
oc get sub kiali-ossm -n openshift-operators >/dev/null
oc get sub servicemeshoperator -n openshift-operators >/dev/null

oc delete sub elasticsearch-operator -n openshift-operators
oc delete sub jaeger-product -n openshift-operators
oc delete sub kiali-ossm -n openshift-operators
oc delete sub servicemeshoperator -n openshift-operators
