#!/bin/bash -e
# delete all kubernetes resources for spinnaker

kubectl -n spinnaker delete deploy,svc,sts,job,po --force --all
