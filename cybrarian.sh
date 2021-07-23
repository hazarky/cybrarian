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
SMB=/srv/samba
DNSC=/etc/bind
if [[ -d /etc/bind ]]; then
    DNSC=/etc/bind
elif [[ -e /etc/named.conf ]]; then
    DNSC=/etc/named.conf
    DNSD=/var/named
fi
POSTM=/etc/postfix
SQLC=/etc/mysql
if [[ -e /var/log/mysql.log ]]; then
    SQLL=/var/log/mysql.log
elif [[ -e /var/log/mysqld.log ]]; then
    SQLL=/var/log/mysqld.log
fi
echo "What distro is being used? (ubuntu/centos)"
read dist 
echo 
if [[ $dist == ubuntu ]]; then
        HTTPC=/etc/httpd
        HTTPD=/var/www
        HTTPV=/var/log/httpd
elif [[ $dist == centos ]]; then
        HTTPC=/etc/apache
        HTTPD=/var/www
        HTTPV=/var/log/httpd
fi
#Accepting Options
options(){
    if [[ $CHOICE -eq 0 ]]; then
        echo "Exiting now!"
    elif [[ $CHOICE -eq 1 ]]; then #1: Manually Backup Files
        #Grabbing logging info
        cp $LASTLOG $HOMELOGS
        cp $DMESG $HOMELOGS
        cp $AUTH $HOMELOGS
        cp $FAIL $HOMELOGS
        cp $FAIL2 $HOMELOGS
        cp $LASTLOG $HOMELOGS
        cp $SQLL $HOMELOGS
        #Grabbing service files
        cp -R $HTTPC $HOMESERV
        cp -R $HTTPD $HOMESERV
        cp -R $HTTPV $HOMESERV
        cp -R $SQLC $HOMESERV
        cp -R $SMB $HOMESERV
        cp -R $DNSC $HOMESERV
        cp -R $DNSD $HOMESERV
        cp -R $POSTM $HOMESERV
        tar -cpzf $DESTINATION $HOME #create the backup
        chmod 600 $DESTINATION #Apply respecting permissions
        #Apply password encryption
        echo 'Enter encrypted passphrase for $DESTINATION: '
        read PHRASE
        ENCFILE=$HOME$BACKUPTIME.encrypt
        if [[ -e /usr/bin/gpg ]]; then
            gpg --passphrase $PHRASE -d $FILENAME >> $ENCFILE
        else
            openssl enc -k $PHRASE -aes-256-cbc -in $DESTINATION -out $ENCFILE #securing folder
        fi 
        if [[ -e $ENCFILE ]]; then
            echo "File encrypted successfully!"
        else
            echo "File encrypted unsuccessfully, check logs for troubleshooting!"
        fi 

        #Securely move the encrypted backup over to another target
        echo "Please enter username, ip address, and remote directory of the target: "
        read NAME ADDRESS DIRECT
        scp $ENCFILE $NAME@$ADDRESS:$DIRECT
        echo "Secure Copy Completed"


    elif [[ $CHOICE -eq 2 ]]; then #2: Manually Backup and Implment an automated script
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
        cp -R $DNSD $HOMESERV
        cp -R $POSTM $HOMESERV
        tar -cpzf $DESTINATION $HOME #create the backup
        chmod 600 $DESTINAITON #Apply respecting permissions
        #Apply password encryption
        echo 'Enter encrypted passphrase for $DESTINATION (This will be used for reoccuring backups):  '
        read PHRASE
        ENCFILE=$HOME$BACKUPTIME.encrypt
        if [[ -e /usr/bin/gpg ]]; then
            gpg --passphrase $PHRASE -c $FILENAME 
        else #insecure due to padding issues
            openssl enc -k $PHRASE -aes-256-cbc -in $DESTINATION -out $ENCFILE #securing files
        fi
        if [[ -e $ENCFILE ]]; then
            echo "File encrypted successfully!"
        else 
            echo "File encrypted unsuccessfully, check logs for troubleshooting!"
        fi 

        #Securely move the encrypted backup over to another target
        echo "Please enter username, ip address, and remote directory (absolute path) of the target: "
        read NAME ADDRESS DIRECT
        scp $ENCFILE $NAME@$ADDRESS:$DIRECT
        echo "Secure Copy Completed"
        chmod 750 childbackup.sh
        touch /var/spool/cron/root
        /usr/bin/crontab /var/spool/cron/root
        echo "*/15 * * * * /usr/bash/ $HOME/childbackup.sh $PHRASE >> /var/spool/cron/root"

    elif [[ $CHOICE -eq 3 ]]; then
        CODEDIR=/root/.parent
        echo "Please enter the backup file to implement and the passphrase: "
        read -r FILENAME, PHRASE
        mkdir -P $CODEDIR
        if [[ -e /usr/bin/gpg ]]; then
            gpg --passphrase $PHRASE -d $FILENAME >> $CODEDIR/decrypt.tar.gz
        else #insecure due to padding issues
            openssl aes-256-cbc -d -a -in $FILENAME -out $CODEDIR/decrypt.tar.gz -k $PHRASE #decrypt the file
        fi
        tar -xf $CODEDIR/decrypt.tar.gz
        #Pushing services and reseting them
        if [[ -d $HTTPC ]]; then
            rm -rf $HTTPC && cp -R $CODEDIR/secure/httpd $HTTPC
            service httpd restart
            systemctl httpd restart
        elif [[ -d $HTTPD ]]; then
            rm -rf $HTTPD && cp -R $CODEDIR/secure/www $HTTPD
            service httpd restart
            systemctl restart httpd
        elif [[ -d $POSTM ]]; then
            rm -rf $POSTM && cp -R $CODEDIR/secure/postfix $POSTM
            postfix reload
        elif [[ -d $SMB ]]; then
            rm -rf $SMB && cp -R $CODEDIR/secure/samba $SMB
            service smb restart
            systemctl restart smb.service
            systemctl restart nmb.service
        elif [[ -d $DNSC ]]; then
            if [[ -d /etc/bind ]]; then
                rm -rf $DNSC && cp -R $CODEDIR/secure/named.conf $DNSC
            elif [[ -e /etc/named.conf ]]; then 
                rm -rf $DNSC && cp $CODEDIR/secure/named.conf $DNSC
                rm -rf $DNSD && cp -R $CODEDIR/secure/named $DNSD
            fi
        elif [[ -d /etc/mysql ]]; then
            rm -rf $SQLC && cp -R $CODEDIR/secure/mysql $SQLC
        else
            echo "No known service implemented on the system. Check logging for details!"
        fi
        echo "Backup has been implemented on to the system!"
    fi
}
echo "1: Manually Backup Files"
echo "2: Manually Backup and Implment an automated script"
echo "3: Implement restore of a backup"
echo "0: Exit"
read CHOICE
options choice
