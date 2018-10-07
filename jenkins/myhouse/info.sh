#!/usr/bin/env bash

echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
echo "${ColorGreen} Start info.sh ${ColorGreenEnd}"

echo "${ColorCyan} java ${ColorCyanEnd}"
java -version

echo "${ColorCyan} python ${ColorCyanEnd}"
python -V

echo "${ColorCyan} system ${ColorCyanEnd}"
uname -a

#curl --request POST --data id=7 "https://szczepix1.nazwa.pl/nyskaflat/api/getadmin/" > data.json

echo "${ColorGreen} End info.sh ${ColorGreenEnd}"
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"