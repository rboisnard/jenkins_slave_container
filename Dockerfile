#syntax=docker/dockerfile:1.2
ARG alpine_version=3.14

FROM alpine:${alpine_version}

ARG docker_group_id
ARG jenkins_user_id
ARG jenkins_group_id

ARG java_version=openjdk11

RUN  apk update     \
  && apk add        \
    bash            \
    curl            \
    docker          \
    docker-compose  \
    git             \
    less            \
    ${java_version} \
    openssh         \
    openssh-server  \
    shadow          \
    wget            \
  && mkdir -p /var/jenkins_home/.ssh            \
  && groupmod -g ${docker_group_id} docker      \
  && groupadd -g ${jenkins_group_id} jenkins    \
  && useradd -u ${jenkins_user_id} -g ${jenkins_group_id} -M -d /var/jenkins_home -s /bin/bash jenkins \
  && usermod -aG docker jenkins                 \
  && echo "jenkins:jenkins" | chpasswd          \
  && chown -R jenkins:jenkins /var/jenkins_home \
  && chmod 700 /var/jenkins_home/.ssh           \
  && ssh-keygen -A                              \
  && sed -i "s/#HostKey/HostKey/" /etc/ssh/sshd_config \
  && /usr/sbin/sshd

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
