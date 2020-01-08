#!/bin/bash
set -e

if [[ -z ${BOOKINFO_PROJECT} ]]; then
  BOOKINFO_PROJECT='bookinfo'
fi

oc delete policy default -n $BOOKINFO_PROJECT 