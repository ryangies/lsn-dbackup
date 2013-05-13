#!/bin/bash

source "install/common.sh"

if [ -z "$install_dir" ] || [ ! -d "$install_dir" ]; then
  echo "Install directory does not exist."
  exit 1
fi

for filename in ${script_manifest[@]}; do
  rm -i "$install_dir/$filename"
done

for filename in ${provides[@]}; do
  rm -i "$bin_dir/$filename"
done

rmdir $install_dir
