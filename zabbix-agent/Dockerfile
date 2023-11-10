FROM zabbix/zabbix-agent:alpine-latest

USER root

RUN apk add mysql-client postgresql-client

COPY etc /etc

COPY healthcheck.sh /healthcheck.sh

USER zabbix

HEALTHCHECK  --interval=1m --timeout=10s \
  CMD /healthcheck.sh
