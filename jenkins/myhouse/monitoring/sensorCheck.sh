#!/usr/bin/env bash
SENSOR_IP=$1
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
echo "${ColorGreen} Start sensorCheck.sh ${ColorGreenEnd}"

echo "${ColorCyan} getting data from http://${SENSOR_IP}/error ${ColorCyanEnd}"
curl --max-time 10 --request GET "http://${SENSOR_IP}/error" > errors.json

ERRORS=$(jq -r '.errors' errors.json)
errorslength=$(jq '.errors | length' errors.json)

echo "${ColorCyan} errors $errorslength ${ColorCyanEnd}"
echo "${ERRORS}"

echo "${ColorGreen} End sensorCheck.sh ${ColorGreenEnd}"
echo "${ColorRed}---------------------------------------------${ColorRedEnd}"
