#!/bin/bash

get_date_now=$(date '+%Y-%m-%d')
get_dirs=$(ls -lrtd /local/ci/jenkins/workspace/* --full-time | grep -v "Temp$\|clean_old.sh$" | grep -v "$get_date_now" | awk '{print$9}')

for f in `echo $get_dirs`; do
    echo -e "Removing... " $f
    rm -rf $f
done

find /local/ci/jenkins/workspace/* -type d -mtime +1 -exec rm -rf "{}" \; 2>&1>> /dev/null

echo -e "DONE . . ."
