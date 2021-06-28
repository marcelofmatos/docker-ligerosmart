FROM ligero/ligerosmart:base

# Packages
RUN apt-get update \
    && apt-get install -y \
        ssh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# include files
COPY etc /etc

# ssh configuration
RUN echo "AuthorizedKeysFile .ssh/authorized_keys /etc/ssh/authorized_keys" >> /etc/ssh/sshd_config

RUN mkdir /var/run/sshd

# default env values for services
ENV START_SSHD=1 \
    DATABASE_CHECK=0 \
    START_WEBSERVER=0 \
    START_SCHEDULER=0

