#!/bin/bash -l

set -e


CURRENT_PIPELINE_LOCATOR=$1 # Example :- http://goserver.com:8153/go/files/foo/1243/UATest/1/UAT

[ -d artifacts ] || mkdir artifacts
[ -d test_artifacts ] || mkdir test_artifacts

rm -rf tmp_artifacts
mkdir tmp_artifacts

if [ -f .artifacts_fetched_from_upstream ]; then
    for upstream_artifacts in `cat .artifacts_fetched_from_upstream`
    do
        rm -rf $upstream_artifacts
    done
fi

zip -r artifacts.zip artifacts
zip -r test_artifacts.zip test_artifacts

echo -e "Uploading artifacts to $CURRENT_PIPELINE_LOCATOR \n"
curl -H "Confirm: true" -u artifacts-propagator:Helpdesk -F zipfile=@artifacts.zip $CURRENT_PIPELINE_LOCATOR
curl -H "Confirm: true" -u artifacts-propagator:Helpdesk -F zipfile=@test_artifacts.zip $CURRENT_PIPELINE_LOCATOR
echo -e "\n Warming up the artifact cache for downstream pipelines \n"
curl -H "Confirm: true" -u artifacts-propagator:Helpdesk $CURRENT_PIPELINE_LOCATOR/artifacts.zip