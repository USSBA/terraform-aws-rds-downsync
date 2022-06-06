FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
  && apt-get install -y gnupg dirmngr wget curl unzip \
  && rm -rf /var/lib/apt/lists/*

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list

RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update \
  && apt-get install -y software-properties-common \
  && rm -rf /var/lib/apt/lists/*

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

COPY entrypoint.sh sync_dump.sh sync_restore.sh /usr/local/bin/

RUN chmod 500 /usr/local/bin/*.sh

ENTRYPOINT [ "entrypoint.sh" ]
