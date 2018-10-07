#!/usr/bin/env bash

SBT_VERSION=$1
wget "https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/${SBT_VERSION}/sbt-launch.jar"
sudo mkdir /usr/lib/sbt
sudo mv sbt-launch.jar /usr/lib/sbt

echo '#!/bin/sh' >>> /bin/sbt
echo 'java -server -Xmx512M -jar /usr/lib/sbt/sbt-launch.jar "$@"' >>> /bin/sbt

sudo chmod +x /bin/sbt
sbt --version

