#!/bin/sh

usage() {
  echo "Usage: $0 -d <docker_group_id> -g <jenkins_group_id> -u <jenkins_user_id> [-i <image name>] [-t <image tag>] [-b]" 1>&2;
  exit 1;
}

# default values
DOCKER_BUILDKIT=
image_name=jenkins_slave_container
image_tag=staging

while getopts ":d:g:u:i:t:b" option; do
  case "${option}" in
    d)
      docker_group_id=${OPTARG}
      ;;
    g)
      jenkins_group_id=${OPTARG}
      ;;
    u)
      jenkins_user_id=${OPTARG}
      ;;
    i)
      image_name=${OPTARG}
      ;;
    t)
      image_tag=${OPTARG}
      ;;
    b)
      DOCKER_BUILDKIT=1
      ;;
  esac
done

if [ -z ${docker_group_id} ]; then
  echo "Var 'docker_group_id' needs to be set to the host's docker group id"
  usage
fi

if [ -z ${jenkins_group_id} ]; then
  echo "Var 'jenkins_group_id' needs to be set to the host's user group id"
  usage
fi

if [ -z ${jenkins_user_id} ]; then
  echo "Var 'jenkins_user_id' needs to be set to the host's user id"
  usage
fi

status=1
arch=$(uname -m)

case ${arch} in
  x86_64|aarch64)
    DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker build     \
      -t ${image_name}:${image_tag}                     \
      --build-arg alpine_version=3.14                   \
      --build-arg java_version=openjdk11                \
      --build-arg docker_group_id=${docker_group_id}    \
      --build-arg jenkins_group_id=${jenkins_group_id}  \
      --build-arg jenkins_user_id=${jenkins_user_id}    \
      .
      status=$?
    ;;
  armv7l)
    DOCKER_BUILDKIT=${DOCKER_BUILDKIT} docker build     \
      -t ${image_name}:${image_tag}                     \
      --build-arg alpine_version=3.12                   \
      --build-arg java_version=openjdk8                 \
      --build-arg docker_group_id=${docker_group_id}    \
      --build-arg jenkins_group_id=${jenkins_group_id}  \
      --build-arg jenkins_user_id=${jenkins_user_id}    \
      .
      status=$?
    ;;
  *)
    echo "unknown arch ${arch}"
    exit 1
esac

if [ ${status} -ne 0 ]; then
  echo "build failed for arch ${arch} with status ${status}"
fi