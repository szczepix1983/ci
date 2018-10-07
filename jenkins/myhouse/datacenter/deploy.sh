#!/bin/sh
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
echo "${ColorGreen} Start deploy.sh ${ColorGreenEnd}"
[ -e blockchainstorage/storage.war ] && rm blockchainstorage/storage.war
[ -e blockchainstorage/startup.json ] && rm blockchainstorage/startup.json
APPLICATION=$(ls blockchainstorage | grep .war)
echo "${ColorCyan} Updates ${APPLICATION} ${ColorCyanEnd}"
cp -Rf blockchainstorage/${APPLICATION} blockchainstorage/storage.war

echo "${ColorCyan} kill java -jar ${ColorCyanEnd}"
pkill -f 'java -jar blockchainstorage/storage.war'
[ -e blockchainstorage/run.log ] && rm blockchainstorage/run.log

echo "${ColorCyan} running blockchainstorage/storage.war ${ColorCyanEnd}"
java -jar blockchainstorage/storage.war > blockchainstorage/run.log &

verify () {
  echo "Checking $1 for $2"
  [ -e blockchainstorage/startup.json ] && rm blockchainstorage/startup.json
  curl --request GET "http://${2}:8081/ping" > blockchainstorage/startup.json || echo '{"status":404}' >> blockchainstorage/startup.json
}

unamestr="$(uname)"
if [ "$unamestr" = "Linux" ]
then
   LOCAL_IP=$(sudo ifconfig wlan0 | awk '/inet /{print $2}')
elif [ "$unamestr" = 'Darwin' ]
then
    LOCAL_IP=$(sudo ifconfig en0 | awk '/inet /{print $2}')
    if [ ! $LOCAL_IP ]
    then
        LOCAL_IP=$(sudo ifconfig en1 | awk '/inet /{print $2}')
    fi
fi
echo "${ColorCyan} Checking ${LOCAL_IP} ${ColorCyanEnd}"

i=1
while [ "$i" -le 120 ]; do
  verify $i $LOCAL_IP
  RESULT=$(jq -r '.status' blockchainstorage/startup.json)
  echo "Result: $RESULT"
  if [ "$RESULT" = "200" ]
  then
    exit 0
  fi
  sleep 5s
  i=$(( i + 1 ))
done

echo "${ColorGreen} End deploy.sh ${ColorGreenEnd}"
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
