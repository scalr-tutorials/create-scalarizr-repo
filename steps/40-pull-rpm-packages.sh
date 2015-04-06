#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail

source "${SCALR_REPOCONFIG_CONF}"

for repo in ${CLONE_REPOS}; do
  echo "Cloning repo '$repo'"

  current_repo_root="${LOCAL_REPO_ROOT}/${repo}/rpm/rhel"
  # Mirror a single copy of EL5 packages and create aliases
  for arch in x86_64 i386; do
    cd "${current_repo_root}/latest/${arch}"
    wget_mirror "${REMOTE_REPO_ROOT}/rpm/${repo}/rhel/latest/${arch}/"
  done
  
  cd ${current_repo_root}
  for alias in ${RHEL_5_ALIASES} ${RHEL_6_ALIASES} ${RHEL_7_ALIASES}; do
    ln -s latest ${alias}
  done
done
