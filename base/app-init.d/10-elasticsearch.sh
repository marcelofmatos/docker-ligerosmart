#!/bin/bash

# elasticsearch integration
# Change WebService destination

cat >/tmp/elasticsearch-config.yml <<EOF
---
- ${APP_LigeroSmart_Node}:9200
EOF

otrs.Console.pl Admin::Config::Update --setting-name 'LigeroSmart###Nodes' --source-path=/tmp/elasticsearch-config.yml

otrs.Console.pl Admin::Config::Update --setting-name 'LigeroSmart::Index' --value "${APP_CustomerID}"



# init elasticsearch mapping
otrs.Console.pl Admin::Ligero::Elasticsearch::MappingInstall --DefaultLanguage