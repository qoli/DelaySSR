#!/bin/bash
clear
echo '> '$(pwd)
CONF="./LogDelay_subscribe_link.txt"
CONF_decode="./LogDelay_subscribe_link_decode.txt"
CONF_ssr="./LogDelay_ssr_list.txt"
PING_log="./LogDelay_working_log.txt"
PING_sort="./LogDelay_working_sort.txt"

if [ ! -n "$1" ]; then
	echo "usage:"
	echo "$0 subscribe_link"
	exit
fi

rm ${CONF}
rm ${CONF_ssr}
rm ${PING_log}
wget -c $1 -O ${CONF}
base64 --decode ${CONF} > ${CONF_decode}

NUMBER=0
clear

echo "Checking..."

for SSR_Line in `cat ${CONF_decode}`
do
	NUMBER=$(expr $NUMBER + 1)
	Config_determine=$(echo ${SSR_Line}|cut -c 1-6)
	Config_ip=$(echo ${SSR_Line}| cut -c 7-2000 | base64 --decode | awk -F ":" '{print $1}')
	DELAY=$(ping -t 3 ${Config_ip} | grep "min/avg/max/stddev" | awk '{print $4}' | cut -d "/" -f 2)
	if [ ! -n "$DELAY" ]; then
		echo "> "$NUMBER"/"${Config_ip}"/timeout"
	else
		echo $(echo $SSR_Line | cut -c 7-2000 | base64 --decode)"" >> ${CONF_ssr}
		echo "> "$NUMBER"/"${Config_ip}"/avg(ms)/"${DELAY} | tee -a ${PING_log}
	fi
done

clear
sort -t / -n -k 4 ${PING_log} > ${PING_sort}
clear
echo "./delay-test.sh 6, Check for Google delays."
./delay-test.sh 10