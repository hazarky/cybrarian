#!/bin/bash
#Defining all the parameters
BACKUPTIME=`date +%b-%d-%y-%H-%M`
DESTINATION=/root/secure/backup-$BACKUPTIME.tar.gz
IPTABLES=/etc/sysconfig/network-scripts/iptables.rules
#Check if the tree is there
if [[  ! -e /root/secure ]]; then
    mkdir -p /root/secure
    chmod 700 /root/secure
fi
HOMESERV=/root/secure/services #For running services
HOMELOGS=/root/secure/logs #For logging information
HOME=/root/secure
#Make the necessary branches of the tree
if [[ ! -d $HOMESERV ]]; then
    mkdir -p $HOMESERV
fi
if [[ ! -d $HOMELOGS ]]; then
    mkdir -p $HOMELOGS
fi
#Logging variables
DMESG=/var/log/dmesg
AUTH=/var/log/auth.log*
FAIL=/var/log/faillog
FAIL2=/var/log/btmp
LOGOUT=/var/log/wtmp
LASTLOG=/var/log/lastlog
SMB=/srv/samba
if [[ -e /var/log/mysql.log ]]; then
    SQLL=/var/log/mysql.log
elif [[ -e /var/log/mysqld.log ]]; then
    SQLL=/var/log/mysqld.log
fi
#Directory variables
DNSC=/etc/bind
POSTM=/etc/postfix
if [[ -d /etc/bind ]]; then
    DNSC=/etc/bind
elif [[ -e /etc/named.conf ]]; then
    DNSC=/etc/named.conf
    DNSD=/var/named
fi
SQLC=/etc/mysql
if [[ -d /etc/httpd ]]; then
        HTTPC=/etc/httpd
        HTTPD=/var/www
        HTTPV=/var/log/httpd
elif [[ -d /etc/apache ]]; then
        HTTPC=/etc/apache
        HTTPD=/var/www
        HTTPV=/var/log/httpd
