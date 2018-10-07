#!/bin/sh
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
echo "${ColorGreen} Start deploy.sh ${ColorGreenEnd}"
cd myhouseblockchain

echo "${ColorGreen} docker kill all containers ${ColorGreenEnd}"
sudo docker-compose stop

echo "${ColorGreen} Make docker composer ${ColorGreenEnd}"
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
echo "${ColorCyan} Found IP $LOCAL_IP ${ColorCyanEnd}"
echo "${ColorGreen} Generate docker-compose.yml file for IP address ${LOCAL_IP} ${ColorGreenEnd}"

sed "s/{ip_address}/${LOCAL_IP}/g" <docker-compose-template.yml >docker-compose.yml

echo "${ColorGreen} sbt publish local ${ColorGreenEnd}"
sudo sbt docker:publishLocal

echo "${ColorCyan} Run docker app ${ColorCyanEnd}"
[ -e run.log ] && rm run.log
sudo docker-compose up -d

#verify () {
#  echo "Checking $1 for $2"
#  [ -e blockchainstorage/startup.json ] && rm blockchainstorage/startup.json
#  curl --request GET "http://${2}:8081/ping" > blockchainstorage/startup.json || echo '{"status":404}' >> blockchainstorage/startup.json
#}
#
#i=1
#while [ "$i" -le 120 ]; do
#  verify $i $LOCAL_IP
#  RESULT=$(jq -r '.status' blockchainstorage/startup.json)
#  echo "Result: $RESULT"
#  if [ "$RESULT" = "200" ]
#  then
#    exit 0
#  fi
#  sleep 5s
#  i=$(( i + 1 ))
#done

echo "${ColorGreen} End deploy.sh ${ColorGreenEnd}"
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
