FROM ligero/ligerosmart:base

# Packages
RUN apt-get update \
    && apt-get install -y \
        bind9-host \
        htop \
        iputils-ping \
        ldap-utils \
        mtr \
        ncdu \
        nmap \
        screen \
        ssh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# include files
COPY etc /etc

RUN mkdir /var/run/sshd

# default env values for services
ENV START_SSHD=1 \
    DATABASE_CHECK=0 \
    START_WEBSERVER=0 \
    START_SCHEDULER=0

