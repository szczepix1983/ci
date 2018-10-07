#!/bin/sh
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
echo "${ColorGreen} Start paymentCheck.sh ${ColorGreenEnd}"

echo "${ColorCyan} getting data from https://szczepix1.nazwa.pl/nyskaflat/api/getadmin/ ${ColorCyanEnd}"
curl --max-time 10 --request POST --data id=7 "https://szczepix1.nazwa.pl/nyskaflat/api/getadmin/" > data.json

echo "${ColorCyan} Checking ... ${ColorCyanEnd}"
USERS=$(jq -r '.data.users' data.json)
CURRENT_PAYMENT_ID=$(date +'%m-%Y')
echo "Current payment date: $CURRENT_PAYMENT_ID"

userslength=$(jq '.data.users | length' data.json)
costslength=$(jq '.data.costs | length' data.json)
roomslength=$(jq '.data.rooms | length' data.json)
i=1
while [ "$i" -le ${userslength} ];
do
  ROOM_ID=$(cat data.json | jq ".data.users[$i-1].roomId")
  USER=$(cat data.json | jq ".data.users[$i-1].username")
  EMAIL=$(cat data.json | jq ".data.users[$i-1].email")
  EMAIL=${EMAIL#*'"'};
  EMAIL=${EMAIL%'"'*}
  FOUND=false

  k=1
  while [ "$k" -le ${roomslength} ];
  do
    if [ $(cat data.json | jq ".data.rooms[$k-1].id") = $ROOM_ID ]; then
      ROOM_NAME=$(cat data.json | jq ".data.rooms[$k-1].name")
    fi;
    k=$(( k + 1 ))
  done

  j=1
  while [ "$j" -le ${costslength} ];
  do
    COST_ID=$(cat data.json | jq ".data.costs[$j-1].costId")
    ACCEPTED=$(cat data.json | jq ".data.costs[$j-1].accepted")
    if [ "\"${CURRENT_PAYMENT_ID}_${ROOM_ID}\"" = $COST_ID ]; then
      if [ $ACCEPTED = 1 ]; then
        FOUND=true
      else
        [ -e index.html ] && rm index.html
        PRICE=$(cat data.json | jq ".data.costs[$j-1].price")
        echo "${ColorCyan} Found user to pay ${USER} ${ColorCyanEnd}"
        echo '<table style="width: 100%;" border="0">' >> index.html
        echo '<tbody>' >> index.html
        echo '<tr>' >> index.html
        echo '<td colspan="2"><h4 style="text-align: center;">Payment reminder</h4></td>' >> index.html
        echo '</tr>' >> index.html
        echo '<tr>' >> index.html
        echo '<td style="text-align: center;">User</td>' >> index.html
        echo '<td><h4 style="text-align: center;">'${USER}'</h4></td>' >> index.html
        echo '</tr>' >> index.html
        echo '<tr>' >> index.html
        echo '<td style="text-align: center;">Payment</td>' >> index.html
        echo '<td><h4 style="text-align: center;">'${CURRENT_PAYMENT_ID}'</h4></td>' >> index.html
        echo '</tr>' >> index.html
        echo '<tr>' >> index.html
        echo '<td style="text-align: center;">Price</td>' >> index.html
        echo '<td><h4 style="text-align: center;">'$PRICE' zł</h4></td>' >> index.html
        echo '</tr>' >> index.html
        echo '<tr>' >> index.html
        echo '<td style="text-align: center;">Room</td>' >> index.html
        echo '<td><h4 style="text-align: center;">'$ROOM_NAME'</h4></td>' >> index.html
        echo '</tr>' >> index.html
        echo '<tr>' >> index.html
        echo '<td style="text-align: center;">Email</td>' >> index.html
        echo '<td><h4 style="text-align: center;">'$EMAIL'</h4></td>' >> index.html
        echo '</tr>' >> index.html
        echo '</tbody>' >> index.html
        echo '</table>' >> index.html
        echo '<h4 style="text-align: center;font-style: italic;">Powered by NyskaFlat</h4>' >> index.html

        echo "Sending email to: ${EMAIL}"

        #EMAIL="\"szczepan.martyniuk@gmail.com\""

        curl --max-time 10 --request POST -F 'email='${EMAIL}'' -F 'template=@index.html' "https://szczepix1.nazwa.pl/nyskaflat/api/sendemail/" > $ROOM_ID.json

        RESPONSE=$(jq -r '.data' $ROOM_ID.json)
        echo "${ColorCyan} Response ${ColorCyanEnd}"
        echo $RESPONSE
      fi;
    fi;
    j=$(( j + 1 ))
  done
  i=$(( i + 1 ))
done

echo "${ColorGreen} End paymentCheck.sh ${ColorGreenEnd}"
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
