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

echo "⏳ Installing Timeshift..."
add-apt-repository -y ppa:teejee2008/timeshift
apt update
apt install -y timeshift

echo "🔍 Installing FSearch..."
add-apt-repository -y ppa:christian-boxdoerfer/fsearch-stable
apt update
apt install -y fsearch

echo "🎬 Installing Clapper via Flatpak..."
sudo -u "$SUDO_USER" flatpak install -y --noninteractive flathub com.github.rafostar.Clapper

# Ask about developer tools
echo "💻 Developer Tools Installation"
read -rp "Would you like to install Node.js & npm? (y/n): " install_node
if [[ "$install_node" =~ ^[Yy]$ ]]; then
  echo "📦 Installing Node.js & npm..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
fi

read -rp "Would you like to install Python? (y/n): " install_python
if [[ "$install_python" =~ ^[Yy]$ ]]; then
  echo "🐍 Installing Python..."
  apt install -y python3 python3-pip python3-venv
fi

read -rp "Would you like to install Visual Studio Code? (y/n): " install_vscode
if [[ "$install_vscode" =~ ^[Yy]$ ]]; then
  echo "🧩 Installing Visual Studio Code..."
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
  apt update
  apt install -y code
fi

# Ask about Office suite
echo "📂 Choose an Office suite to install:"
select office_choice in "LibreOffice" "OnlyOffice"; do
  case $office_choice in
    LibreOffice)
      echo "📦 Installing LibreOffice..."
      if flatpak search org.libreoffice.LibreOffice | grep -q LibreOffice; then
        sudo -u "$SUDO_USER" flatpak install -y --noninteractive flathub org.libreoffice.LibreOffice
      else
        apt install -y libreoffice
      fi
      break
      ;;
    OnlyOffice)
      echo "📦 Installing OnlyOffice..."
      if flatpak search org.onlyoffice.desktopeditors | grep -q ONLYOFFICE; then
        sudo -u "$SUDO_USER" flatpak install -y --noninteractive flathub org.onlyoffice.desktopeditors
      else
        echo "⚠️ Flatpak version not found. Installing .deb version..."
        TMP_DIR=$(mktemp -d)
        cd "$TMP_DIR"
        wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb
        apt install -y ./onlyoffice-desktopeditors_amd64.deb
        cd - && rm -rf "$TMP_DIR"
      fi
      break
      ;;
    *)
      echo "❌ Invalid option. Choose 1 or 2."
      ;;
  esac
done

echo "🧽 Final system cleanup..."
apt autoremove -y
apt clean
apt autoclean -y

echo "✅ Setup complete! Full log saved in setup.log"
