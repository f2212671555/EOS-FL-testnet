FROM ubuntu:18.04

# Install Libraries
# jq for json
# cmake for build eosio.cdt, build-essential for cmake
RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y wget nano jq curl git cmake build-essential \
    && apt-get install -y python3-pip g++ psmisc openssl libssl-dev

RUN wget https://github.com/eosio/eos/releases/download/v2.0.11/eosio_2.0.11-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./eosio_2.0.11-1-ubuntu-18.04_amd64.deb

RUN wget https://github.com/eosio/eosio.cdt/releases/download/v1.6.3/eosio.cdt_1.6.3-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./eosio.cdt_1.6.3-1-ubuntu-18.04_amd64.deb

WORKDIR /opt
RUN git clone https://github.com/EOSIO/eosio.contracts.git eosio.contracts-1.8.x \
    && cd ./eosio.contracts-1.8.x/ \
    && git checkout release/1.8.x \
    && echo yes | ./build.sh

ENV EOSIO_OLD_CONTRACTS_DIRECTORY /opt/eosio.contracts-1.8.x/build/contracts

RUN apt-get remove -y eosio.cdt

RUN wget https://github.com/eosio/eosio.cdt/releases/download/v1.7.0/eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb

RUN git clone https://github.com/EOSIO/eosio.contracts.git --branch v1.9.0 eosio.contracts \
    && cd ./eosio.contracts/ \
    && echo yes | ./build.sh

ENV EOSIO_CONTRACTS_DIRECTORY /opt/eosio.contracts/build/contracts

RUN git clone https://github.com/EOSIO/eos.git

# coder-server
EXPOSE 8080
ENV PASSWORD eospc

RUN wget https://github.com/cdr/code-server/releases/download/3.1.1/code-server-3.1.1-linux-x86_64.tar.gz \
    && tar zxvf code-server-3.1.1-linux-x86_64.tar.gz \
    && rm -r code-server-3.1.1-linux-x86_64.tar.gz

#https://github.com/ml-tooling/ml-workspace/blob/develop/Dockerfile#L930
RUN \
    # Make zsh the default shell
    chsh -s $(which bash) root

# setting code-server default to bash and resize font
RUN mkdir -p /root/.local/share/code-server/User &&\
    touch /root/.local/share/code-server/User/settings.json &&\
    echo '{"editor.fontSize": 18,"terminal.integrated.fontSize": 16,"terminal.integrated.shell.linux": "/bin/bash",}' >> /root/.local/share/code-server/User/settings.json
# run code server   
ENTRYPOINT ./code-server-3.1.1-linux-x86_64/code-server --host 0.0.0.0  >> codeserver.txt