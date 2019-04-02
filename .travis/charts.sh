#!/bin/bash

set -e

#
# Publishes Helm charts.
#
# $1 - The charts URL.
#
# Examples:
#
#   publish "https://moikot.github.io/helm-charts"
#
publish() {
  readonly url="${1}"

  mkdir -p ./public
  printf "User-Agent: *\nDisallow: /\n" > ./public/robots.txt

  docker run -it --rm -v $(pwd):/repo --entrypoint /bin/sh linkyard/docker-helm \
  -c "helm init --client-only && helm package /repo/charts/* --destination /repo/public && cd /repo/public && helm repo index --url ${url} ."
#  helm init --client-only
#  helm package charts/* --destination ./public
#  cd ./public
#  helm repo index --url "${url}" .
}

"$@"
