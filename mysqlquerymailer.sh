#!/bin/bash
#define configdir
configpath=/etc/mysqlquerymailer
#define email file
configfile=${configpath}/email
#define qry numberfile
qryfile=${configpath}/qrynmb
#get date
DATE=`date +%Y-%m-%d`
#reads valeus of files
nmb=`cat $qryfile`
email=`cat $configfile`

#ask for $nmb of slow queries and sends as mail.
mysqldumpslow -a -s r -t $nmb /var/log/mysql/mysql-slow.log | mail -s "Slowest $nmb queries of $DATE" $email
