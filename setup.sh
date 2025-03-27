#!/bin/bash

set -e

SCRIPT_VERSION="1.0.0"
LOG_FILE="$HOME/setup.log"

# Flags
INSTALL_CORE=true
INSTALL_HACKING=true
INSTALL_DOTFILES=true
INSTALL_I3BLOCKS=true
SET_ZSH=true
PROMPT_REBOOT=true
DEBUG=false

# Parse flags
for arg in "$@"; do
  case $arg in
    --no-core) INSTALL_CORE=false ;;
    --no-hacking) INSTALL_HACKING=false ;;
    --no-dotfiles) INSTALL_DOTFILES=false ;;
    --no-i3blocks) INSTALL_I3BLOCKS=false ;;
    --no-zsh) SET_ZSH=false ;;
    --no-reboot) PROMPT_REBOOT=false ;;
    --debug) DEBUG=true ;;
    --help)
      echo "📖 Arch Hacking Setup Script v$SCRIPT_VERSION"
      echo "Usage: ./install_hacking_env.sh [options]"
      echo "Options:"
      echo "  --no-core       Skip core utilities installation"
      echo "  --no-hacking    Skip hacking tools installation"
      echo "  --no-dotfiles   Do not clone or apply dotfiles"
      echo "  --no-i3blocks   Skip i3blocks-contrib setup"
      echo "  --no-zsh        Skip setting ZSH as default shell"
      echo "  --no-reboot     Don’t prompt for reboot at the end"
      echo "  --debug         Show full command output"
      echo "  --help          Show this help message"
      exit 0
      ;;
    *) echo "⚠️ Unknown option: $arg"; exit 1 ;;
  esac
done

# Ask for sudo once and keep it alive
printf "🔐 Requesting sudo access...\n"
sudo -v
( while true; do sudo -n true; sleep 30; done ) &
SUDO_PID=$!
trap 'kill $SUDO_PID' EXIT

# Logging helper
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

run() {
  if $DEBUG; then
    "$@" 2>&1 | tee -a "$LOG_FILE"
  else
    "$@" >> "$LOG_FILE" 2>&1
  fi
}

print_progress() {
  local progress=$1
  local label=$2
  local bar=$(printf "#%.0s" $(seq 1 $((progress / 2))))
  local spaces=$(printf " %.0s" $(seq 1 $((50 - progress / 2))))
  printf "\r[%s%s] %3d%% %s" "$bar" "$spaces" "$progress" "$label"
}

install_core_packages() {
  print_progress 10 "Updating system"
  log "Updating system packages"
  run sudo -v && sudo pacman -Syu --noconfirm

  print_progress 20 "Installing core utilities"
  log "Installing core packages"
  run sudo -v && sudo pacman -S --noconfirm \
    virtualbox-guest-utils \
    terminator \
    zsh \
    zsh-syntax-highlighting \
    less \
    pcmanfm \
    lxappearance \
    arc-gtk-theme \
    feh \
    rofi \
    ttf-font-awesome \
    papirus-icon-theme \
    firefox \
    flatpak \
    htop \
    i3blocks \
    pacman-contrib

  print_progress 30 "Enabling VirtualBox guest services"
  log "Enabling VirtualBox guest services"
  run sudo -v && sudo systemctl enable vboxservice
  run sudo -v && sudo systemctl start vboxservice
}

install_hacking_tools() {
  print_progress 40 "Installing hacking tools (pacman)"
  log "Installing nmap and john"
  run sudo -v && sudo pacman -S --noconfirm nmap john

  print_progress 50 "Installing yay"
  log "Installing yay AUR helper"
  run sudo -v && sudo pacman -S --needed --noconfirm git base-devel
  cd "$HOME"
  if [ -d "$HOME/yay" ]; then
    cd yay && run git pull && cd ..
  else
    run git clone https://aur.archlinux.org/yay.git
    cd yay
    run makepkg -si --noconfirm
    cd ..
    rm -rf yay
  fi

  print_progress 60 "Installing hacking tools (AUR)"
  log "Installing gobuster, ffuf, burpsuite, zsh-autosuggestions"
  run yay -S --noconfirm \
    zsh-autosuggestions \
    gobuster \
    ffuf \
    burpsuite
}

