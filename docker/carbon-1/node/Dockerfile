FROM burnt/carbon-1/base-image:develop as node

  # create burntd user
  RUN set -eux \
    && useradd -s /bin/bash -d /home/burntd/ -m burntd

  # populate /tmp/node/... to fetch at runtime with volume mounts
  COPY data/config/app.toml /tmp/node/config/app.toml
  COPY data/config/client.toml /tmp/node/config/client.toml
  COPY data/config/config.toml /tmp/node/config/config.toml

  # chown the stuff
  RUN set -eux \
    && chown -R burntd:burntd /home/burntd \
    && chown -R burntd:burntd /tmp/node

  # populate burntd home to run without volumes
  RUN set -eux \
    && mkdir -p /home/burntd/.burnt \
    && cp -Rvf /tmp/node/* /home/burntd/.burnt/

  USER burntd:burntd
  WORKDIR /home/burntd

  CMD [ "/tini", "--", "burntd", "start", "--x-crisis-skip-assert-invariants", "--home", "/home/burntd/.burnt" ]
