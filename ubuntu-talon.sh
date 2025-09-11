#!/bin/bash
set -euo pipefail

# Log everything to setup.log
exec > >(tee -i setup.log)
exec 2>&1

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root. Try: sudo $0"
  exit 1
fi

echo "🔄 Updating system..."
apt update && apt upgrade -y
apt install -y curl

echo "🧹 Removing snap-store (if present)..."
snap remove --purge snap-store || true

echo "📦 Installing Flatpak + GNOME Software integration..."
apt install -y flatpak gnome-software gnome-software-plugin-flatpak

echo "🌐 Adding Flathub repository..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "⏳ Installing Timeshift..."
add-apt-repository -y ppa:teejee2008/timeshift
apt update
apt install -y timeshift

echo "🦁 Installing Brave Browser via Flatpak..."
curl -fsS https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
  | gpg --dearmor | tee /usr/share/keyrings/brave-browser-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com stable main" \
  | tee /etc/apt/sources.list.d/brave-browser-release.list

apt update
flatpak install -y flathub com.brave.Browser

echo "⚡ Installing performance + GNOME tools..."
apt install -y preload gnome-shell gnome-shell-extensions clapper

echo "🗑️ Removing Firefox (if present)..."
apt remove --purge -y firefox || true
snap remove firefox || true

echo "🧹 Running The New Brave Debloater..."
bash <(curl -s https://raw.githubusercontent.com/MulesGaming/brave-debloatinator/main/brave-bullshitinator-linux-install.sh)

echo "🧽 Cleaning up..."
apt autoremove -y
apt clean

echo "✅ Setup complete! A full log is saved in setup.log"
