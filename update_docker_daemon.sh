#!/bin/sh

if [ $(id -u) -ne 0 ]; then
  echo "this script must be run as root or with sudo"
  exit 1
fi

if [ -z ${DOCKER_PORT} ]; then
  DOCKER_PORT=4243
fi

# make dockerd listen on port ${DOCKER_PORT} to allow remote connections
sed -i -E "s|^ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock|ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:${DOCKER_PORT} -H unix:///var/run/docker.sock|" /lib/systemd/system/docker.service

# restart the docker daemon
systemctl daemon-reload
service docker restart
