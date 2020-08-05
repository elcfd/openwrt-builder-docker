#!/bin/bash -e

DOCKERHUB_USERNAME="elcfd"
REPOSITORY="openwrt-builder"

usage()
{
    echo "Incorrect args - must specify build or release"
    echo -e "\n   ./image_creator.sh <action>"
    exit 1
}

[[ $# -eq 1 ]] || usage

# args: 
    # image tag
build()
{
    docker build -t "$1:latest" .
}

# args: 
    # image tag
release()
{
    docker image push "$1:latest"
    datestamp_tag="$1:$(date +"%Y_%m_%d-%H_%M_%S")"
    docker tag "$1:latest" "$datestamp_tag"
    docker image push "$datestamp_tag"
}

action=$1

if [[ "$action" == "build" ]]
then
    build "$DOCKERHUB_USERNAME/$REPOSITORY"
elif [[ "$action" == "release" ]]
then
    release "$DOCKERHUB_USERNAME/$REPOSITORY"
else
    usage
fi
