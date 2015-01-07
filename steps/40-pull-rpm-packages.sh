#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

source "${SCALR_REPOCONFIG_CONF}"

remote_base="${REMOTE_REPO_ROOT}/rpm"

for repo in ${CLONE_REPOS}; do
  remote_repo_base="${remote_base}/${repo}/rhel"

  # Until February 2015, stable is still on builbot!
  if [ "${repo}" = "stable" ]; then
    remote_repo_base="http://rpm-delayed.scalr.net/rpm/rhel/"
  fi

  for ver in ${RHEL_VERSIONS}; do
    for arch in x86_64 i386; do
      cd "${LOCAL_REPO_ROOT}/${repo}/rpm/rhel/${ver}/${arch}"
      echo "## mirroring $ver/$arch"
      wget ${WGET_OPTS} --accept "*.rpm" "${remote_repo_base}/${ver}/${arch}/"
      createrepo .
    done
  done
done
