# dockerfile for parachain package installation

FROM ubuntu

ENV DEBIAN_FRONTEND noninteractive

# substrate config variables
ARG substrate_executable=parachain
ARG substrate_daemon_state=enable
ARG bucket_name={s3_bucket_name}
ARG substrate_release_url=https://github.com/Manta-Network/Manta/releases/download/v3.0.9-1/manta
ARG substrate_chainspec_url=https://raw.githubusercontent.com/Manta-Network/Manta/manta/genesis/calamari-testnet-genesis.json
ARG relay_chainspec_url=https://raw.githubusercontent.com/paritytech/polkadot/master/node/service/res/westend.json

RUN apt -y update

RUN apt -y install python-is-python3 \
    awscli \
    certbot \
    curl \
    jq \
    python3 \
    python3-certbot-nginx \
    python3-pip \
    software-properties-common \
    wget

# Setup envs that are used in below commands
ENV substrate_executable=$substrate_executable
ENV substrate_daemon_state=$substrate_daemon_state
ENV bucket_name=$bucket_name
ENV substrate_release_url=$substrate_release_url
ENV substrate_chainspec_url=$substrate_chainspec_url
ENV relay_chainspec_url=$relay_chainspec_url


# install and configure prometheus,alertmanager and node exporter
RUN wget https://github.com/prometheus/prometheus/releases/download/v2.32.0-rc.0/prometheus-2.32.0-rc.0.linux-amd64.tar.gz && \
    wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz && \
    wget https://github.com/prometheus/alertmanager/releases/download/v0.23.0/alertmanager-0.23.0.linux-amd64.tar.gz  

RUN tar -xvzf prometheus-2.32.0-rc.0.linux-amd64.tar.gz && \
    tar -xvzf node_exporter-1.3.1.linux-amd64.tar.gz && \  
    tar -xvzf alertmanager-0.23.0.linux-amd64.tar.gz && \  
    cp -r alertmanager-0.23.0.linux-amd64/alertmanager /usr/local/bin/  && \
    cp -r node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/  && \ 
    cp -r prometheus-2.32.0-rc.0.linux-amd64/prometheus /usr/local/bin/  
    
RUN mkdir -p /etc/prometheus/  && \
    mkdir -p /etc/alertmanager/

RUN chmod -R +x /etc/prometheus/ && \
    chmod -R +x /etc/alertmanager/

RUN cp -r prometheus-2.32.0-rc.0.linux-amd64/consoles /etc/prometheus/  && \
    cp -r prometheus-2.32.0-rc.0.linux-amd64/console_libraries /etc/prometheus/

# install and configure cloudwatch     
RUN wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb && \
    dpkg -i -E ./amazon-cloudwatch-agent.deb

# install and configure discord.sh
RUN curl -sL -o /usr/local/bin/discord https://raw.githubusercontent.com/ChaoticWeg/discord.sh/59cab0c/discord.sh 
RUN chmod +x /usr/local/bin/discord

# create substrate log, data and config folders
RUN mkdir -p /var/log/${substrate_executable} /var/lib/${substrate_executable} /usr/share/${substrate_executable}

# download relaychain-spec.json (fail quietly if relay_chainspec_url is not set, since fallback is relay_chain)
RUN wget --quiet ${relay_chainspec_url} -O /usr/share/${substrate_executable}/relaychain-spec.json || true

# download parachain-spec.json (fail quietly if substrate_chainspec_url is not set, since fallback is substrate_chain)
RUN wget --quiet ${substrate_chainspec_url} -O /usr/share/${substrate_executable}/${substrate_executable}-parachain-spec.json || true

# download substrate executable
RUN wget --quiet ${substrate_release_url} -O /usr/local/bin/${substrate_executable} 
RUN chmod +x /usr/local/bin/${substrate_executable}