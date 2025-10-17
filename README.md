<div align="center">

<img width="240" height="240" alt="bitmap" src="https://github.com/user-attachments/assets/0f9e2d28-3c86-45dc-9238-efe537d68306" />


# Ubuntu-Talon

### A one-time-use script to debloat, improve & update fresh or almost fresh Ubuntu LTS installs.
**It also optionally installs better default browsers & office suits.**

### [👉 Run](#how-to-run)
### [👷 Contribute](#how-to-run)

<div align="left">

---

## What does it do?
- Updates system packages.
- Removes Snap Store & Snaps to simplify the system and reduce bloat by removing unnecessary Snap components.
- Installs Flatpak and Flathub repository making it easier to install software securely and without Snap.
- Installs must have apps/packages like Timeshift for backups, VLC for video formats & more.
- Replaces Firefox with Brave or LibreWolf if desired for better security.
- Installs productivity utities-Preload & FSearch.
- Cleans up unused packages.
- Installs optional Office Suites like LibreOffice or OnlyOffice, decided by the user.

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
