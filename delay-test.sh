#!/bin/bash
clear
RUN_Log="./run-local.log"
CONF_ssr="./LogDelay_ssr_list.txt"
PING_sort="./LogDelay_working_sort.txt"
PING_google="./LogDelay_Google.txt"
SSR_ConfigBuild="./delay-config.py "

if [ ! -n "$1" ]; then
	echo "usage:"
	echo "	$0 count(int)"
	exit
fi

NUMBER=0
clear

echo "Google Delay" | tee $PING_google
echo '> '$(pwd)
cat ${PING_sort} | while read Line
do
	if [ $NUMBER == $1 ]; then
		exit
	fi
	NUMBER=$(expr $NUMBER + 1)
	SSRP2=$(echo $Line | cut -d "/" -f 2)
	echo ""
	echo "---"
	echo "# "$NUMBER" / "$Line | tee -a $PING_google
	$SSR_ConfigBuild $CONF_ssr $SSRP2 > ./run-local.json
	nohup ./ss-local -c ./run-local.json > $RUN_Log &
	sleep 3
	PID=$(ps -ef | grep ss-local | awk 'NR==1{print $2}')
	echo "PID: "$PID
	ps -ef | grep ss-local | awk 'NR==1'
	# cat -n ./ss-local.log
	google=$(curl -o /dev/null -s -w %{time_total} --connect-timeout 2 --max-time 5 --socks5 127.0.0.1:2014 http://www.google.com/generate_204)
	miui=$(curl -o /dev/null -s -w %{time_total} --connect-timeout 2 http://connect.rom.miui.com/generate_204)
	echo "Delay, Google: "$google" / MIUI:"$miui | tee -a $PING_google
	sleep 1
	# pkill -9 "ss-local"
	echo "Kill $PID"
	kill $PID
done

pkill -9 "ss-local"