#!/bin/bash
#pythonpre requisite
#sudo apt-get install python-serial
echo first of all update all packages on the pi
#sudo apt-get update
#sudo apt-get upgrade
if ( ! dpkg -s python-serial 2> /dev/null | grep Status); then
echo python serial not installed, installing it
sudo apt-get install python-serial
fi

echo check if fhem is installed
if ( dpkg -s fhem 2> /dev/null | grep Status); then
	echo FHEM is already installed
else
   while [ "$OK" != "1" ]; do
	echo FHEM is not installed do you want it to be installed "(Y/N)" ?
	read -n 1 INST
	if [ "$INST" = "Y" ]; then
		echo " installing it"
		echo Installation of FHEM, getting certificate
		wget --no-check-certificate -qO - https://debian.fhem.de/archive.key | sudo apt-key add -
		if (! grep -q fhem /etc/apt/sources.list ); then
			echo add source in apt source file
			echo "deb https://debian.fhem.de/stable ./" | sudo tee -a /etc/apt/sources.list
		fi
		echo Check if apt-transport-https is installed
		if ( ! dpkg -s apt-transport-https 2> /dev/null | grep Status ); then
			echo add https transport
			sudo apt-get install apt-transport-https
		fi
		echo installing fhem package
		sudo apt-get install fhem
		OK="1"
	elif [ "$INST" != "N" ]; then
		echo " reply Y or N please"
	else
		OK="1"
	fi
   done
fi
echo configuring the station
./config.py

echo patching inittab
sed -i '/server.py/ c\vm:2345:respawn:\/home\/pi\/raspVMC-master\/server.py >>\/var\/log\/VMCerr.log 2>\&1/' /etc/inittab
sudo init q
echo cleanup
rm raspVMC.zip
exit