setup_dotfiles() {
  print_progress 70 "Cloning dotfiles"
  log "Cloning and applying dotfiles"
  if [ -d "$HOME/dotfiles-arch-i3" ]; then
    cd "$HOME/dotfiles-arch-i3" && run git pull
  else
    run git clone https://github.com/SoBatista/dotfiles-arch-i3 "$HOME/dotfiles-arch-i3"
  fi

  print_progress 75 "Applying i3 config"
  mkdir -p "$HOME/.config/i3"
  cp "$HOME/dotfiles-arch-i3/i3/config" "$HOME/.config/i3/config"

  print_progress 80 "Applying i3blocks config"
  mkdir -p "$HOME/.config/i3blocks"
  cp "$HOME/dotfiles-arch-i3/i3blocks/i3blocks.conf" "$HOME/.config/i3blocks/i3blocks.conf"

   # Move the wallpaper to Downloads
  print_progress 83 "Setting wallpaper"
  log "Moving wallpaper to ~/Downloads/"
  cp -f "$HOME/dotfiles-arch-i3/wallpaper.jpg" "$HOME/Downloads/wallpaper.jpg"

  print_progress 85 "Applying zshrc"
  cp "$HOME/dotfiles-arch-i3/zshrc/config" "$HOME/.zshrc"
}

setup_i3blocks_contrib() {
  print_progress 90 "Cloning i3blocks-contrib"
  log "Setting up i3blocks-contrib"
  mkdir -p "$HOME/.config/i3blocks"
  cd "$HOME/.config/i3blocks"
  if [ -d "$HOME/.config/i3blocks/i3blocks-contrib" ]; then
    cd i3blocks-contrib && run git pull
  else
    run git clone https://github.com/vivien/i3blocks-contrib.git
  fi
}

set_zsh_default() {
  print_progress 95 "Setting Zsh as default shell"
  log "Setting ZSH as default shell"
  run sudo -v && chsh -s "$(which zsh)"
  if [ "$(basename "$SHELL")" != "zsh" ]; then
    echo -e "\nℹ️ Zsh will be applied after you log out and back in."
  fi
}

download_and_install_rofi_themes() {
  print_progress 87 "Downloading and installing Rofi themes"
  log "Downloading and installing Rofi themes"

  # Define the URLs and target directory
  local themes=(
    "https://raw.githubusercontent.com/newmanls/rofi-themes-collection/master/themes/rounded-common.rasi"
    "https://raw.githubusercontent.com/newmanls/rofi-themes-collection/master/themes/rounded-nord-dark.rasi"
  )
  local rofi_themes_dir="/usr/share/rofi/themes"

  # Ensure the Rofi themes directory exists
  sudo mkdir -p "$rofi_themes_dir"

  # Download each theme
  for theme_url in "${themes[@]}"; do
    local theme_name=$(basename "$theme_url")
    sudo wget -q "$theme_url" -O "$rofi_themes_dir/$theme_name"
  done

  # Replace the existing config.rasi with the one from your repository
  local config_source="$HOME/dotfiles-arch-i3/rofi/config.rasi"
  local config_target="$HOME/.config/rofi/config.rasi"

  mkdir -p "$(dirname "$config_target")"
  cp -f "$config_source" "$config_target"
}

main() {
  echo -e "\n🚀 Starting full system setup...\n"
  echo "📋 Logging everything to: $LOG_FILE"
  echo "----------------------" > "$LOG_FILE"
  echo "Setup Log - $(date)" >> "$LOG_FILE"
  echo "----------------------" >> "$LOG_FILE"

  $INSTALL_CORE && install_core_packages
  $INSTALL_HACKING && install_hacking_tools
  $INSTALL_DOTFILES && setup_dotfiles
  $INSTALL_I3BLOCKS && setup_i3blocks_contrib
  $SET_ZSH && set_zsh_default

  print_progress 100 "✅ Setup complete!"
  echo -e "\n\n🎉 All done!"

  if $PROMPT_REBOOT; then
    echo
    read -p "🔁 Do you want to reboot now? (y/n): " answer
    case "$answer" in
        [Yy]* ) echo "🔄 Rebooting..."; reboot ;;
        [Nn]* ) echo "✅ Done! You can reboot later to apply all changes." ;;
        * ) echo "❓ Invalid option. Not rebooting. You can reboot manually later." ;;
    esac
  else
    echo "🧘 Skipping reboot (flag: --no-reboot)"
  fi
}

# 🚀 Start the script
main
