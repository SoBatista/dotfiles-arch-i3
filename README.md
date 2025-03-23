# 🐧 Arch Linux Hacking Environment Setup

This project provides an automated setup script for building a complete ethical hacking environment on **Arch Linux with i3 window manager**, designed for performance, usability, and customization.

It’s based on my YouTube tutorial series and configures everything from terminal utilities to graphical tools, workspace bindings, and themes — all using lightweight and powerful tools.

---

## 📦 What It Installs

### 🧰 Core Utilities
- `virtualbox-guest-utils` – Guest additions (auto-resize, drag & drop)
- `terminator` – Better terminal with copy/paste shortcuts
- `zsh` – Modern shell
- `zsh-syntax-highlighting` – Syntax color while typing
- `zsh-autosuggestions` – Command autosuggestions
- `less`, `pkgfile`, `yay` – Essential helpers

### 🎯 Hacking Tools
- `nmap` – Network scanner
- `john` – Password cracker
- `burpsuite` – Web proxy/interceptor
- `gobuster` – Directory scanner
- `ffuf` – Fuzzing tool
- Custom wordlists folder (`/usr/share/wordlists`)

### 🧱 i3 Setup
- `i3blocks` – Custom status bar blocks
- `i3blocks-contrib` – Pre-built useful scripts
- `pacman-contrib` – Required for update notifier

### 🎨 UI / Theming
- `rofi` – Application launcher (replacement for dmenu)
- `pcmanfm` – Lightweight file manager
- `lxappearance`, `arc-gtk-theme` – Theme manager + dark themes
- `papirus-icon-theme` – Icon set
- `ttf-font-awesome` – FontAwesome icons
- `feh` – Wallpaper setting tool

---

## 🚀 How to Use

1. Clone this repository:

   git clone https://github.com/yourusername/arch-hacking-setup.git
   cd arch-hacking-setup

2. Make the script executable:

    chmod +x install_hacking_env.sh

3. Run the script

    ./install_hacking_env.sh

⚠️ Important: Run this on a fresh Arch Linux install with i3 window manager and internet access.

---

## 🔧 Manual Steps (After the Script)
This script installs everything, but a few configurations require manual edits to match your preferences.

### ~/.config/i3/config

    # Change terminal
    bindsym $mod+Return exec terminator

    # Replace i3status with i3blocks
    status_command SCRIPT_DIR=~/.config/i3blocks/scripts/i3blocks-contrib i3blocks

    # Set wallpaper
    exec --no-startup-id feh --bg-scale /path/to/image

    # Assign applications to workspaces
    for_window [class="firefox"] move to workspace $ws2

    # Lock screen shortcut
    bindsym $mod+z exec i3lock

    # Launch rofi with icons
    bindsym $mod+d exec rofi -show run -icon-theme "Papirus" -show-icons

### ~/.zshrc (snippet added by the script)

    # Enable syntax highlighting and autosuggestions
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
    source /usr/share/doc/pkgfile/command-not-found.zsh

    # Alias to update system
    alias u="sudo pacman -Syu"

## Rofi: Set Your Theme

    rofi-theme-selector

Use Alt + A to apply a theme.

---

## 📺 Based on My YouTube Series

This project was built alongside a YouTube series that walks through each step in detail — from ISO setup to a fully customized ethical hacking desktop.

🎥 **Subscribe to follow along** 👉 [SoBatistaCyber YouTube](https://www.youtube.com/@SoBatistaCyber)

---

## ❤️ Contributing

Got improvements, extra tools, or want to make this even more plug-and-play?  
Feel free to **open an issue** or **submit a pull request** — collaboration is welcome!
