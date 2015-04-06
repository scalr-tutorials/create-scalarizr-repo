#!/bin/bash
set -o errexit
set -o nounset
set -o pipefail


# Install dependencies

if which apt-get; then
  echo "Found apt-get"
  apt-get update
  apt-get install -q -y nginx dpkg-dev wget
elif which yum; then
  echo "Found yum"

  # Check the repos we need are installed
  yum repolist | grep epel || {
    echo "The EPEL repo must be enabled (nginx). Please enable it. View: https://fedoraproject.org/wiki/EPEL"
  }

  yum repolist | grep nux-dextop || {
    echo "The nux-dextop repo must be enabled (dpkg-dev). Please enable it. View: http://li.nux.ro/repos.html"
  }

  for pkg in "nginx" "wget"; do
    yum install -y "${pkg}"
  done

  yum install -y "dpkg-devel"
  yum install -y "dpkg-dev" || true  # on CentOS 6, this is in dpkg-devel

else
  echo "No known package manager found (tried apt-get, yum)."
  exit 1
fi
