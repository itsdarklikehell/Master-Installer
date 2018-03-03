#!/bin/bash
CONFIG(){
	whiptail --title "Master-Installer" --msgbox "Welcome to Master-Installer by rizzo." 8 78
	#sudo apt-get update && sudo apt-get upgrade -y
	clonedir=$HOME
	masterurl="https://github.com/itsdarklikehell"
	CLONE="git clone $masterurl"
}

RETROPIE-SETUP(){
	cd $clonedir
    sudo apt-get install git lsb-release
	git clone --depth=1 https://github.com/RetroPie/RetroPie-Setup.git
	cd RetroPie-Setup
    chmod +x retropie_setup.sh
    sudo ./retropie_setup.sh
}
RETROPIE-CUSTOMIZED(){
	
	echo "Checking for custom es_systems.cfg"
	file=/opt/retropie/configs/all/emulationstation/es_systems.cfg
	if [ -e "$file" ]; then
	echo "Custom es_systems.cfg found in /opt/retropie/configs/all/emulationstation/ making backup in /opt/retropie/configs/all/emulationstation/es_systems.cfg /opt/retropie/configs/all/emulationstation/es_systems.old!"
	sudo cp /opt/retropie/configs/all/emulationstation/es_systems.cfg /opt/retropie/configs/all/emulationstation/es_systems.old
	else 
    echo "Custom es_systems.cfg does not exist, creating"
    sudo cp /etc/emulationstation/es_systems.cfg /opt/retropie/configs/all/emulationstation/es_systems.cfg
    fi
    
    echo "Checking for custom theme"
    file=/opt/retropie/configs/all/emulationstation/themes/carbon-custom
    if [ -e "$file" ]; then
    echo "Custom theme found in /opt/retropie/configs/all/emulationstation/themes/carbon-custom making backup in /opt/retropie/configs/all/emulationstation/themes/carbon-custom /opt/retropie/configs/all/emulationstation/themes/carbon-custom.old"
    sudo cp -R /opt/retropie/configs/all/emulationstation/themes/carbon-custom /opt/retropie/configs/all/emulationstation/themes/carbn-custom.old
    else
    echo "Custom theme does not exist, creating"
    sudo cp -R /etc/emulationstation/themes/carbon /opt/retropie/configs/all/emulationstation/themes/carbon-custom
    fi
    echo "Customization is now done."
	echo "You can now add systems to /opt/retropie/configs/all/emulationstation/es_systems.cfg"
	echo "And you can now modify the custom-carbon theme and select it in emulationstation to use it."
}
CREATE_AP(){
cd $clonedir
$CLONE/create_ap
sudo apt-get install bash util-linux procps hostapd iproute2 iw haveged dnsmasq iptables
cd create_ap
sudo make install
sudo nano /etc/create_ap.conf
sudo nano /etc/network/interfaces
sudo systemctl start create_ap
sudo systemctl enable create_ap
}
AFTER-BURNER(){
cd $clonedir
$CLONE/raspbian-after-burner
echo "still needs configuring"
}

RETROPIE-BIOS-FILES(){
cd $clonedir
$CLONE/RetroPie-Bios-Files
echo "still needs configuring"
}

RETROPIE-BGM(){
	cd $clonedir
	$CLONE/RetroPie-Bgm
	cd RetroPie-Bgm
	sudo apt-get install -y python-pygame
	
	echo "creating music dir in: ~/RetroPie/roms/music"
	mkdir -p ~/RetroPie/roms/music
	echo "please put some music in it..."
	read -rsp $'Press any key to continue...\n' -n 1 key
	
	echo "edit /etc/rc.local"
	echo "Above exit 0, put the following code:"
	echo ""
	echo "(sudo python $HOME/RetroPie-Bgm/Bgm-Player.py) &"
	echo ""
	read -rsp $'Press any key to continue...\n' -n 1 key
	sudo nano /etc/rc.local
	
	echo "Setting up EmulationStation menu options..."
	cp -R bgm /opt/retropie/configs/all/emulationstation/themes/carbon-custom/bgm
	mkdir -p /opt/retropie/configs/bgm
	cp es_systems.cfg /opt/retropie/configs/bgm/es_systems.cfg
	cp emulators.cfg /opt/retropie/configs/bgm/emulators.cfg
	echo "Please edit /opt/retropie/configs/all/emulationstation/es_systems.cfg so that is includes the following:"
	cat bgm/es_systems.cfg
	read -rsp $'Press any key to continue...\n' -n 1 key
	
	echo "Final 'test' phase..."
	bash start-player.sh &
	echo "If emulationstation is running and there is music in your $HOME/RartoPie/roms/music dir you shoud hear it playing now."
}

