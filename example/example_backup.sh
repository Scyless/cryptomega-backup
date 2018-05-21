#!/bin/bash

clear
echo Starting...
echo


# Make some shortcuts

export upload='megacopy --config ~/.config/mega/config -r /Root/Cloud/'
export rsync='rsync -rulpgoD --temp-dir=/tmp/rsync'
export vault=/media/vault
export veracrypt=/media/veracrypt1


# Open the Vault

java -jar ~/cryptomator-cli/cryptomator-cli-0.3.1.jar \
     --vault Stuff=$veracrypt/Vaults/Stuff/ --password Stuff=mypassword \
     --bind 127.0.0.1 --port 8080 \
     &> /dev/null &
sleep 1


# Mount the Vault

echo Opening Vault...
yes | \
sudo mount -t davfs -o uid=$USER http://localhost:8080/Stuff /media/vault/ | printf 0 &> /dev/null


# Locally back the files up, if the vault is NOT mounted, give error message

if pgrep "davfs" > /dev/null
then

$rsync $HOME/Documents/ $veracrypt/Documents/arch/ &> /dev/null
echo Documents moved... 

$rsync $veracrypt/Documents/arch $vault/Documents/
echo Documents backed up...

$rsync $veracrypt/Music $vault/
echo Music backed up...

$rsync $veracrypt/Pictures $vault/
echo Pictures backed up...

$rsync $veracrypt/Videos $vault/
echo Videos backed up...

echo
echo Backups done, closing Vault...


# Unmount the Vault
sudo umount /media/vault > /dev/null
pgrep java | xargs kill


echo
echo Starting Upload, this will take some time. Make yourself some tea, yeah?


# Upload the new files
megacopy --config $HOME/.config/mega/config -r /Root/Cloud/ -l $veracrypt/Vaults/


echo
echo All done!

else echo "Can't open Vault, aborting."

fi 
