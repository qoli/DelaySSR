#!/bin/bash
IFS_old=$IFS 
clear
echo '> '$(pwd)
CONF="./LogDelay_subscribe_link.txt"
CONF_decode="./LogDelay_subscribe_link_decode.txt"
CONF_ssr="./LogDelay_ssr_list.txt"
PING_log="./LogDelay_working_log.txt"
PING_sort="./LogDelay_working_sort.txt"

ping_test() {
	Config_ip=$(echo $1| cut -c 7-2000 | base64 --decode | awk -F ":" '{print $1}')
	DELAY=$(ping -t 3 ${Config_ip} | grep "min/avg/max/stddev" | awk '{print $4}' | cut -d "/" -f 2)
	# echo $1| cut -c 7-2000
	if [ ! -n "$DELAY" ]; then
		echo "> "$NUMBER"/"${Config_ip}"/timeout"
	else
		echo $(echo $1 | cut -c 7-2000 | base64 --decode)"" >> ${CONF_ssr}
		echo "> "$NUMBER"/"${Config_ip}"/avg(ms)/"${DELAY} | tee -a ${PING_log}
	fi
}

if [ ! -n "$1" ]; then
	echo "usage:"
	echo "	$0 subscribe_link"
	echo "	$0 ssr://"
	echo "	$0 ssr:// ssr://"
	exit
fi

determine=$(echo $1|cut -c 1-4)

rm ${CONF_decode}
rm ${CONF_ssr}
rm ${PING_log}
NUMBER=0
clear
touch ${CONF}

if [ $determine == "ssr:" ]; then
	# SSR Mode
	echo "ssr: mode..."
	# ping_test $1
	IFS=" "
	arr=($1)
	for s in ${arr[@]}
	do
	    echo "$s" >> ${CONF_decode}
	done
	IFS=$IFS_old
	cat -n ${CONF_decode}
else
	# 下載 SSR 訂閱文件
	echo "subscribe link mode..."
	wget -c $1 -O ${CONF}
	base64 --decode ${CONF} > ${CONF_decode}
	rm ${CONF}
fi

for Line in `cat ${CONF_decode}`
do
	NUMBER=$(expr $NUMBER + 1)
	ping_test $Line
done
sleep 5
clear
sort -t / -n -k 4 ${PING_log} > ${PING_sort}
./delay-test.sh 10

