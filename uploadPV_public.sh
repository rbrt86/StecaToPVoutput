#/bin/sh
## v0.1 by Robert Jan de Groot

## CHANGE THESE TO YOUR OWN VARIABLES
## API and ID are from Pvoutput
API="<ENTER_YOUR_API_KEY_HERE>"
ID="<ENTER_YOUR_ID_HERE>"

## enter the local ip adress from your inverter
SERVER="<ENTER_YOUR_LOCAL_IP>"

## DONT CHANGE THESE
DATAFILE="gen.measurements.table.js"
URL="http://pvoutput.org/service/r2/addstatus.jsp"
DATE="$(date "+%Y%m%d")"
TIME="$(date "+%H:%M")"

getData() {
## function to get the raw data from the measurements page of Steca

rawdata=$(curl -s ${SERVER}/${DATAFILE} | perl -pe "s/.*<td>P DC<\/td><td align='right'>\s*(.*?)\s*<.*?U DC<\/td><td align='right'>\s*(.*?)\s*<.*?<td>P AC<\/td><td align='right'>\s*(.*?)\s*<.*/\1,\2,\3/g")
if [ -z ${rawdata} ]; then
        echo "nothing to do, server is down"
        exit 1
else
        echo "got file!"
        acWatt=$(echo ${rawdata} | cut -f 1 -d ',')
        acVolt=$(echo ${rawdata} | cut -f 2 -d ',')
        dcWatt=$(echo ${rawdata} | cut -f 3 -d ',')

        echo "acWatt set to ${acWatt}"
        echo "acVolt set to ${acVolt}"
        echo "dcWatt set to ${dcWatt}"
fi

}

uploadData () {

if [ "${acWatt}" == "---" ]; then
        v2="0"
        v6="0"
else
        v2=$(echo ${acWatt} | cut -f 1 -d '.')
        v6=$(echo ${acVolt} | perl -pe "s/(.*?)\.(.).*/\1.\2/g" )
fi

echo "$v2"
echo "$v6"


curl -d "d=${DATE}" -d "t=${TIME}" -d "v2=${v2}" -d "v6=${v6}" -H "X-Pvoutput-Apikey: ${API}" -H "X-Pvoutput-SystemId: ${ID}" ${URL}
}

getData;
uploadData;


