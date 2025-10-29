FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ARG USERNAME=devops
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update &&     apt-get install -y --no-install-recommends       ca-certificates curl wget jq git unzip vim       apt-transport-https gnupg lsb-release iproute2 dnsutils       openssh-server sudo supervisor &&     rm -rf /var/lib/apt/lists/*

RUN groupadd --gid ${USER_GID} ${USERNAME} &&     useradd  --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} &&     echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

RUN mkdir -p /var/run/sshd &&     sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config &&     sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config &&     sed -i 's@^#\?AuthorizedKeysFile.*@AuthorizedKeysFile %h/.ssh/authorized_keys@' /etc/ssh/sshd_config &&     echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config &&     echo "ClientAliveCountMax 3" >> /etc/ssh/sshd_config
EXPOSE 22

RUN apt-get update &&     apt-get install -y --no-install-recommends       libicu70 libkrb5-3 zlib1g libssl3 libcurl4 libunwind8 gettext &&     rm -rf /var/lib/apt/lists/*

RUN mkdir -p /azp && chown ${USERNAME}:${USERNAME} /azp

COPY start.sh /start.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /start.sh && chown ${USERNAME}:${USERNAME} /start.sh

WORKDIR /azp
CMD ["/usr/bin/supervisord", "-n"]
