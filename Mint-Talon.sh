#!/bin/bash
set -euo pipefail

# Log everything
exec > >(tee -i linux-mint-talon.log)
exec 2>&1

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root → sudo $0"
  exit 1
fi

USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

echo "Updating system..."
apt update && apt upgrade -y

echo "Installing core tools and libraries..."
apt install -y curl jq flatpak preload vlc ffmpeg software-properties-common xdg-desktop-portal xdg-desktop-portal-gtk

# Ensure Mint Flatpak integration (Mint already ships it but we enforce)
echo "Ensuring Flatpak + Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Firefox (Mint uses its own repo-build Firefox ESR)
read -rp "Replace Mint Firefox ESR with another browser? (y/n): " replace_ff
if [[ $replace_ff =~ ^[Yy]$ ]]; then
  echo "1) Brave   2) LibreWolf   3) Hardened Firefox (Flatpak)"
  select browser in Brave LibreWolf "Hardened Firefox"; do
    case $browser in
      Brave)
        apt remove --purge -y firefox firefox-locale-en || true
        apt autoremove -y
        curl -fsSLo /usr/share/keyrings/brave-browser-release.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-release.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" \
          > /etc/apt/sources.list.d/brave-browser-release.list
        apt update && apt install -y brave-browser
        break;;
      LibreWolf)
        apt remove --purge -y firefox firefox-locale-en || true
        apt autoremove -y
        flatpak install -y --noninteractive flathub io.gitlab.librewolf-community
        break;;
      "Hardened Firefox")
        flatpak install -y --noninteractive flathub org.mozilla.firefox
        break;;
    esac
  done
else
  echo "Keeping Linux Mint Firefox ESR."
fi

# Timeshift (Mint official)
echo "Installing Timeshift..."
apt install -y timeshift

# FSearch
echo "Installing FSearch..."
add-apt-repository -y ppa:christian-boxdoerfer/fsearch-stable
apt update
apt install -y fsearch

# Clapper (Mint video alternative)
echo "Installing Clapper (Flatpak)..."
sudo -u "$SUDO_USER" flatpak install -y --noninteractive flathub com.github.rafostar.Clapper

### Developer Tools ###
read -rp "Install Node.js 20 LTS? (y/n): " node
[[ $node =~ ^[Yy]$ ]] && {
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
}

read -rp "Install Python 3 + pip + venv? (y/n): " python
[[ $python =~ ^[Yy]$ ]] && apt install -y python3 python3-pip python3-venv

read -rp "Install Visual Studio Code? (y/n): " vscode
[[ $vscode =~ ^[Yy]$ ]] && {
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" \
    > /etc/apt/sources.list.d/vscode.list
  apt update && apt install -y code
}

### Office Suite ###
echo "Office suite: 1) LibreOffice (Mint default)   2) ONLYOFFICE (Flatpak)"
select office in "LibreOffice" "ONLYOFFICE"; do
  case $office in
    LibreOffice)
      apt install -y libreoffice libreoffice-l10n-en-au libreoffice-help-en-gb
      break;;
    ONLYOFFICE)
      sudo -u "$SUDO_USER" flatpak install -y --noninteractive flathub org.onlyoffice.desktopeditors
      break;;
  esac
done

echo "Final cleanup..."
apt autoremove -y && apt clean

echo "All done! Reboot recommended. Log saved to linux-mint-talon.log"
