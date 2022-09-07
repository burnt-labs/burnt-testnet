FROM golang:1.19-bullseye AS base

  ARG GITHUB_API_TOKEN

  ENV GIT_BRANCH "main"
  ENV GIT_URL "https://oauth2:$GITHUB_API_TOKEN@github.com/BurntFinance/burnt.git"
  ENV CHAIN_ID "carbon-1"
  ENV MONIKER "burnt.com"
  ENV GRPCURL_VERSION "v1.8.7"
  ENV GENESIS_URL "https://burnt-use1testnet-carbon-1.s3.amazonaws.com/genesis.json"

  # Add Tini
  ENV TINI_VERSION v0.19.0
  ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
  RUN chmod +x /tini

  # update OS and packages
  RUN set -eux \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
      build-essential \
      git \
      htop \
      jq \
      vim-tiny \
      wget \
    && rm -rf /var/lib/apt/lists/*

  # build grpcurl
  RUN set -eux \
    && go install github.com/fullstorydev/grpcurl/cmd/grpcurl@$GRPCURL_VERSION

  # build burntd
  RUN set -eux \
    && git clone $GIT_URL --branch $GIT_BRANCH /tmp/burnt \
    && cd /tmp/burnt; make install

  # init burnt node
  # we're using /tmp/node to help when mounting data volumes
  RUN set -eux \
    && burntd init $MONIKER --chain-id $CHAIN_ID --home /tmp/node \
    && wget -O /tmp/node/config/genesis.json $GENESIS_URL
  COPY ./config/app.toml /tmp/node/config/app.toml
  COPY ./config/client.toml /tmp/node/config/client.toml
  COPY ./config/config.toml /tmp/node/config/config.toml

  RUN set -eux \
    && mkdir -p /root/.burnt \
    && cp -Rvf /tmp/node/* /root/.burnt/
  WORKDIR /root/.burnt

  CMD [ "/bin/sleep", "infinity" ]
