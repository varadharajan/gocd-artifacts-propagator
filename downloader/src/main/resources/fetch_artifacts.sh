#!/bin/bash

set -e

# Steps:
# 1. Find out the materials for current stream
# 2. mkdir artifacts and pull *all artifacts* in this folder

rm -rf artifacts
mkdir -p artifacts/pipelines
rm -rf test_artifacts
mkdir test_artifacts

# What kind of API optimization is this? Return 202 and ask client to hit the same url again after sometime?
function try_url
{
    url=$1
    while [ `curl -H "Confirm: true" -u artifacts-propagator:Helpdesk $url -w '%{response_code}' -so /dev/null` -eq 202 ]
    do
        echo -e "GO just became lazy and returned 202. Retrying to fetch artifacts \n"
        sleep 2
    done
}
export -f try_url

function get_artifact
{
    url=$1
    pid=$BASHPID
    echo -e "Pulling artifacts from $url PID: $pid \n"
    try_url $url
    curl -H "Confirm: true" -u artifacts-propagator:Helpdesk "$url" > /dev/shm/$pid.zip
    [ $? -eq  0 ] && unzip -o /dev/shm/$pid.zip
    rm -rf /dev/shm/$pid.zip
}
export -f get_artifact

cat .artifacts_to_be_fetched | parallel -j 8 --gnu get_artifact {}

[ "$(ls -A artifacts)" ] && ls -1 artifacts/* > .artifacts_fetched_from_upstream
echo -e "All upstream artifacts downloaded into WORKDIR/artifacts folder \n"