fi
SSHD=/etc/ssh
#decryption directory
CODEDIR=/root/.parent
CODESERV=/root/secure/services
if [[ ! -d $CODEDIR ]]; then
     mkdir -p $CODEDIR
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
        echo "Enter encrypted passphrase for $DESTINATION: "
        read PHRASE
        ENCFILE=$HOME$BACKUPTIME.encrypt
        if [[ -e /usr/bin/openssl ]]; then
            #openssl enc -k $PHRASE -aes-256-cbc -in $DESTINATION -out $ENCFILE #securing folder
            openssl aes-256-cbc -salt -in $DESTINATION -out $ENCFILE -base64 -k $PHRASE

        fi
        #if [[ -e /usr/bin/gpg ]]; then
        #    gpg --passphrase $PHRASE -d $FILENAME >> $ENCFILE
        #else
        #    openssl enc -k $PHRASE -aes-256-cbc -in $DESTINATION -out $ENCFILE #securing folder
        #fi 
        if [[ -e $ENCFILE ]]; then
            echo "File encrypted successfully!"
        else
            echo "File encrypted unsuccessfully, check logs for troubleshooting!"
        fi 

        #Securely move the encrypted backup over to another target
        echo "Do you want to secure copy the backup?(Y/N)"
        read OP1 
        if [[ $OP1 == "Y" ]]; then
            echo "Please enter username, ip address, and remote directory of the target: "
            read NAME ADDRESS DIRECT
            scp $ENCFILE $NAME@$ADDRESS:$DIRECT
            echo "Secure Copy Completed"
        fi
        echo "Exiting now!"

    elif [[ $CHOICE -eq 2 ]]; then #2: Manually Backup and Implment an automated script
        #Grabbing logging info
        cp $LASTLOG $HOMELOGS
        cp $DMESG $HOMELOGS
        cp $AUTH $HOMELOGS
        cp $FAIL $HOMELOGS
        cp $FAIL2 $HOMELOGS
        cp $LASTLOG $HOMELOGS
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
        chmod 600 $DESTINAITON #Apply respecting permissions
        #Apply password encryption
        echo 'Enter encrypted passphrase for $DESTINATION (This will be used for reoccuring backups):  '
        read PHRASE
        ENCFILE=$HOME$BACKUPTIME.encrypt
        #if [[ -e /usr/bin/gpg ]]; then
        #    gpg --passphrase $PHRASE -c $FILENAME 
        #else #insecure due to padding issues
        #    openssl enc -k $PHRASE -aes-256-cbc -in $DESTINATION -out $ENCFILE #securing files
        #fi
        if [[ -e /usr/bin/openssl ]]; then
            #openssl enc -k $PHRASE -aes-256-cbc -in $DESTINATION -out $ENCFILE #securing folder
            openssl aes-256-cbc -salt -in $DESTINATION -out $ENCFILE -base64 -k $PHRASE
        fi
        if [[ -e $ENCFILE ]]; then
            echo "File encrypted successfully!"
        else 
            echo "File encrypted unsuccessfully, check logs for troubleshooting!"
        fi 

        #Securely move the encrypted backup over to another target
        echo "Do you want to secure copy the backup?(Y/N)"
        read OP1 
        if [[ $OP1 == "Y" ]]; then
             echo "Please enter username, ip address, and remote directory (absolute path) of the target: "
            read NAME ADDRESS DIRECT
            scp $ENCFILE $NAME@$ADDRESS:$DIRECT
            echo "Secure Copy Completed"
        fi
        chmod 700 $CODEDIR/childbackup.sh
        touch /var/spool/cron/root
        /usr/bin/crontab /var/spool/cron/root
        echo "*/15 * * * * /usr/bash/ $HOME$CODEDIR/childbackup.sh $PHRASE >> /var/spool/cron/root"

    elif [[ $CHOICE -eq 3 ]]; then
        echo "Please enter the backup file to implement: "
        read -r FILENAME
        #if [[ -e /usr/bin/gpg ]]; thens
        #    gpg --passphrase $PHRASE -d $FILENAME >> $CODEDIR/decrypt.tar.gz
        #else #insecure due to padding issues
        #    openssl aes-256-cbc -d -a -in $FILENAME -out $CODEDIR/decrypt.tar.gz -k $PHRASE #decrypt the file
        #fi
        echo $FILENAME
        if [[ -e /usr/bin/openssl ]]; then 
            #openssl aes-256-cbc -d -a -in $FILENAME -out $CODEDIR/decrypt.tar.gz -k $PHRASE #decrypt the file
            openssl enc -d -aes-256-cbc -a -in $FILENAME -out $CODEDIR/decrypt.tar.gz 
        fi
        tar -xf $CODEDIR/decrypt.tar.gz -C $CODEDIR
        #Pushing services and reseting them
        if [[ -d $HTTPC ]]; then
            rm -rf $HTTPC && cp -R $CODEDIR$CODESERV/httpd $HTTPC
            echo "Implementing $HTTPC"
            service httpd restart
            systemctl httpd restart
        elif [[ -d $HTTPD ]]; then
            rm -rf $HTTPD && cp -R $CODEDIR$CODESERV/www $HTTPD
            echo "Implementing $HTTPD"
            service httpd restart
            systemctl restart httpd
        elif [[ -d $POSTM ]]; then
            echo "Implementing $POSTM"
            rm -rf $POSTM && cp -R $CODEDIR$CODESERV/postfix $POSTM
            postfix reload
        elif [[ -d $SSHD ]]; then
            echo "Implementing $SSHD"
            rm -rf $SSHD && cp -R $CODEDIR$CODESERV/ssh $SSHD
            systemctl restart ssh
            service ssh restart
        elif [[ -d $SMB ]]; then
            echo "Implementing $SMB"
            rm -rf $SMB && cp -R $CODEDIR$CODESERV/samba $SMB
            service smb restart
            systemctl restart smb.service
            systemctl restart nmb.service
        elif [[ -d $DNSC ]]; then
            if [[ -d /etc/bind ]]; then
                echo "Implementing $DNSC"
                rm -rf $DNSC && cp -R $CODEDIR$CODESERV/named.conf $DNSC
            elif [[ -e /etc/named.conf ]]; then
                echo "Implementing $DNSC" 
                rm -rf $DNSC && cp $CODEDIR$CODESERV/named.conf $DNSC
                rm -rf $DNSD && cp -R $CODEDIR$CODESERV/named $DNSD
            fi
        elif [[ -d /etc/mysql ]]; then
            echo "Implementing $SQLC"
            rm -rf $SQLC && cp -R $CODEDIR$CODESERV/mysql $SQLC
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
