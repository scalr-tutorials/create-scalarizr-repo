#!/bin/bash
#set -o errexit
set -o nounset
set -o pipefail

source "${SCALR_REPOCONFIG_CONF}"

remote_base="${REMOTE_REPO_ROOT}/apt-plain"
extra_wget_opts=("--accept" "*.deb")

for repo in ${CLONE_REPOS}; do
  local_apt_repo="${LOCAL_REPO_ROOT}/${repo}/apt"
  new_style_repo=false

  echo "Checking for new style apt repository"
  $(wget -q  ${remote_base}/${repo}/${APT_BASE_VER}/)
  if [[ $? != 0 ]] ; then
    echo "Using old style apt repository"
    remote_repo="${remote_base}/${repo}/"
    base_apt_repo="${local_apt_repo}"
  else
    echo "Using new style apt repository"
    remote_repo="${remote_base}/${repo}/${APT_BASE_VER}"
    base_apt_repo="${local_apt_repo}/${APT_BASE_VER}"
    new_style_repo=true
  fi

  echo "Cloning repo '$repo' ..."

  # Navigate to the appropriate repository
  mkdir -p ${base_apt_repo}
  cd ${base_apt_repo}

  # Pull latest packages from Scalr
  wget "${WGET_OPTS[@]}" "${extra_wget_opts[@]}" "${remote_repo}"

  # Create a release file
  cat > Release << EOC
Origin: ${ORG_NAME}
Label: scalr
Suite: scalr
Codename: scalr
Architectures: all i386 amd64
Description: Scalr packages
EOC

  # Update Packages index
  dpkg-scanpackages -m . > Packages
  dpkg-scansources . > Sources
  cat Packages | gzip -9c > Packages.gz
  cat Sources | gzip -9c > Sources.gz

  if [[ $new_style_repo == true ]] ; then
    echo "creating Ubuntu symlinks"
    for ubuntu_ver in ${UBUNTU_VERS}; do
      ln -sf ${base_apt_repo} ${local_apt_repo}/ubuntu/${ubuntu_ver}
    done

    echo "creating Debian symlinks"
    mkdir -p ${local_apt_repo}/debian
    for debian_ver in ${DEBIAN_VERS}; do
      ln -sf ${base_apt_repo} ${local_apt_repo}/debian/${debian_ver}
    done

    echo "Creating symlinks to the root directory"
    ln -s ${base_apt_repo}/* ${local_apt_repo}
  fi

done
