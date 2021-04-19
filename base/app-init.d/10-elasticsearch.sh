#!/bin/bash

# elasticsearch integration
# Change WebService destination
perl $HOME/scripts/UpdateWS.pl ${APP_LigeroSmart_Node} ${APP_CustomerID}

# init elasticsearch mapping
otrs.Console.pl Admin::Ligero::Elasticsearch::MappingInstall --DefaultLanguage