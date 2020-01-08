#!/bin/bash
set -e

if [[ -z ${BOOKINFO_PROJECT} ]]; then
  BOOKINFO_PROJECT='bookinfo'
fi

ISTIO_RELEASE=$(curl --silent https://api.github.com/repos/istio/istio/releases/latest |grep -Po '"tag_name": "\K.*?(?=")')

oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/virtual-service-all-v1.yaml
oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml
oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml

if [[ -z ${GATEWAY_URL} ]]; then
  GATEWAY_URL="http://$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')"
fi

# printf """On the /productpage of the Bookinfo app, log in as user jason.\n
# URL: $GATEWAY_URL/productpage.\n
# The star ratings appear next to each review.
# """

echo "URL: $GATEWAY_URL/productpage."

#v2 timeout is 2.5s
#Login with Jason and test, should be failed
#Check developer tools network tab