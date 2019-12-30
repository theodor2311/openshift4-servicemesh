#!/bin/bash
set -e

if [[ -z ${BOOKINFO_PROJECT} ]]; then
  BOOKINFO_PROJECT='bookinfo'
fi

ISTIO_RELEASE=$(curl --silent https://api.github.com/repos/istio/istio/releases/latest |grep -Po '"tag_name": "\K.*?(?=")')

oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/virtual-service-all-v1.yaml

GATEWAY_URL=$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')

printf """Open the Bookinfo site in your browser. The URL is http://$GATEWAY_URL/productpage.\n
Notice that the reviews part of the page displays with no rating stars, no matter how many times you refresh. This is because you configured Istio to route all traffic for the reviews service to the version reviews:v1 and this version of the service does not access the star ratings service.
"""