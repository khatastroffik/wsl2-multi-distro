#!/bin/bash

newuser=sensei
echo -e "\n===== 1 ===== Add new user ===================================="
sudo adduser $newuser
#sudo passwd $newuser
echo -e "\n===== 2 ===== Make new user a sudoer =========================="
sudo usermod -aG sudo $newuser
echo -e "\n===== 3 ===== Set the new user as default user ================"
sudo echo -e "[user]\ndefault=$newuser" >> /etc/wsl.conf
echo -e "\n===== 4 ===== Configure the screen displayed on start ========="
# echo -e "cd ~\nclear\necho -e \"\033[7;92m\$(printf \"%0.s=\" {1..40}) \$WSL_DISTRO_NAME - \$(lsb_release -d | grep -oP \"Description:\s+\K(.+)\") \$(printf \"%0.s=\" {1..40})\033[m\"" >> ~/.profile
# echo -e "cd ~\nclear\necho -e \"\\\n\033[7;92m\$(printf \"%0.s=\" {1..40}) \$WSL_DISTRO_NAME - \$(lsb_release -d | grep -oP \"Description:\s+\K(.+)\") \$(printf \"%0.s=\" {1..40})\033[m\\\n\"" >> ~/.profile
sudo echo -e "cd ~\nclear\necho -e \"\033[1;92m\$(printf \"%0.s=\" {1..40})\\\n \$WSL_DISTRO_NAME - \$(lsb_release -d | grep -oP \"Description:\s+\K(.+)\") \\\n\$(printf \"%0.s=\" {1..40})\033[m\\\n\"" >> /home/$newuser/.profile
echo "\n===== 5 ===== Update the distro and upgrade, clean ... ========"
sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoremove && sudo apt -y autoclean
