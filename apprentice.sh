#!/bin/bash
#Defining all the parameters
BACKUPTIME='date +%b-%d-%y-%H-%M'
DESTINATION=/root/secure/backup-$BACKUPTIME.tar.gz
IPTABLES=/etc/sysconfig/network-scripts/iptables.rules
#Check if the secure file exist
if [[  ! -e /root/secure ]]; then
    mkdir -p /root/secure
    chmod 700 /root/secure
fi
HOMESERV=/root/secure/services
HOMELOGS=/root/secure/logs
HOME=/root/secure
DMESG=/var/log/dmesg
AUTH=/var/log/auth.log*
FAIL=/var/log/faillog
FAIL2=/var/log/btmp
LOGOUT=/var/log/wtmp
LASTLOG=/var/log/lastlog
SMB=/srv/samba/*
DNSC=/etc/named/*
POSTM=/etc/postfix/*
SQLC=/etc/mysql/*
if [[ -e /var/log/mysql.log ]]; then
    SQLL=/var/log/mysql.log
elif [[ -e /var/log/mysqld.log ]]; then
    SQLL=/var/log/mysqld.log
fi
if [[  -d /etc/httpd/ ]]; then
    HTTPC=/etc/httpd/*
else
    HTTPC=/etc/apache2/*
fi
HTTPD=/var/www/*
HTTPV=/var/log/httpd/*
#Grabbing logging info
cp $LASTLOG $HOMELOGS
cp $DMESG $HOMELOGS
cp $AUTH $HOMELOGS
cp $FAIL $HOMELOGS
cp $FAIL2 $HOMELOGS
cp $LASTLOG $HOMELOGS
cp $SQLL $HOMELOGS
cp $IPTABLES $HOMELOGS
#Grabbing service files
cp -R $HTTPC $HOMESERV
cp -R $HTTPD $HOMESERV
cp -R $HTTPV $HOMESERV
cp -R $SQLC $HOMESERV
cp -R $SMB $HOMESERV
cp -R $DNSC $HOMESERV
cp -R $POSTM $HOMESERV
tar -cpzf $DESTINATION $HOME #create the backup
chmod 600 $DESTINATION #Apply respecting permissions
#Apply password encryption
PHRASE=$1
ENCFILE=$HOME$BACKUPTIME.encrypt
openssl enc -k $PHRASE -aes-256-cbc -in $DESTINATION -out $ENCFILE #securing files
if [[ -e $ENCFILE ]]; then
    echo "$BACKUPTIME: File encrypted successfully!" >> /root/secure/backlog
else 
    echo "$BACKUPTIME: File encrypted unsuccessfully, check logs for troubleshooting!" >> /root/secure/backlog
fi
