#!/bin/bash
set -e

if [[ -z ${BOOKINFO_PROJECT} ]]; then
  BOOKINFO_PROJECT='bookinfo'
fi

if [[ -z ${ISTIO_RELEASE} ]]; then
  ISTIO_RELEASE=$(curl --silent https://api.github.com/repos/istio/istio/releases/latest |grep -Po '"tag_name": "\K.*?(?=")')
fi

# Clean up dr, gw and vs
oc delete dr,gw,vs --all -n $BOOKINFO_PROJECT >/dev/null

# Apply Default Gateway
oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/bookinfo-gateway.yaml >/dev/null
# Apply Default DR
oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/destination-rule-all.yaml >/dev/null

oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/virtual-service-all-v1.yaml >/dev/null
oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/virtual-service-reviews-test-v2.yaml >/dev/null
oc apply -n $BOOKINFO_PROJECT -f https://raw.githubusercontent.com/istio/istio/${ISTIO_RELEASE}/samples/bookinfo/networking/virtual-service-ratings-test-delay.yaml >/dev/null

if [[ -z ${GATEWAY_URL} ]]; then
  GATEWAY_URL="http://$(oc -n istio-system get route istio-ingressgateway -o jsonpath='{.spec.host}')"
fi

printf """Instructions:
URL: $GATEWAY_URL/productpage
1. Open the Bookinfo web application in your browser with above URL.
2. On the /productpage web page, log in as user jason.
   You expect the Bookinfo home page to load without errors in approximately 7 seconds. However, there is a problem, the Reviews section displays an error message: \"Sorry, product reviews are currently unavailable for this book.\"
3. View the web page response times:
    1. Open the Developer Tools menu in you web browser.
    2. Open the Network tab
    3. Reload the /productpage web page. You will see that the page actually loads in about 6 seconds.
"""
