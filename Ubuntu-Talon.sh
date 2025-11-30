#!/bin/bash
set -euo pipefail

# ===============================
# Setup Logging
# ===============================
exec > >(tee -i setup.log)
exec 2>&1

# ===============================
# Root Check
# ===============================
if [[ $EUID -ne 0 ]]; then
  echo "❌ Must be run as root. Try: sudo $0"
  exit 1
fi

USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

# ===============================
# Helper Functions
# ===============================
remove_firefox() {
    echo "🗑️ Removing Firefox..."
    snap list | grep -q firefox && snap remove --purge firefox || true
    apt list --installed 2>/dev/null | grep -q firefox && apt remove --purge -y firefox || true
    rm -rf /etc/firefox /usr/lib/firefox /usr/share/firefox
}

install_flatpak_app() {
    local app_id="$1"
    sudo -u "$SUDO_USER" flatpak install -y --noninteractive flathub "$app_id"
}

# ===============================
# Remove Snapd and All Snaps
# ===============================
remove_snapd_and_snaps() {
    echo "🧹 Removing Snapd and all snaps..."
    # Remove all snaps installed on the system
    snap list | awk '{if(NR>1) print $1}' | xargs -I {} snap remove --purge {}
    
    # Now remove snapd itself
    apt remove --purge -y snapd
    # Clean up snap directories if any remain
    rm -rf /var/cache/snapd /snap
}

# ===============================
# Remove Ubuntu Software Updater
# ===============================
remove_ubuntu_software_updater() {
    echo "🧹 Removing Ubuntu Software Updater..."
    # Remove GNOME Software (the Ubuntu Software Updater)
    apt remove --purge -y gnome-software
}

# ===============================
# System Update & Base Libraries
# ===============================
echo "🔄 Updating system & installing packages..."
apt update && apt upgrade -y
apt install -y curl jq flatpak gnome-shell gnome-shell-extensions software-properties-common libvlc-dev ffmpeg stacer

# GNOME Shell Extension Manager
echo "🔧 Installing GNOME Extension Manager..."
apt install -y gnome-shell-extension-manager

# Flatpak & Flathub
echo "🌐 Setting up Flatpak & Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ===============================
# Firefox Replacement
# ===============================
read -rp "Replace Firefox? (y/n): " replace_ff
if [[ "$replace_ff" =~ ^[Yy]$ ]]; then
  echo "Choose a browser:"
  select browser_choice in "Brave" "LibreWolf"; do
    case $browser_choice in
      Brave)
        remove_firefox
        echo "🦁 Installing Brave..."
        curl -fsS https://dl.brave.com/install.sh | sh
        break
        ;;
      LibreWolf)
        remove_firefox
        echo "🦊 Installing LibreWolf..."
        install_flatpak_app "io.gitlab.librewolf-community"
        break
        ;;
      *)
        echo "❌ Invalid option."
        ;;
    esac
  done
else
  echo "✅ Keeping Firefox."
fi

# ===============================
# Remove GNOME Document Viewer
# ===============================
echo "🗑️ Removing GNOME Document Viewer..."
apt remove -y evince || true

# ===============================
# Install Celluloid Media Player
# ===============================
echo "🎬 Installing Celluloid..."
install_flatpak_app "org.gnome.Celluloid"

# ===============================
# Developer Tools
# ===============================
echo "💻 Installing Developer Tools..."
read -rp "Install Node.js? (y/n): " install_node
if [[ "$install_node" =~ ^[Yy]$ ]]; then
  echo "📦 Installing Node.js..."
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
  apt install -y nodejs
fi

read -rp "Install Python? (y/n): " install_python
if [[ "$install_python" =~ ^[Yy]$ ]]; then
  echo "🐍 Installing Python..."
  apt install -y python3 python3-pip python3-venv
fi

read -rp "Install VS Code? (y/n): " install_vscode
if [[ "$install_vscode" =~ ^[Yy]$ ]]; then
  echo "🧩 Installing Visual Studio Code..."
  curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/packages.microsoft.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
  apt update
  apt install -y code
fi

# ===============================
# Office Suite
# ===============================
echo "📂 Choose Office suite:"
select office_choice in "LibreOffice" "OnlyOffice"; do
  case $office_choice in
    LibreOffice)
      echo "📦 Installing LibreOffice..."
      install_flatpak_app "org.libreoffice.LibreOffice" || apt install -y libreoffice
      break
      ;;
    OnlyOffice)
      echo "📦 Installing OnlyOffice..."
      TMP_DIR=$(mktemp -d)
      cd "$TMP_DIR"
      wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb
      apt install -y ./onlyoffice-desktopeditors_amd64.deb
      cd - && rm -rf "$TMP_DIR"
      break
      ;;
    *)
      echo "❌ Invalid option."
      ;;
  esac
done

# ===============================
# Disk Utilities
# ===============================
echo "💽 Replacing gdisk with gpart..."
apt remove -y gdisk || true
apt install -y gpart

# ===============================
# Final Cleanup
# ===============================
echo "🧽 Cleanup..."
apt autoremove -y
apt clean
apt autoclean -y

echo "✅ Setup complete! Log saved in setup.log"
