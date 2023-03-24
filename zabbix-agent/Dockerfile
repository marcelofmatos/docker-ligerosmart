FROM zabbix/zabbix-agent:alpine-latest

USER root

RUN apk add mysql-client postgresql-client

COPY etc /etc

USER zabbix
