#!/bin/bash
set -e

if [[ -z ${BOOKINFO_PROJECT} ]]; then
  BOOKINFO_PROJECT='bookinfo'
fi

ISTIO_RELEASE=$(curl --silent https://api.github.com/repos/istio/istio/releases/latest |grep -Po '"tag_name": "\K.*?(?=")')

grep BOOKINFO_PROJECT $HOME/.bashrc || echo "export BOOKINFO_PROJECT=$BOOKINFO_PROJECT" >> $HOME/.bashrc
grep ISTIO_RELEASE $HOME/.bashrc || echo "export ISTIO_RELEASE=$ISTIO_RELEASE" >> $HOME/.bashrc

oc new-project $BOOKINFO_PROJECT >/dev/null

oc get smmr default -n istio-system -o json --export | jq '.spec.members += ["'"$BOOKINFO_PROJECT"'"]' | oc apply -n istio-system -f -

oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/platform/kube/bookinfo.yaml

for deployment in $(oc get deployments -o jsonpath='{.items[*].metadata.name}' -n $BOOKINFO_PROJECT);do
oc -n $BOOKINFO_PROJECT patch deployment $deployment -p '{"spec":{"template":{"metadata":{"annotations":{"sidecar.istio.io/inject": "true"}}}}}'
done

oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/bookinfo-gateway.yaml

export GATEWAY_URL=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')
grep -q GATEWAY_URL $HOME/.bashrc || echo "export GATEWAY_URL=$GATEWAY_URL" >> ~/.bashrc
