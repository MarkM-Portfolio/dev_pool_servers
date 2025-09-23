#!/bin/bash

rm expect.sh 2>> /dev/null

declare -a GET_POOL_SERVERS
domain=".cnx.cwp.pnp-hcl.com"
echo -e ""

echo -e "Checking if hosts are reachable..."
## specify range in the loop for lcuato server number ##
for (( i=0; i<=167; i++ )); do
	online=`ping lcauto$i$domain -c 2 >> /dev/null; echo $?`
	if [[ $online -eq 0 ]]; then
		echo -e "\xE2\x9C\x94 lcauto$i$domain"
		GET_POOL_SERVERS+="lcauto$i$domain "
	else
		echo -e "\xE2\x9D\x8C lcauto$i$domain"
	fi
done

echo -e ""
filename=volume_extender.sh

for i in ${GET_POOL_SERVERS[@]}; do
	## deploy extend_volune script to server ##
	echo -e '#!/usr/bin/expect -f' > expect.sh
	echo -e 'spawn scp -o StrictHostKeyChecking=no' $filename 'root@'$i':/tmp' >> expect.sh
	echo -e 'expect "assword: "' >> expect.sh
	echo -e 'send "bvtsecret17\\r"' >> expect.sh
	echo -e 'interact' >> expect.sh
	## execture extend_volune script ##
	echo -e 'spawn ssh -o StrictHostKeyChecking=no root@'$i >> expect.sh
	echo -e 'expect "assword: "' >> expect.sh
	echo -e 'send "bvtsecret17\\r"' >> expect.sh
	echo -e 'expect "#"' >> expect.sh
	echo -e 'send "/tmp/'$filename'\\r"' >> expect.sh
	echo -e 'expect "#"' >> expect.sh
	echo -e 'send "rm -rf /tmp/'$filename'\\r"' >> expect.sh
	## record logs ##
	echo -e 'expect "#"' >> expect.sh
	echo -e 'send "hostname > /tmp/hosts.log\\r"' >> expect.sh
	echo -e 'expect "#"' >> expect.sh
	echo -e 'send "lsblk | grep cl-root >> /tmp/hosts.log\\r"' >> expect.sh
	echo -e 'expect "#"' >> expect.sh
	echo -e 'send "exit\\r"' >> expect.sh
	echo -e 'interact' >> expect.sh
	## send logs to my local ##
	echo -e 'spawn scp -o StrictHostKeyChecking=no root@'$i':/tmp/hosts.log .' >> expect.sh
	echo -e 'expect "assword: "' >> expect.sh
	echo -e 'send "bvtsecret17\\r"' >> expect.sh
	echo -e 'interact' >> expect.sh

	chmod +x expect.sh
	./expect.sh
	rm expect.sh

	cat hosts.log >> records.log
	rm hosts.log
done

echo -e "\n\nDONE...!\n"
