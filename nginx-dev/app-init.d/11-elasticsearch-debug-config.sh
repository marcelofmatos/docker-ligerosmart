#!/bin/bash

# logging all requests to elasticsearch 

curl --silent -X PUT "${APP_LigeroSmart_Node:-elasticsearch}:9200/_settings" -H 'Content-Type: application/json' -d'
{
  "index.search.slowlog.threshold.query.warn": "0",
  "index.search.slowlog.threshold.query.info": "0",
  "index.search.slowlog.threshold.query.debug": "0",
  "index.search.slowlog.threshold.query.trace": "0",
  "index.search.slowlog.threshold.fetch.warn": "0",
  "index.search.slowlog.threshold.fetch.info": "0",
  "index.search.slowlog.threshold.fetch.debug": "0",
  "index.search.slowlog.threshold.fetch.trace": "0",
  "index.search.slowlog.level": "info"
}' > /dev/null