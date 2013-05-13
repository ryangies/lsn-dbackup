#!/bin/bash

bin_dir=/usr/bin
install_dir=/opt/dbackup

script_manifest=(
  dbackup
  dbackup-reaper
  dbackup-reaper-impl.pl
  functions
  sample-backup.sh
  sample-excludes
)

provides=(
  dbackup
  dbackup-reaper
)

if [ "$(id -u)" -ne "0" ]; then
  echo "Only the root user may run these commands."
  exit 1
fi

if [ -z "$bin_dir" ] || [ ! -d "$bin_dir" ]; then
  echo "Binary directory does not exist."
  exit 1
fi
