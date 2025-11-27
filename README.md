One-time use script to setup a fresh Ubuntu LTS (22+) install the way I endorce (and/or the way I like)

## Features

- **Root Check**: Ensures the script is run with root privileges.
- **System Update & Package Installation**: Updates the system and installs essential tools like `curl`, `jq`, `flatpak`, and more.
- **GNOME Extension Manager**: Installs the GNOME Shell Extension Manager to easily manage GNOME Shell extensions.
- **Flatpak & Flathub Setup**: Adds the `flathub` remote to Flatpak, allowing easy installation of sandboxed apps.
- **Firefox Replacement**: Optionally replaces Firefox with either **Brave** or **LibreWolf**.
- **Snap Store Removal**: Removes the Snap Store, if installed, to free up resources.
- **GNOME Document Viewer Removal**: Removes Evince (GNOME Document Viewer) to free up space.
- **Celluloid Media Player**: Installs the **Celluloid** media player (via Flatpak).
- **Developer Tools**: Optionally installs **Node.js**, **Python**, and **Visual Studio Code**.
- **Office Suite**: Allows you to choose between installing **LibreOffice** or **OnlyOffice**.
- **Partitioning Tools**: Replaces `gdisk` with `gpart` for disk partitioning.
- **System Cleanup**: Runs cleanup tasks like `apt autoremove` and `apt clean` to optimize disk space.

## Requirements

- Fresh or almost fresh Ubuntu LTS install (v22 or above). 
- **Root privileges** (you must run the script as root).
- Internet connection (for downloading packages).
- Curl installed (install by running: ```sudo apt install curl -y```).

## Usage
### Paste into terminal:
```bash
   sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/draftysumo/Ubuntu-Talon/refs/heads/main/Ubuntu-Talon.sh)"
```
### Or paste this to run the script and install the apps I like to use (this version of the script is knida just for me to use when setting up my own machines)
```bash
   sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/draftysumo/Ubuntu-Talon/refs/heads/main/Ubuntu-Talon-Drafty.sh)"
```
