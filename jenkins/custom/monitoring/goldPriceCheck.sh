echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
echo "${ColorGreen} Start goldPriceCheck.sh ${ColorGreenEnd}"

EMAIL="\"szczepan.martyniuk@gmail.com\""
EMAIL=${EMAIL#*'"'};
EMAIL=${EMAIL%'"'*}
LIMITTED=$1
URL=$2
DESCRIPTION=$3

echo "${ColorCyan} Check $DESCRIPTION from https://www.metalelokacyjne.pl/ ${ColorCyanEnd}"
[ -e data.html ] && rm data.html
curl --max-time 10 --request GET "${URL}" > data.html

REPLACE=""
START_TAG="\"minprice\":"
END_TAG=","
ZERO=0

FOUND=$(grep -i "$START_TAG" data.html)

FOUND=$(echo "sed "s/$START_TAG/$REPLACE/g" <<<"$FOUND"")
FOUND=$(echo "sed "s/$END_TAG/$REPLACE/g" <<<"$FOUND"")
FOUND=$(echo "sed "s/ //g" <<<"$FOUND"")
#FOUND=$(echo "${FOUND/$START_TAG/$REPLACE}")
#FOUND=$(echo "${FOUND/$END_TAG/$REPLACE}")
#FOUND=$(echo "${FOUND// /}")
FOUND=$(echo "$FOUND" | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')

calc() { awk "BEGIN{print $*}"; }

PRICE=$FOUND
echo "${ColorCyan} Got price $PRICE for limit $LIMITTED ${ColorCyanEnd}"

FOUND=$(calc $FOUND*100)
LIMIT=$(calc $LIMITTED*100)
#RESULT=$(calc $FOUND-$LIMIT)
#RESULT=$(calc $RESULT/100)
#echo "Result: $RESULT"

if [ "$FOUND" -lt "$LIMIT" ]; then
  echo "${ColorCyan} Sending email alert ${ColorCyanEnd}"

  [ -e index.html ] && rm index.html
  echo '<table style="width: 100%;" border="0">' >> index.html
  echo '<tbody>' >> index.html
  echo '<tr>' >> index.html
  echo '<td colspan="2"><h4 style="text-align: center;">Gold alert</h4></td>' >> index.html
  echo '</tr>' >> index.html
  echo '<tr>' >> index.html
  echo '<td style="text-align: center;">Weight</td>' >> index.html
  echo '<td><h4 style="text-align: center;">'${DESCRIPTION}'</h4></td>' >> index.html
  echo '</tr>' >> index.html
  echo '<tr>' >> index.html
  echo '<td style="text-align: center;">Price</td>' >> index.html
  echo '<td><h4 style="text-align: center;">'${PRICE}'</h4></td>' >> index.html
  echo '</tr>' >> index.html
  echo '<tr>' >> index.html
  echo '<td style="text-align: center;">Limit to buy</td>' >> index.html
  echo '<td><h4 style="text-align: center;">'${LIMITTED}'</h4></td>' >> index.html
  echo '</tr>' >> index.html
  echo '</tbody>' >> index.html
  echo '</table>' >> index.html

  curl --max-time 10 --request POST -F 'email='${EMAIL}'' -F 'template=@index.html' "https://szczepix1.nazwa.pl/nyskaflat/api/sendemail/" > response.json

  RESPONSE=$(jq -r '.data' response.json)
  echo "${ColorCyan} Response ${ColorCyanEnd}"
  echo $RESPONSE
fi;

echo "${ColorGreen} End goldPriceCheck.sh ${ColorGreenEnd}"
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
