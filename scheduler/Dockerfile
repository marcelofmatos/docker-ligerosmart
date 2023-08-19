FROM ligero/ligerosmart:base

ENV START_WEBSERVER=0 \
    START_SCHEDULER=1

COPY app-healthcheck.sh /app-healthcheck.sh

HEALTHCHECK --interval=10s --timeout=20s --retries=2 --start-period=10s CMD /app-healthcheck.sh
