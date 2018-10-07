#!/usr/bin/env bash

VERSION=`echo "$(sudo systemctl status apache2>&1)" | grep "apache2.service -" | awk '{ print $2; }'`
INSTALLED="apache2.service"
if [ $VERSION = $INSTALLED ]; then
    echo "Match"
else
    echo "No Match ($VERSION != $INSTALLED) & Install"
    sudo apt-get -y install apache2 apache2-doc apache2-utils
fi
sudo systemctl status apache2
