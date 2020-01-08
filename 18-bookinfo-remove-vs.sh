#!/bin/bash
set -e

if [[ -z ${BOOKINFO_PROJECT} ]]; then
  BOOKINFO_PROJECT='bookinfo'
fi

oc delete vs details productpage ratings reviews -n $BOOKINFO_PROJECT 