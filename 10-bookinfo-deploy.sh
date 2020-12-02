#!/bin/bash
set -e

source $HOME/.bashrc

if [[ -z ${BOOKINFO_PROJECT} ]]; then
  BOOKINFO_PROJECT='bookinfo'
fi

if [[ -z ${ISTIO_RELEASE} ]]; then
  ISTIO_RELEASE=$(curl --silent https://api.github.com/repos/istio/istio/releases/latest |grep -Po '"tag_name": "\K.*?(?=")')
fi

grep -q BOOKINFO_PROJECT $HOME/.bashrc || echo "export BOOKINFO_PROJECT=$BOOKINFO_PROJECT" >> $HOME/.bashrc
grep -q ISTIO_RELEASE $HOME/.bashrc || echo "export ISTIO_RELEASE=$ISTIO_RELEASE" >> $HOME/.bashrc

echo "Creating project for bookinfo..."
oc new-project $BOOKINFO_PROJECT >/dev/null


cat <<EOF | oc create -f -
apiVersion: maistra.io/v1
kind: ServiceMeshMember
metadata:
  name: default
spec:
  controlPlaneRef:
    namespace: istio-system
    name: basic
EOF


oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/platform/kube/bookinfo.yaml

for deployment in $(oc get deployments -o jsonpath='{.items[*].metadata.name}' -n $BOOKINFO_PROJECT);do
oc -n $BOOKINFO_PROJECT patch deployment $deployment -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}'
done

oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/bookinfo-gateway.yaml

export GATEWAY_URL="http://$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')"
grep -q GATEWAY_URL $HOME/.bashrc || echo "export GATEWAY_URL=$GATEWAY_URL" >> ~/.bashrc

printf "You may now access the bookinfo application from:\n%s/productpage\n" "$GATEWAY_URL"
