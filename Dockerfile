FROM ubuntu:20.04

RUN apt -y update
RUN apt -y install wget 

COPY bash.sh ./
RUN chmod +x bash.sh

ARG PROMETHEUS_PORT=9090
ARG NODE_EXPORTER_PORT=9100
ARG ALERTMANAGER_PORT=9093

ENV PROMETHEUS_PORT=$PROMETHEUS_PORT
ENV NODE_EXPORTER_PORT=$NODE_EXPORTER_PORT
ENV ALERTMANAGER_PORT=$ALERTMANAGER_PORT
 
EXPOSE $PROMETHEUS_PORT
EXPOSE $NODE_EXPORTER_PORT
EXPOSE $ALERTMANAGER_PORT

# install prometheus and configure
RUN wget --quiet https://github.com/prometheus/prometheus/releases/download/v2.32.0-rc.0/prometheus-2.32.0-rc.0.linux-amd64.tar.gz 
RUN tar -xvf prometheus-2.32.0-rc.0.linux-amd64.tar.gz 
RUN cp -r prometheus-2.32.0-rc.0.linux-amd64/prometheus /usr/local/bin/ 
RUN mkdir -p /etc/prometheus/ 
#RUN cp -r prometheus-2.32.0-rc.0.linux-amd64/prometheus.yml /etc/prometheus/
COPY prometheus.yml /etc/prometheus/
COPY alert.rules.yml /etc/prometheus/
RUN chmod +x /etc/prometheus/prometheus.yml 
RUN chmod +x /etc/prometheus/alert.rules.yml
RUN cp -r prometheus-2.32.0-rc.0.linux-amd64/consoles /etc/prometheus/ 
RUN cp -r prometheus-2.32.0-rc.0.linux-amd64/console_libraries /etc/prometheus/ 

# install alertmanager and configure    
RUN wget --quiet https://github.com/prometheus/alertmanager/releases/download/v0.23.0/alertmanager-0.23.0.linux-amd64.tar.gz  
RUN tar -xvf alertmanager-0.23.0.linux-amd64.tar.gz 
RUN cp -r alertmanager-0.23.0.linux-amd64/alertmanager /usr/local/bin/ 
RUN mkdir -p /etc/alertmanager/ 
#RUN cp alertmanager-0.23.0.linux-amd64/alertmanager.yml /etc/alertmanager/alertmanager.yml
COPY alertmanager.yml /etc/alertmanager/
RUN chmod +x /etc/alertmanager/alertmanager.yml

#install node_exporter and configure
RUN wget --quiet https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz 
RUN tar -xvf node_exporter-1.3.1.linux-amd64.tar.gz 
RUN cp -r node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/ 

#ENTRYPOINT ["/bash.sh"]

LABEL description="parachain node"
ENV DEBIAN_FRONTEND noninteractive

ARG substrate_executable=parachain
ARG substrate_release_url=https://github.com/Manta-Network/Manta/releases/download/v3.0.9-1/manta
ARG substrate_chainspec_url=https://raw.githubusercontent.com/Manta-Network/Manta/manta/genesis/calamari-testnet-genesis.json
ARG relay_chainspec_url=https://raw.githubusercontent.com/paritytech/polkadot/master/node/service/res/westend.json

RUN apt -y update

RUN apt -y install curl \
    software-properties-common \
    wget \
    openssl \
    libssl-dev

ENV substrate_executable=$substrate_executable
ENV substrate_release_url=$substrate_release_url
ENV substrate_chainspec_url=$substrate_chainspec_url
ENV relay_chainspec_url=$relay_chainspec_url

RUN wget --quiet ${relay_chainspec_url} -O /usr/share/${substrate_executable}/relaychain-spec.json || true

RUN wget --quiet ${substrate_chainspec_url} -O /usr/share/${substrate_executable}/${substrate_executable}-parachain-spec.json || true

RUN wget --quiet ${substrate_release_url} -O /usr/local/bin/${substrate_executable} 
RUN chmod +x /usr/local/bin/${substrate_executable}

# Configurations to start node 
ARG PARA_BINARY_URL=https://github.com/Manta-Network/Manta/releases/download/v3.0.9-1/manta
ARG PARA_BINARY_PATH=/usr/local/bin/parachain

ARG PARA_GENESIS_URL=https://raw.githubusercontent.com/Manta-Network/Manta/manta/genesis/calamari-testnet-genesis.json
ARG PARA_GENESIS_PATH=/usr/share/calamari.json

ARG RELAY_GENESIS_URL=https://raw.githubusercontent.com/paritytech/polkadot/master/node/service/res/westend.json
ARG RELAY_GENESIS_PATH=/usr/share/westend.json

