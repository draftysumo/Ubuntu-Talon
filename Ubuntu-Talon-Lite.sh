#!/bin/bash
set -euo pipefail

# Log everything to setup.log
exec > >(tee -i setup.log)
exec 2>&1

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ This script must be run as root. Try: sudo $0"
  exit 1
fi

USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

echo "🔄 Updating system & installing libraries..."
apt update && apt upgrade -y
apt install -y curl jq flatpak gnome-software gnome-software-plugin-flatpak preload gnome-shell gnome-shell-extensions software-properties-common libvlc-dev ffmpeg

# Install GNOME Shell Extension Manager
echo "🔧 Installing GNOME Shell Extension Manager..."
apt install -y gnome-shell-extension-manager

echo "🌐 Setting up Flatpak and Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Ask about Firefox replacement
read -rp "🌐 Do you want to replace Firefox? (y/n): " replace_ff
if [[ "$replace_ff" =~ ^[Yy]$ ]]; then
  echo "Choose a replacement browser:"
  select browser_choice in "Brave" "LibreWolf"; do
    case $browser_choice in
      Brave)
        echo "🗑️ Removing Firefox..."
        snap list | grep -q firefox && snap remove --purge firefox || echo "No Firefox snap installed."
        apt list --installed 2>/dev/null | grep -q firefox && apt remove --purge -y firefox || echo "No Firefox apt package installed."
        rm -rf /etc/firefox /usr/lib/firefox /usr/lib/firefox-addons /usr/share/firefox /usr/share/firefox-addons

        echo "🦁 Installing Brave Browser via script..."
        curl -fsS https://dl.brave.com/install.sh | sh
        break
        ;;
      LibreWolf)
        echo "🗑️ Removing Firefox..."
        snap list | grep -q firefox && snap remove --purge firefox || echo "No Firefox snap installed."
        apt list --installed 2>/dev/null | grep -q firefox && apt remove --purge -y firefox || echo "No Firefox apt package installed."
        rm -rf /etc/firefox /usr/lib/firefox /usr/lib/firefox-addons /usr/share/firefox /usr/share/firefox-addons

        echo "🦊 Installing LibreWolf via Flatpak..."
        flatpak install -y --noninteractive flathub io.gitlab.librewolf-community
        break
        ;;
      *)
        echo "❌ Invalid option. Choose 1 or 2."
        ;;
    esac
  done
else
  echo "✅ Keeping Firefox."
fi

echo "🧹 Removing Snap Store (if present)..."
snap list | grep -q snap-store && snap remove --purge snap-store || echo "No Snap Store found."

echo "🔍 Installing FSearch..."
add-apt-repository -y ppa:christian-boxdoerfer/fsearch-stable
apt update
apt install -y fsearch

echo "🎬 Installing Clapper via Flatpak..."
sudo -u "$SUDO_USER" flatpak install -y --noninteractive flathub com.github.rafostar.Clapper

echo "🧽 Final system cleanup..."
apt autoremove -y
apt clean
apt autoclean -y

echo "✅ Setup complete! Full log saved in setup.log"
