<div align="center">

<img width="240" height="240" alt="bitmap" src="https://github.com/user-attachments/assets/0f9e2d28-3c86-45dc-9238-efe537d68306" />


# Linux-Talons

One-time-use scripts to debloat, improve & update fresh or almost fresh Linux Distro LTS installs. They also optionally installs better default browsers & office suits.

<div align="left">

---

## Disclaimer!
I am not responsible for any damages or distress caused by the program in the event that something goes wrong, like always, never install & run things from users online until you have done the necessary research.

## What do they do?
- Updates system packages.
- (Ubuntu) Removes Snap Store & Snaps to simplify the system and reduce bloat by removing unnecessary Snap components.
- Installs Flatpak and Flathub repository making it easier to install software securely and without Snap.
- Installs must have apps/packages like Timeshift for backups, VLC for video formats & more.
- Replaces Firefox with Brave or LibreWolf if desired for better security.
- Installs productivity utities-Preload & FSearch.
- Cleans up unused packages.
- Installs optional Office Suites like LibreOffice or OnlyOffice, decided by the user.
- Installs optional coding languages & Visual Studio Code, decided by the user.

## How To Run

### FIRST
Make sure your system meets these requirements (running the program without meeting these requirements will result in issues):

- (Ubuntu) Ubuntu Version 22.04 (LTS) or higher (Must be an LTS version)
- (Mint) Linux Mint 22.2 (Cinnamon)
- Fresh or almost fresh install of the distro of choice
- Curl installed (install by running ```sudo apt install curl```)

### THEN
Run the following command:

**Ubuntu-Talon:**
```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/draftysumo/Linux-Talons/refs/heads/main/Ubuntu-Talon.sh)"
```

**Mint-Talon:**
```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/draftysumo/Linux-Talons/refs/heads/main/Mint-Talon.sh)"
```

If you encounter any bugs, please open an 'Issue' on the GitHub repository. Thank you! :)

---

**Windows Talon** By k0: https://github.com/ravendevteam/talon
