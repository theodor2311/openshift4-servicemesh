#!/bin/bash
set -e

if [[ -z ${BOOKINFO_PROJECT} ]]; then
  BOOKINFO_PROJECT='bookinfo'
fi

if [[ -z ${ISTIO_RELEASE} ]]; then
  ISTIO_RELEASE=$(curl --silent https://api.github.com/repos/istio/istio/releases/latest |grep -Po '"tag_name": "\K.*?(?=")')
fi

# Clean up dr, gw and vs
oc delete dr,gw,vs --all -n $BOOKINFO_PROJECT >/dev/null 2>&1

# Apply Default Gateway
oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/bookinfo-gateway.yaml
# Apply Default DR
oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/destination-rule-all.yaml

oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/virtual-service-all-v1.yaml
oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml

if [[ -z ${GATEWAY_URL} ]]; then
  GATEWAY_URL="http://$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')"
fi
printf """Instructions:
URL: $GATEWAY_URL/productpage.
On the /productpage of the Bookinfo app, log in as user jason without the password.
The star ratings appear next to each review.
"""