FROM ligero/ligerosmart:apache2

COPY --chown=root:root etc /etc
COPY --chown=root:root app-run-oracle-support.sh /

RUN sudo apt-get update \
    && sudo apt-get install -y \
       alien \
       libaio1 \
    && cd /tmp \
    && curl --silent --remote-name --location https://addons.ligerosmart.org/packages/oracle/oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm \
    && curl --silent --remote-name --location https://addons.ligerosmart.org/packages/oracle/oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm \
    && curl --silent --remote-name --location https://addons.ligerosmart.org/packages/oracle/oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm \
    && alien -i oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm \
    && alien -i oracle-instantclient12.1-sqlplus-12.1.0.2.0-1.x86_64.rpm \
    && alien -i oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm \
    && rm -rf /tmp/*.rpm \
    && cpanm --notest DBD::Oracle \
    && apt remove --purge alien -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/* 

CMD /app-run-oracle-support.sh

ENV START_WEBSERVER=1 \
    START_SCHEDULER=1