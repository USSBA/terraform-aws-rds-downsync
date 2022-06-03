FROM ubuntu:18.04
RUN apt-get update && \
    apt-get install -y gnupg dirmngr wget && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod 555 /usr/bin/entrypoint.sh
ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common postgresql-client-12


