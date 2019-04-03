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
  readonly user="${1}"
  readonly repo="${2}"

  readonly url="https://${user}.github.io/${repo}"

  mkdir -p ./public
  printf "User-Agent: *\nDisallow: /\n" > ./public/robots.txt

  docker run -it --rm -v $(pwd):/repo --entrypoint /bin/sh linkyard/docker-helm \
  -c "helm init --client-only && helm package /repo/charts/* --destination /repo/public && cd /repo/public && helm repo index --url ${url} ."
}

push() {
  readonly user="${1}"
  readonly repo="${2}"
  readonly email="${3}"
  readonly name="${4}"
  readonly token="${5}"

  git config user.email ${email}
  git config user.name ${name}

  readonly url="https://${user}:${token}@github.com/${user}/${repo}.git"

  git remote set-url origin ${url}

  # Switch to the master branch.
  readonly head=$(git symbolic-ref HEAD)
  if [[ "${head}" != "refs/heads/master" ]]; then
    git checkout master
  fi

  # Recreate gh-pages if it exists.
  set +e
  git branch -D gh-pages > /dev/null 2>&1
  git branch -d -r origin/gh-pages > /dev/null 2>&1
  set -e
  
  git checkout -b gh-pages

  mv ./public/* .
  git add .

  git commit -m "Publish Helm chart"
  git remote set-url --push origin "${url}"
  git push origin gh-pages --force > /dev/null 2>&1
}

"$@"
