#!/bin/bash

set -e

#
# Publishes Helm charts.
#
# $1 - The Git user.
# $2 - The Git repository.
#
# Examples:
#
#   publish "moikot" "helm-charts"
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

#
# Publishes Helm charts to Git pages.
#
# $1 - The Git user.
# $2 - The Git repository.
# $3 - The Git user's e-mail.
# $4 - The Git user's name.
# $5 - The access token.
#
# Examples:
#
#   publish "moikot" "helm-charts" "admin@moikot.com" "Moikot" "AD123FT"
#
push() {
  readonly user="${1}"
  readonly repo="${2}"
  readonly email="${3}"
  readonly name="${4}"
  readonly token="${5}"

  git config user.email ${email}
  git config user.name ${name}

  # Recreate gh-pages if it exists.
  set +e
  git branch -D gh-pages > /dev/null 2>&1
  git branch -d -r origin/gh-pages > /dev/null 2>&1
  set -e

  git checkout -b gh-pages

  mv ./public/* .
  git add .

  git commit --message "Publish Helm chart"

  readonly url="https://${user}:${token}@github.com/${user}/${repo}.git"
  git remote add origin-pages "${url}" > /dev/null 2>&1
  git push --quiet --set-upstream origin-pages gh-pages --force > /dev/null 2>&1
}

"$@"
