FROM ligero/ligerosmart:base


# Packages
RUN apt-get update \
    && apt-get install -y \
        nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*  

# Extra perl modules
RUN apt update \
    && apt install -y \
            build-essential \
    && cpanm --sudo --quiet --notest Starman \
    && cpanm --sudo --quiet --notest Devel::NYTProf \
    && apt remove --purge -y \
            build-essential \
            libexpat1-dev \
            libssl-dev \
    && apt autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* 

# include files
COPY etc /etc
COPY var /var
COPY app.psgi /
COPY app-healthcheck.sh /app-healthcheck.sh

# post configuration
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && echo ". /etc/environment" > /opt/otrs/.profile 
    
EXPOSE 80

HEALTHCHECK --interval=10s --timeout=20s --retries=2 --start-period=1m CMD /app-healthcheck.sh

# default env values for services
ENV START_WEBSERVER=1 \
    STARMAN_WORKERS=3 \
    START_SCHEDULER=1 \
    DEBUG_MODE=0 \
    PLACK_ENV=deployment \
    NYTPROF=start=no

