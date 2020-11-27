#!/bin/bash
set -e

# Reference: https://istio.io/downloadIstio

cd /dev/shm

OSEXT="linux"
ISTIO_ARCH="amd64"

if [ "x${ISTIO_VERSION}" = "x" ] ; then
  ISTIO_VERSION=$(curl -L -s https://api.github.com/repos/istio/istio/releases | \
                  grep tag_name | sed "s/ *\"tag_name\": *\"\\(.*\\)\",*/\\1/" | \
		  grep -v -E "(alpha|beta|rc)\.[0-9]$" | sort -t"." -k 1,1 -k 2,2 -k 3,3 -k 4,4 | tail -n 1)
fi

if [ "x${ISTIO_VERSION}" = "x" ] ; then
  printf "Unable to get latest Istio version. Set ISTIO_VERSION env var and re-run. For example: export ISTIO_VERSION=1.0.4"
  exit;
fi

NAME="istio-$ISTIO_VERSION"
URL="https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istio-${ISTIO_VERSION}-${OSEXT}-${ISTIO_ARCH}.tar.gz"
printf "Downloading %s from %s ...\n" "$NAME" "$URL"
curl -s -L "$URL" | tar xz

mv $NAME/bin/istioctl /usr/bin
mv $NAME/tools/istioctl.bash /etc/bash_completion.d

rm -rf $NAME

printf "istioctl installed\n"
