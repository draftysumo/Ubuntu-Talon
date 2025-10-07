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

echo "🔄 Updating system..."
apt update && apt upgrade -y
apt install -y curl jq flatpak gnome-software gnome-software-plugin-flatpak preload gnome-shell gnome-shell-extensions software-properties-common

# Install GNOME Shell Extension Manager
echo "🔧 Installing GNOME Shell Extension Manager..."
apt install -y gnome-shell-extension-manager

echo "🌐 Setting up Flatpak and Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

echo "🗑️ Removing Firefox (Snap and APT, if present)..."
snap list | grep -q firefox && snap remove --purge firefox || echo "No Firefox snap installed."
apt list --installed 2>/dev/null | grep -q firefox && apt remove --purge -y firefox || echo "No Firefox apt package installed."
rm -rf /etc/firefox /usr/lib/firefox /usr/lib/firefox-addons /usr/share/firefox /usr/share/firefox-addons

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

echo "🦁 Installing Brave Browser via script..."
curl -fsS https://dl.brave.com/install.sh | sh

echo "🎬 Installing Clapper via Flatpak..."
sudo -u "$SUDO_USER" flatpak install -y --noninteractive flathub com.github.rafostar.Clapper

echo "🚀 Running Brave debloater..."

PREF_PATH="${USER_HOME}/.config/BraveSoftware/Brave-Browser/Default/Preferences"
PROFILE_DIR=$(dirname "$PREF_PATH")

# Launch Brave to create the profile (in background)
if [[ ! -f "$PREF_PATH" ]]; then
  echo "⚠️ Brave Preferences not found, launching Brave once to create profile..."
  sudo -u "$SUDO_USER" brave-browser --no-first-run --headless --disable-gpu about:blank &
  sleep 5
  pkill -u "$SUDO_USER" -f brave || true
  sleep 2
fi

if [[ ! -f "$PREF_PATH" ]]; then
  echo "❌ Still couldn't find Brave Preferences at: $PREF_PATH"
  echo "Skipping Brave debloat step."
else
  echo "✅ Found Brave Preferences at: $PREF_PATH"

  echo "📦 Backing up Brave profile..."
  TS=$(date +%Y%m%d-%H%M%S)
  BACKUP_DIR="${USER_HOME}/brave-debloat-backup-${TS}"
  mkdir -p "$BACKUP_DIR"
  cp -a "$PROFILE_DIR" "$BACKUP_DIR/"

  # Kill Brave if it's running
  pkill -u "$SUDO_USER" -f brave || true
  sleep 1

  TMP_PREF=$(mktemp)
  cp "$PREF_PATH" "$TMP_PREF"

  echo "🧠 Applying Brave debloat preferences..."

  declare -a PREF_CHANGES=(
    "brave.rewards.enabled false"
    "brave.rewards.ac.enabled false"
    "brave.rewards.banner_shown false"
    "brave.rewards.show_notification false"
    "brave.wallets.ui.enabled false"
    "brave.crypto_wallets.enabled false"
    "brave.ai.enabled false"
    "brave.leo.enabled false"
    "first_run false"
    "session.restore_on_startup 0"
    "brave.onboarding_shown true"
    "metrics.reporting_enabled false"
    "brave.metrics_reporting_enabled false"
    "crash_reporter_enabled false"
    "safebrowsing.enabled false"
    "brave.ntp.ads.enabled false"
    "brave.sponsored_images.enabled false"
    "browser.disable_component_update true"
  )

  for kv in "${PREF_CHANGES[@]}"; do
    key="${kv%% *}"
    val="${kv#* }"
    jq ".$key = $val" "$TMP_PREF" > "${TMP_PREF}.new" 2>/dev/null && mv "${TMP_PREF}.new" "$TMP_PREF" || true
  done

  cp "$TMP_PREF" "$PREF_PATH"
  chown "$SUDO_USER":"$SUDO_USER" "$PREF_PATH"

  # Optional: disable extensions
  if [[ -d "$(dirname "$PREF_PATH")/Extensions" ]]; then
    mv "$(dirname "$PREF_PATH")/Extensions" "$(dirname "$PREF_PATH")/Extensions.disabled" || true
  fi

  echo "🦾 Brave debloat complete! Backup stored at: $BACKUP_DIR"
fi

echo "🧽 Final system cleanup..."
apt autoremove -y
apt clean

echo "✅ Setup complete! Full log saved in setup.log"
