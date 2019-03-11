#!/bin/bash

REPO=243982910378.dkr.ecr.ap-southeast-1.amazonaws.com/kms
VERSION=latest

$(aws ecr get-login --no-include-email --region ap-southeast-1)

cp -R ../../cmd ../../pkg ./

docker build -t $REPO:$VERSION .

docker push $REPO:$VERSION

rm -rf cmd/ pkg/