#!/bin/bash

bank=/var/backup
user=root
host=example.com
excludes=/opt/dbackup/sample-excludes
keep_daily=30
keep_monthly=12

list1=(
  /etc
  /var/www
)

list2=(
  /home
)

case "$1" in

  normal)
    dirlist=(
      ${list1[@]}
    )
    shift
    ;;

  full)
    dirlist=(
      ${list1[@]}
      ${list2[@]}
    )
    shift
    ;;

  *)
    echo "usage: $0 {normal|full} [options]"
    exit 1

esac

for dir in ${dirlist[@]}; do
  dbackup "$user@$host:$dir" "$bank" $@ --exclude-from $excludes
  dbackup-reaper "$user@$host:$dir" "$bank" --daily $keep_daily --monthly $keep_monthly $@
done
