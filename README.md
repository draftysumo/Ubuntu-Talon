<img width="200" height="200" alt="bitmap" src="https://github.com/user-attachments/assets/8bcbfecf-c363-4ce0-beb6-8ec019fff1d4" />


# Ubuntu-Talon

A one-time-use script to debloat and improve Ubuntu automatically with better privacy & security browsers, open source office suites and more.

## What does it do?
- Updates system packages: Keeps Ubuntu secure, fast, and up to date with the latest software and patches.
- Removes Snap Store & Snaps: Simplifies the system and reduces bloat by removing unnecessary Snap components.
- Installs Flatpak and Flathub repository: Enables access to a large library of modern, sandboxed applications, making it easier to install software securely and without Snap.
- Installs Timeshift for backups: Allows easy system snapshots and restores in case of issues or failed updates.
- Replaces Firefox with Brave or LibreWolf: Asks the user whether they want to replace Firefox with Brave Browser (for enhanced privacy and ad blocking) or LibreWolf (a privacy-focused fork of Firefox). Both options are available via Flatpak for maximum security.
- Installs essential tools (Preload, VLC, FSearch, etc.): Enhances system responsiveness, provides media playback capabilities, and improves file search speed and usability.
- Cleans up unused packages: Frees disk space and optimizes performance by removing leftover and unnecessary dependencies.
- Installs Office Suite: Prompts the user to install either LibreOffice or OnlyOffice and provides installation via Flatpak or APT (depending on availability).

## Key Features:
- Full replacement of Firefox with Brave or LibreWolf (if wanted)
- Installs Flatpak applications like Clapper (media player) and FSearch (file search tool) from Flathub.
- Offers a selection between LibreOffice or OnlyOffice for office suite functionality.
- Installs Timeshift for automatic system backups and restores.

## Disclaimer!
I am not responsible for any damages or distress caused by the program in the event that something goes wrong, like always, never install & run things from users online until you have done the necessary research.

## How To Run

### FIRST
Make sure your system meets these requirements (running the program without meeting these requirements will result in issues):

- Ubuntu Version 22.04 (LTS) or higher (Must be an LTS version)
- Fresh or almost fresh install of Ubuntu
- Curl installed (install by running ```sudo apt install curl```)

### THEN
Run the following command:

```sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/draftysumo/Ubuntu-Talon/refs/heads/main/ubuntu-talon.sh)"```

If you encounter any bugs, please open an 'Issue' on the GitHub repository. Thank you! :)

**Windows Talon** By k0: https://github.com/ravendevteam/talon
