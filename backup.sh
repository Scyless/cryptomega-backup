#!/bin/bash

clear
echo Starting...
echo


# Make some shortcuts

export upload='megacopy --config ~/path/to/your/mega/config -r /path/on/mega/'
export rsync='rsync -rulpgoD --temp-dir=/tmp/rsync'
export vault=/media/vault


# Open the Vault

java -jar /path/to/cryptomator-cli/cryptomator-cli-0.3.1.jar \
     --vault vault=/path/to/your/open/vault/ --password vault=yourpassword \
     --bind 127.0.0.1 --port 8080 \
     &> /dev/null &
sleep 1


# Mount the Vault

echo Opening Vault...
yes | \
sudo mount -t davfs -o uid=$USER http://localhost:8080/vault /media/vault/ | printf 0 &> /dev/null


# Locally back the files up, if the vault is NOT mounted, give error message

if pgrep "davfs" > /dev/null
then

$rsync /path/to/Documents $vault/Documents/
echo Documents backed up...

$rsync /path/to/Music $vault/
echo Music backed up...

$rsync /path/to/Pictures $vault/
echo Pictures backed up...

$rsync /path/to/Videos $vault/
echo Videos backed up...

echo
echo Backups done, closing Vault...


# Unmount the Vault
sudo umount /media/vault > /dev/null
pgrep java | xargs kill


echo
echo Starting Upload, this will take some time. Make yourself some tea, yeah?


# Upload the new files
megacopy --config ~/path/to/your/mega/config -r /path/on/mega/ -l /path/to/your/open/vault/


echo
echo All done!

else echo "Can't open Vault, aborting."

fi 
