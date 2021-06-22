FROM ubuntu:20.04

ENV RELEASE_TAG=6.1.9 \
    CODE_REPOSITORY="https://github.com/LigeroSmart/ligerosmart" \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PATH=/opt/otrs/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

SHELL ["/bin/bash", "-c"]

# Language
RUN apt-get update \
    && apt-get install -y locales \
    && rm -rf /var/lib/apt/lists/* \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && echo "pt_BR.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=${LANG} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Packages
RUN apt-get update \
    && apt-get install -y \
        bash-completion \
        cron \
        curl \
        dialog \
        gettext \
        git-core \
        graphviz \
        libarchive-zip-perl \
        libauthen-ntlm-perl \
        libauthen-sasl-perl \
        libcrypt-eksblowfish-perl \
        libcrypt-ssleay-perl \
        libdate-pcalc-perl \
        libdatetime-perl \
        libdbd-mysql-perl \
        libdbd-odbc-perl \
        libdbd-pg-perl \
        libdbi-perl \
        libencode-hanextra-perl \
        libgraphviz-perl \
        libio-socket-ssl-perl \
        libjson-xs-perl \
        libmail-imapclient-perl \
        libnet-dns-perl \
        libnet-ldap-perl \
        libtemplate-perl \
        libterm-readline-perl-perl \
        libtext-csv-xs-perl \
        libtimedate-perl \
        libxml-libxml-perl \
        libxml-libxslt-perl \
        libxml-parser-perl \
        libxml2-utils \
        libyaml-libyaml-perl \
        mysql-client \
        perl \
        postgresql-client \
        rsync \
        sendmail \
        sudo \
        supervisor \
        tzdata \
        unzip \
        vim \
        xterm \
        zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# Extra perl modules
RUN apt update \
    && apt install -y \
            build-essential \
            libexpat1-dev \
            libssl-dev \
    && curl --silent -L https://cpanmin.us | perl - --sudo App::cpanminus \
    && cpanm --sudo --quiet --notest Cache::Memcached::Fast \
    && cpanm --sudo --quiet --notest DateTime::TimeZone \
    && cpanm --sudo --quiet --notest HTTP::Server::Brick \
    && cpanm --sudo --quiet --notest JSON::Path \
    && cpanm --sudo --quiet --notest Plack \
    && cpanm --sudo --quiet --notest Search::Elasticsearch@7.30 \
    && cpanm --sudo --quiet --notest HTTP::DAV \
    && cpanm --sudo --quiet --notest MIME::Words \
    && cpanm --sudo --quiet --notest Text::Markdown \
    && apt remove --purge -y \
            build-essential \
            libexpat1-dev \
            libssl-dev \
    && apt autoremove -y \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* 

# user config
RUN useradd -d /opt/otrs -c 'OTRS user' -g www-data -s /bin/bash otrs \
    && usermod -a -G tty www-data \
    && usermod -a -G tty otrs 

RUN mkdir /opt/otrs \
        /app-backups \
        /app-packages \
        /app-init.d

WORKDIR /opt/otrs

# LigeroSmart code
RUN cd /opt/otrs \
    && git init \
    && git config core.fileMode false \
    && git remote add origin $CODE_REPOSITORY \
    && git pull origin $RELEASE_TAG \
    && mkdir -p /opt/otrs/var/article \ 
                /opt/otrs/var/spool \
                /opt/otrs/var/tmp \
    && chown otrs:www-data -R /opt/otrs \
    && chmod 775 -R /opt/otrs 
    
# include files
COPY --chown=otrs:www-data var /var
COPY etc /etc
COPY usr /usr
COPY root /root
COPY app-init.d/* /app-init.d/
COPY app-packages/* /app-packages/
COPY app-init.sh /app-init.sh
COPY app-run.sh /app-run.sh

# post configuration
RUN mkdir -p /var/log/supervisor \
    && chmod +x /*.sh \
    && rm /etc/update-motd.d/* \
    && echo "PATH=\"$PATH\"" > /etc/environment

# aws cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && sudo ./aws/install \
    && rm -rf aws/ awscliv2.zip

# default env values for services
ENV APP_DIR=/opt/otrs \
    START_SCHEDULER=0 \
    START_WEBSERVER=0 \
    DEBUG_MODE=0

CMD /app-run.sh
