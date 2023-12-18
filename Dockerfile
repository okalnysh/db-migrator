FROM ubuntu:22.04
WORKDIR /db-migrator
COPY . .
RUN ./install-sqlcmd.sh