RETROPIE-ROM-USB(){
	df
	echo "Please specify where your roms should be stored e.g. /dev/usb0"
	read USBMOUNT
	clear
	
	echo "moving files from $HOME/RetroPie to $USBMOUNT"
	sudo mv -v $HOME/RetroPie/* $USBMOUNT
	clear
	
	echo "Setting up fstab mount point"
	ls -l /dev/disk/by-uuid/
	echo "Please specify the UUID of the drive. e.g. E44B-FC4E or 7cc81461-50b9-45a8-a561-fd5c4aa71934"
	read UUID
	echo "Creating fstab mount point so that your usb gets mounted as $HOME/RetroPie"
	sudo echo "UUID=$UUID  $HOME/RetroPie      vfat    rw,exec,uid=pi,gid=pi,umask=022 0       2" >> /etc/fstab
	sudo echo "" >> /etc/fstab     # make sure there is an empty line at the end of fstab
	echo "Please do a full reboot to start using the new storage location in emulationstation."
}

RETROPIE-INTERNET-RADIO(){
	PLAYER="vlc"
	cd $clonedir
	$CLONE/RetroPie-Internet-Radio
	cd RetroPie-Internet-Radio
	
	echo "Installing dependencies"
	sudo apt-get install -y $PLAYER
	
	echo "Installing to $HOME/RetroPie/roms/radio"
	cp -R radio $HOME/RetroPie/roms/radio
	
	echo "Setting up EmulationStation menu options..."
    cp -R theme /opt/retropie/configs/all/emulationstation/themes/carbon-custom/radio
    mkdir -p /opt/retropie/configs/radio
    cp menu/es_systems.cfg /opt/retropie/configs/radio/es_systems.cfg
    cp menu/emulators.cfg /opt/retropie/configs/bgm/emulators.cfg
    
    echo "Please edit /opt/retropie/configs/all/emulationstation/es_systems.cfg so that is includes the following:"
    cat menu/es_systems.cfg
    read -rsp $'Press any key to continue...\n' -n 1 key
}


BASH_ALIASES(){
cd $clonedir
$CLONE/bash_aliases
cd bash_aliases
cp $HOME/.bash_aliases $HOME/.bash_aliases_old
cp .bash_aliases $HOME
source $HOME/.bash_aliases
}

INSTALL(){
	option=$(whiptail --title "Check list" --checklist \
	"Choose what to install" 20 78 4 \
	"BASH_ALIASES" "Bash aliases" ON \
	"CREATE_AP" "Create AP" ON \
	"RETROPIE-SETUP" "RetroPie setup Script" ON \
	"RETROPIE-CUSTOMIZED" "Custom Retropie theme and menus" ON \
	"RETROPIE-ROM-USB" "RetroPie Roms on USB" ON \
	"RETROPIE-INTERNET-RADIO" "RetroPie Internet Radio" ON \
	"RETROPIE-BGM" "RetroPie Background Music" ON \
	"RETROPIE-BIOS-FILES" "RetroPie BIOS files" ON \
	"AFTER-BURNER" "raspbian after burner script" ON 3>&1 1>&2 2>&3)
	if [[ $option = *"BASH_ALIASES"* ]];
	then
	BASH_ALIASES
	fi
		if [[ $option = *"CREATE_AP"* ]];
	then
	CREATE_AP
	fi
	if [[ $option = *"RETROPIE-SETUP"* ]];
	then
	RETROPIE-SETUP
	fi
	if [[ $option = *"RETROPIE-CUSTOMIZED"* ]];
	then
	RETROPIE-CUSTOMIZED
	fi
	if [[ $option = *"RETROPIE-ROM-USB"* ]];
	then
	RETROPIE-ROM-USB
	fi
	if [[ $option = *"RETROPIE-INTERNET-RADIO"* ]];
	then
	RETROPIE-INTERNET-RADIO
	fi
	if [[ $option = *"RETROPIE-BGM"* ]];
	then
	RETROPIE-BGM
	fi
	if [[ $option = *"RETROPIE-BIOS-FILES"* ]];
	then
	RETROPIE-BGM
	fi
	if [[ $option = *"AFTER-BURNER"* ]];
	then
	AFTER-BURNER
	fi
}
REMBLOAT(){
	REMOVE="sudo apt-get remove --purge "
	# Remove bloatware (Wolfram Engine, Libre Office, Minecraft Pi, sonic-pi dillo gpicview penguinspuzzle oracle-java8-jdk openjdk-7-jre oracle-java7-jdk openjdk-8-jre)
	echo "Removing wolfram-engine"
	$REMOVE wolfram-engine 
	
	echo "Removing wolfram-engine"
	$REMOVE libreoffice*
	
	echo "Removing scratch"
	$REMOVE scratch
	
	echo "Removing minecraft-pi"
	$REMOVE minecraft-pi
	
	echo "Removing sonic-pi"
	$REMOVE sonic-pi
	
	echo "Removing dillo"
	$REMOVE dillo
	
	#echo "Removing gpicview"
	# $REMOVE gpicview  ## WARNING: also removes lxde desktop!
	
	echo "Removing penguinspuzzle"
	$REMOVE penguinspuzzle
	
	echo "Removing oracle-java8-jdk"
	$REMOVE oracle-java8-jdk
	
	echo "Removing openjdk-7-jre"
	$REMOVE openjdk-7-jre
	
	echo "Removing oracle-java7-jdk"
	$REMOVE oracle-java7-jdk
	
	echo "Removing openjdk-8-jre"
	$REMOVE openjdk-8-jre
	
	echo "Cleaning up"	
	# Autoremove
	sudo apt-get autoremove -y
	# Clean
	sudo apt-get autoclean -y
	
	echo "Updating"
	# Update
	sudo apt-get update && sudo apt-get upgrade -y
}
MENU(){
	option=$(whiptail --title "Menu" --menu "Choose an option" 25 78 16 \
	"INSTALL" "Install software." \
	"REMBLOAT" "Remove bloatware." 3>&1 1>&2 2>&3)
	if [[ $option = INSTALL ]]; then
	INSTALL
	fi
	if [[ $option = REMBLOAT ]]; then
	REMBLOAT
	fi 

}
CONFIG
if (whiptail --title "Warning!" --yesno "Warning use this scrip with caution, press no to cancel now." 8 78) then
    echo "User selected Yes, exit status was $?."
    MENU
else
    echo "User selected No, exit status was $?."
    exit
fi
