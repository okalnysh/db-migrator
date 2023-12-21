FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install ca-certificates curl gnupg software-properties-common wget -y && \
    curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc && \
    add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/ubuntu/20.04/prod.list)" && \
    apt-get update && \
    apt-get install sqlcmd && \
    apt-get clean
WORKDIR /db-migrator
COPY migrate.sh migrate.sh