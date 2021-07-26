#!/bin/bash
#Defining all the parameters
BACKUPTIME=`date +%b-%d-%y-%H-%M`
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
if [[ -e /var/log/mysql.log ]]; then
    SQLL=/var/log/mysql.log
elif [[ -e /var/log/mysqld.log ]]; then
    SQLL=/var/log/mysqld.log
fi
SMB=/srv/samba/*
if [[ -d /etc/bind ]]; then
    DNSC=/etc/bind
elif [[ -e /etc/named.conf ]]; then
    DNSC=/etc/named.conf
    DNSD=/var/named
fi
POSTM=/etc/postfix/*
SQLC=/etc/mysql/*
if [[  -d /etc/httpd ]]; then
    HTTPC=/etc/httpd

elif [[ -d /etc/apache2 ]]; then
    HTTPC=/etc/apache2

fi
HTTPD=/var/www
HTTPV=/var/log/httpd
#Grabbing logging info
cp $LASTLOG $HOMELOGS
cp $DMESG $HOMELOGS
cp $AUTH $HOMELOGS
cp $FAIL $HOMELOGS
cp $FAIL2 $HOMELOGS
cp $LASTLOG $HOMELOGS
cp $SQLL $HOMELOGS
cp $LOGOUT $HOMELOGS
if [[ -e $SQLL ]]; then
    cp $SQLL $HOMELOGS
fi
if [[ -e $IPTABLES ]]; then
    cp $IPTABLES $HOMELOGS
fi
#Grabbing service files
if [[ -d $HTTPC ]]; then
    cp -R $HTTPC $HOMESERV
fi
if [[ -d $HTTPD ]]; then 
    cp -R $HTTPD $HOMESERV
fi
if [[ -d $HTTPV ]]; then
    cp -R $HTTPV $HOMESERV
fi 
if [[ -d $SQLC ]]; then
    cp -R $SQLC $HOMESERV
fi
if [[ -d $SMB ]]; then
    cp -R $SMB $HOMESERV
fi
if [[ -d $DNSC ]]; then
    cp -R $DNSC $HOMESERV
fi 
if [[ -d $DNSD ]]; then
    cp -R $DNSD $HOMESERV
fi
if [[ -d $POSTM ]]; then
    cp -R $POSTM $HOMESERV
fi
if [[ -d  $SSHD ]]; then
    cp -R $SSHD $HOMESERV
fi
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
