#!/bin/bash

UserName=sensei
UserPassword=sensei
echo -e "\n===== 1 ===== Add new user ===================================="
sudo adduser $UserName --disabled-password --gecos ""
chpasswd <<<"$UserName:$UserPassword"
echo -e "\n===== 2 ===== Make new user a sudoer =========================="
sudo usermod -aG sudo $UserName
echo -e "\n===== 3 ===== Set the new user as default user ================"
sudo echo -e "[user]\ndefault=$UserName" >> /etc/wsl.conf
echo -e "\n===== 4 ===== Configure the screen displayed on start ========="
sudo echo -e "cd ~\nclear\necho -e \"\033[1;92m\$(printf \"%0.s=\" {1..40})\\\n \$WSL_DISTRO_NAME - \$(lsb_release -d | grep -oP \"Description:\s+\K(.+)\") \\\n\$(printf \"%0.s=\" {1..40})\033[m\\\n\"" >> /home/$UserName/.profile
echo -e "\n===== 5 ===== Update the distro and upgrade, clean ... ========"
sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove && sudo apt -y autoclean
echo -e "\n==============================================================="
echo -e "\nSetup completed. Please exit, terminate and restart the distro"
echo -e "\n==============================================================="