ARG SUBSTRATE_BASE_PATH=/var/lib/substrate
ARG SUBSTRATE_PORT=30333
ARG SUBSTRATE_RPC_PORT=9933
ARG SUBSTRATE_RPC_CORS=all
ARG SUBSTRATE_RPC_METHODS=safe
ARG SUBSTRATE_WS_PORT=9944
ARG SUBSTRATE_WS_MAX_CONNECTIONS=100
ARG SUBSTRATE_PARACHAIN_ID=2084

ARG SUBSTRATE_BOOTNODE_0=/dns/crispy.westend.testnet.calamari.systems/tcp/30333/p2p/12D3KooWMQYXzM1cEQss5QYehPWVtprCMrbxXU2bjfrCs9XCr8td
ARG SUBSTRATE_BOOTNODE_1=/dns/crunchy.westend.testnet.calamari.systems/tcp/30333/p2p/12D3KooWGmvb3usBiS7mprK65wP4G2Zx68VQGwEtyg9SqtSgVLp6
ARG SUBSTRATE_BOOTNODE_2=/dns/hotdog.westend.testnet.calamari.systems/tcp/30333/p2p/12D3KooWHEJXrGyYwXL7GUy6HCDAS2Tvj3htiNa5hURKUSei3L1v
ARG SUBSTRATE_BOOTNODE_3=/dns/tasty.westend.testnet.calamari.systems/tcp/30333/p2p/12D3KooWPZCmohHvwThz5kdNAh3XHZZHbL3e76hEiKg5KC8SxvHX
ARG SUBSTRATE_BOOTNODE_4=/dns/tender.westend.testnet.calamari.systems/tcp/30333/p2p/12D3KooWPWBYYKGB31VJyBw4snsdfeRmkp8jeGaw7VLHLPYwmwax

RUN mkdir -p $SUBSTRATE_BASE_PATH

ADD $PARA_BINARY_URL $PARA_BINARY_PATH
RUN chmod +x $PARA_BINARY_PATH
RUN ldd $PARA_BINARY_PATH
RUN $PARA_BINARY_PATH --version

ADD $PARA_GENESIS_URL $PARA_GENESIS_PATH
ADD $RELAY_GENESIS_URL $RELAY_GENESIS_PATH

EXPOSE $SUBSTRATE_PORT
EXPOSE $SUBSTRATE_RPC_PORT
EXPOSE $SUBSTRATE_WS_PORT

ENV PARA_BINARY_PATH=$PARA_BINARY_PATH
ENV PARA_GENESIS_PATH=$PARA_GENESIS_PATH
ENV SUBSTRATE_BASE_PATH=$SUBSTRATE_BASE_PATH
ENV SUBSTRATE_PARACHAIN_ID=$SUBSTRATE_PARACHAIN_ID
ENV SUBSTRATE_PORT=$SUBSTRATE_PORT
ENV SUBSTRATE_RPC_PORT=$SUBSTRATE_RPC_PORT
ENV SUBSTRATE_WS_PORT=$SUBSTRATE_WS_PORT
ENV SUBSTRATE_RPC_CORS=$SUBSTRATE_RPC_CORS
ENV SUBSTRATE_RPC_METHODS=$SUBSTRATE_RPC_METHODS
ENV SUBSTRATE_WS_MAX_CONNECTIONS=$SUBSTRATE_WS_MAX_CONNECTIONS
ENV SUBSTRATE_BOOTNODE_0=$SUBSTRATE_BOOTNODE_0
ENV SUBSTRATE_BOOTNODE_1=$SUBSTRATE_BOOTNODE_1
ENV SUBSTRATE_BOOTNODE_2=$SUBSTRATE_BOOTNODE_2
ENV SUBSTRATE_BOOTNODE_3=$SUBSTRATE_BOOTNODE_3
ENV SUBSTRATE_BOOTNODE_4=$SUBSTRATE_BOOTNODE_4
ENV RELAY_GENESIS_PATH=$RELAY_GENESIS_PATH

ENTRYPOINT $PARA_BINARY_PATH \
  --chain $PARA_GENESIS_PATH \
  --base-path $SUBSTRATE_BASE_PATH \
  --parachain-id $SUBSTRATE_PARACHAIN_ID \
  --port $SUBSTRATE_PORT \
  --ws-port $SUBSTRATE_WS_PORT \
  --ws-external \
  --rpc-port $SUBSTRATE_RPC_PORT \
  --rpc-external \
  --rpc-cors $SUBSTRATE_RPC_CORS \
  --rpc-methods $SUBSTRATE_RPC_METHODS \
  --ws-max-connections $SUBSTRATE_WS_MAX_CONNECTIONS \
  --bootnodes \
    $SUBSTRATE_BOOTNODE_0 \
    $SUBSTRATE_BOOTNODE_1 \
    $SUBSTRATE_BOOTNODE_2 \
    $SUBSTRATE_BOOTNODE_3 \
    $SUBSTRATE_BOOTNODE_4 \
  -- \
  --chain $RELAY_GENESIS_PATH & \
/bash.sh

CMD ["sh"]