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
apt install -y curl jq

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
apt install -y preload gnome-shell gnome-shell-extensions clapper fsearch

echo "🗑️ Removing Firefox (if present)..."
apt remove --purge -y firefox || true
snap remove firefox || true

echo "🧽 Cleaning up..."
apt autoremove -y
apt clean

echo "🚀 Running Brave debloater..."

APP_ID="com.brave.Browser"
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
VAR_APP_DIR="${USER_HOME}/.var/app/${APP_ID}"

PREF_PATH="${VAR_APP_DIR}/config/BraveSoftware/Brave-Browser/Default/Preferences"
PROFILE_DIR=$(dirname "$PREF_PATH")

if [[ ! -f "$PREF_PATH" ]]; then
  echo "⚠️  Brave Preferences not found at expected path: $PREF_PATH"
  echo "Skipping Brave debloat step."
else
  echo "✅ Found Brave Preferences at: $PREF_PATH"

  echo "📦 Backing up Brave profile..."
  TS=$(date +%Y%m%d-%H%M%S)
  BACKUP_DIR="${USER_HOME}/brave-debloat-backup-${TS}"
  mkdir -p "$BACKUP_DIR"
  cp -a "$PROFILE_DIR" "$BACKUP_DIR/"

  # Kill Brave if it's running
  sudo -u "$SUDO_USER" flatpak kill "$APP_ID" >/dev/null 2>&1 || true
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

echo "✅ Setup complete! A full log is saved in setup.log"
