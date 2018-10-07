#!/usr/bin/env bash

SCALA_VERSION=$1

VERSION=`echo "$(scala -version 2>&1)" | grep "Scala code runner version" | awk '{ print $5; }'`
if [ $VERSION = $SCALA_VERSION ]; then
    echo "Match"
else
    echo "No Match ($VERSION != $SCALA_VERSION) & Install $SCALA_VERSION"
    echo "Install Scala $SCALA_VERSION"
    wget "https://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz"
    sudo mkdir /usr/lib/scala
    tar -xf scala-$SCALA_VERSION.tgz -C /usr/lib/scala
    rm scala-$SCALA_VERSION.tgz
    sudo ln -s /usr/lib/scala/scala-$SCALA_VERSION/bin/scala /bin/scala
    sudo ln -s /usr/lib/scala/scala-$SCALA_VERSION/bin/scalac /bin/scalac
fi
scala -version
