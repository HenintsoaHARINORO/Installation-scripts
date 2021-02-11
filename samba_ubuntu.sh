##!/bin/sh
sudo apt update
#install samba
sudo apt install samba
#your username  must belong to the system account
sudo smbpasswd -a <enter your username>
#create the folder in which your shared files will be stored and give permissions
sudo mkdir /home/sharedfiles/
sudo chmod -R 777 /home/sharedfiles/
sudo chown -R root:<username> /home/sharedfiles/
#start the samba service
sudo /usr/sbin/service smbd start
#add the following lines at the bottom of the samba configuration files
echo "[sharedfiles]" >> etc/samba/smb.conf
echo "     comment = Samba on Ubuntu" >> etc/samba/smb.conf
echo "     path = /home/sharedfiles" >> etc/samba/smb.conf
echo "     read only = no" >> etc/samba/smb.conf
echo "     browsable = yes" >> etc/samba/smb.conf
#restart the samba service
sudo /usr/sbin/service smbd restart
#then run ngrok
./ngrok tcp 445
#open the file manager and connect to server
#On Windows,open File manager,right-click on This PC and  ->add a network location and follow the steps
smb://<link from ngrok>/sharedfiles/
#an authentification tab will be prompted ,please enter your passwords
#and after ,you will have access to the /home/sharedfiles directory, you can now paste any files there
#verify if all your files have been successfully inserted in the home/sharedfiles/ directory
cd /home/sharedfiles/
ls
#you can add many users and connect to ngrok so that all users can share and access to the shared files remotely


