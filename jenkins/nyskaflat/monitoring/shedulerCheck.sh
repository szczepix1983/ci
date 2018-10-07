#!/usr/bin/env bash
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
echo "${ColorGreen} Start shedulerCheck.sh ${ColorGreenEnd}"

echo "${ColorCyan} getting data from https://szczepix1.nazwa.pl/nyskaflat/api/getactiveuser/ ${ColorCyanEnd}"
curl --max-time 10 --request GET "https://szczepix1.nazwa.pl/nyskaflat/api/getactiveuser/" > data.json

echo "${ColorCyan} Check selected ${ColorCyanEnd}"
SELECTED=$(jq -r '.data.selected' data.json)
#SELECTED=false
echo "Selected: $SELECTED"

if [ $SELECTED = false ]; then
  echo "${ColorCyan} Check email ${ColorCyanEnd}"
  EMAIL=$(jq -r '.data.email' data.json)
  EMAIL=${EMAIL#*'"'};
  EMAIL=${EMAIL%'"'*}
  USER=$(jq -r '.data.name' data.json)
  echo "Email: $EMAIL"
  echo "${ColorCyan} Sending email alert ${ColorCyanEnd}"

  [ -e index.html ] && rm index.html
  echo '<table style="width: 100%;" border="0">' >> index.html
  echo '<tbody>' >> index.html
  echo '<tr>' >> index.html
  echo '<td colspan="2"><h4 style="text-align: center;">Cleaning reminder</h4></td>' >> index.html
  echo '</tr>' >> index.html
  echo '<tr>' >> index.html
  echo '<td style="text-align: center;">User</td>' >> index.html
  echo '<td><h4 style="text-align: center;">'${USER}'</h4></td>' >> index.html
  echo '</tr>' >> index.html
  echo '<tr>' >> index.html
  echo '<td style="text-align: center;">Cleaned</td>' >> index.html
  echo '<td><h4 style="text-align: center;">'${SELECTED}'</h4></td>' >> index.html
  echo '</tr>' >> index.html
  echo '<tr>' >> index.html
  echo '<td style="text-align: center;">Email</td>' >> index.html
  echo '<td><h4 style="text-align: center;">'$EMAIL'</h4></td>' >> index.html
  echo '</tr>' >> index.html
  echo '<tr>' >> index.html
  echo '<td style="text-align: center;"></td>' >> index.html
  echo '<td><h4 style="text-align: center;"><a href="https://szczepix1.nazwa.pl/nyskaflat/" target="_blank">Update</a></h4></td>' >> index.html
  echo '</tr>' >> index.html
  echo '</tbody>' >> index.html
  echo '</table>' >> index.html
  echo '<h4 style="text-align: center;font-style: italic;">Powered by NyskaFlat</h4>' >> index.html

  #EMAIL="\"szczepan.martyniuk@gmail.com\""

  curl --max-time 10 --request POST -F 'email='${EMAIL}'' -F 'template=@index.html' "https://szczepix1.nazwa.pl/nyskaflat/api/sendemail/" > response.json

  RESPONSE=$(jq -r '.data' response.json)
  echo "${ColorCyan} Response ${ColorCyanEnd}"
  echo $RESPONSE
fi;

echo "${ColorGreen} End shedulerCheck.sh ${ColorGreenEnd}"
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
