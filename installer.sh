#!/bin/bash
#Define configpath
configpath=/etc/mysqlquerymailer
#file to store email
configfile=${configpath}/email
#file to store number of queries
qryfile=${configpath}/qrynmb
#Keydirectory
keydir=${configpath}/keys
#dir with the privatekey
privkeydir=${keydir}/.private
#dir with the publickey
pubkeydir=${keydir}/public
pubkey=${pubkeydir}/public_key.pem
privkey=${privkeydir}/private_key.pem

function instellation {
#create dirs if not exist
mkdir -p $configpath
mkdir -p $keydir
mkdir -p $privkeydir
mkdir -p $pubkeydir
touch $qryfile
#moves script to /bin/
mv mysqlquerymailer.sh /bin/mysqlquerymailer
#make script executeable
chmod +x /bin/mysqlquerymailer



}


function encryptCredentials {
	#Encrypts mysql-User credentials
	#File to encrypt
	file=$1
	#encrypt file with public key
	openssl rsautl -encrypt -inkey $pubkey -pubin -in $file -out ${file}.encrypted	
	
}


function generateKey {
	#Generates keypair
	#Ask if key pair exist.
	read -p "Do you need a keypair (only on first installation)? [Y/n] " needkey
	if [[ -z "$needkey" ]] || [[ $needkey == "Y" ]] || [[ $needkey == "y" ]]; then
		#Generate private key
		openssl genpkey -algorithm RSA -out ${privkeydir}/private_key.pem -pkeyopt rsa_keygen_bits:2048
		
		#Generate public key
		openssl rsa -pubout -in ${privkeydir}/private_key.pem -out ${pubkeydir}/public_key.pem	
	
	elif [[ $needkey == "n" ]] || [[ $needkey == "N" ]]; then
		#Do nothing
		echo "No keys generated"
		return
	
	else
		#Ask again
		generateKey
		return
	fi

}
function credentials {
	#Save mysql credentials
	#Generates keys
	generateKey
	#set key values
	privkey=${privkeydir}/private_key.pem
	pubkey=${pubkeydir}/public_key.pem
	#ask for credentials and saves to value
	#ask for mail
	read -p "Write your email adress: " emailadress
	#store mail
	echo $emailadress > $configfile
	#ask number of qry
	read -p "How many queries do you want to recive? " qry
	#store nmb of qry
	echo $qry > $qryfile
	echo ''
	#save credentials to file
	
	#encrypt credentials
	encryptCredentials /$configfile
	
	rm $configfile
	
	
		
}

function registerCronjob {

#make file
touch mycron
#write cronjob to file
echo "0 0 * * * /bin/mysqlquerymailer" > mycron
#register cronjob
crontab mycron
#remove file
rm -f mycron


}





function _start {
	#starts here
	#full instellation or just new mysql-credentials'
	read -p "Do you want a complete instellation or just update the credentials? [C/u] " choice
	if [[ -z "$choice" ]] || [[ $choice == "c" ]] || [[ $choice == "C" ]]; then
		#perform full isntellation
		instellation
		credentials
		registerCronjob
	
	elif [[ $choice == "u" ]] || [[ $choice == "U" ]]; then
		#change credentials
		credentials
	
	else
		#start again
		_start
		return
	fi
	
}


_start
