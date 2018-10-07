#!/usr/bin/env bash

JAVA_VERSION=$1
JAVA_CHECK=$2
VERSION=`echo "$(java -version 2>&1)" | grep "java version" | awk '{ print substr($3, 2, length($3)-2); }'`
if [ $VERSION = $JAVA_CHECK ]; then
    echo "Match"
else
    echo "No Match ($VERSION != $JAVA_CHECK) & Install $JAVA_VERSION"
    sudo apt-get update
    sudo apt-get -y install oracle-$JAVA_VERSION-jdk
fi
java -version
