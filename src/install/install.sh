#!/bin/bash

source "install/common.sh"

if [ ! -d $install_dir ]; then
  mkdir $install_dir
  chmod u=rwX,g=rX,o=rX $install_dir
fi

for filename in ${script_manifest[@]}; do
  cp -f scripts/$filename $install_dir
  chmod u=rw,g=r,o=r $install_dir/$filename
done

for filename in ${provides[@]}; do
  chmod u+x,g+x,o+x $install_dir/$filename
  ln -s $install_dir/$filename $bin_dir/$filename
done
