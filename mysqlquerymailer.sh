#!/bin/bash
#Define configpath
configpath=/etc/mysqlquerymailer
#file to store email
configfile=${configpath}/email
#encrypted config file
encconfigfile=${configpath}
#file to store number of queries
qryfile=${configpath}/qrynmb
#Keydirectory
keydir=${configpath}/keys
#dir with the privatekey
privkeydir=${keydir}/.private
#dir with the publickey
pubkeydir=${keydir}/public
#the public key
pubkey=${pubkeydir}/public_key.pem
#the private key
privkey=${privkeydir}/private_key.pem
#get date
DATE=`date +%Y-%m-%d`

#decrypt the config file
openssl rsautl -decrypt -inkey $privkey -in $encconfigfile -out $configfile

#read query numbers and the email address
nmb=`cat $qryfile`
email=`cat $configfile`


#ask for $nmb of slow queries and sends as mail.
mysqldumpslow -a -s r -t $nmb /var/log/mysql/mysql-slow.log | mail -s "Slowest $nmb queries of $DATE" $email
