#!/bin/bash

set -e
YAY_DIR="$HOME/yay/"
YAY_URL="https://aur.archlinux.org/yay.git"

echo "Installing Yay"
sudo pacman -S --needed git base-devel
if [ -d "$REPO_DIR" ]; then
  echo -e "${NOTE} Folder ${YAY_DIR} already exists. Skipping clone.${RESET}"
else
  if git clone "$YAY_URL" "$YAY_DIR"; then
    echo -e "${OK} yay cloned successfully to ${REPO_DIR}.${RESET}"
  else
    echo -e "${ERROR} Failed to clone yay repo from ${YAY_URL}.${RESET}"
    exit 1
  fi
fi
cd $YAY_DIR
makepkg -si
cd -
rm -rf $YAY_DIR

echo "Adding blackarch repo"
curl -O https://blackarch.org/strap.sh
sha1sum strap.sh # should match: d062038042c5f141755ea39dbd615e6ff9e23121
sudo chmod +x strap.sh
sudo ./strap.sh
rm strap.sh
yay -Syyu


echo "Installing Packages from list: "
echo $(cat packages.txt)
yay -S --needed --noconfirm - < packages.txt
