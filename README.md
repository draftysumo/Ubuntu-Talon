<div align="center">

<img width="240" height="240" alt="bitmap" src="https://github.com/user-attachments/assets/0f9e2d28-3c86-45dc-9238-efe537d68306" />


# Ubuntu Talon

One-time-use script to debloat, improve & update fresh or almost fresh Ubuntu LTS installs. They also optionally installs better default browsers & office suits.

<div align="left">

---

## Disclaimer!
I am not responsible for any damages or distress caused by the program in the event that something goes wrong, like always, never install & run things from users online until you have done the necessary research.

## What does it do?
### Package Management:
- Updates the system ```(apt update && apt upgrade)```.

- Installs essential libraries and tools (curl, jq, flatpak, gnome-shell, etc.).

- Removes unwanted packages (gnome-clocks, gdisk).

- Installs synaptic (Package Manager) and gparted (Disk Management).

- GNOME and Flatpak Setup:

- Installs the GNOME Shell Extension Manager.

- Configures Flatpak and adds the Flathub repository.

### Browser Replacement:
- Optionally replaces Firefox with either Brave or LibreWolf.

- Removes Firefox if chosen.

### Developer Tools:
- Optionally installs Node.js, npm, and Python.

- Optionally installs Visual Studio Code.

### Office Suite Installation:
- Installs either LibreOffice or OnlyOffice, depending on user choice.

### .desktop Entry Modifications (Drafty preset only):
- Renames desktop entries for synaptic, gparted, gedit, software-properties-gtk, and update-manager to more user-friendly names.

- Updates the desktop database for new names.

### System Cleanup:
- Removes unnecessary packages and cleans up temporary files.

- Timeshift and FSearch Installation:

- Installs Timeshift (system backup tool) and FSearch (file search tool).

- Installs Clapper (media player) via Flatpak.

## How To Run

### FIRST
Make sure your system meets these requirements (running the program without meeting these requirements will result in issues):

- Fresh or almost fresh install of Ubuntu Version 22.04 (LTS) or higher (Must be an LTS version)
- Curl installed (install by running ```sudo apt install curl```)

### THEN
Run the following command:

**Ubuntu-Talon:**
```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/draftysumo/Linux-Talons/refs/heads/main/Ubuntu-Talon.sh)"
```

**Ubuntu-Talon (Drafty preset):**
```
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/draftysumo/Linux-Talons/refs/heads/main/Ubuntu-Talon-DraftyPreset.sh)"
```

If you encounter any bugs, please open an 'Issue' on the GitHub repository. Thank you! :)

---

**Windows Talon** By k0: https://github.com/ravendevteam/talon
