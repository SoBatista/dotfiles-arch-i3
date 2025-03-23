#!/bin/bash

set -e

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
    *) echo "⚠️ Unknown option: $arg"; exit 1 ;;
  esac
done

# Ask for sudo once and keep it alive
printf "🔐 Requesting sudo access..."
sudo -v
# Keep-alive: refresh sudo timestamp while script runs (every 30 seconds)
( while true; do sudo -n true; sleep 30; done ) 2>/dev/null &
SUDO_PID=$!
trap 'kill $SUDO_PID' EXIT

run() {
  if $DEBUG; then
    "$@"
  else
    "$@" >/dev/null 2>&1
  fi
}

print_progress() {
  local progress=$1
  local label=$2
  printf "\r[%-50s] %3d%% %s" $(printf "#%.0s" $(seq 1 $((progress/2)))) $progress "$label"
  sleep 0.5
}

install_core_packages() {
  print_progress 10 "Updating system"
  run sudo pacman -Syu --noconfirm

  print_progress 20 "Installing core utilities"
  run sudo pacman -S --noconfirm \
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
  run sudo systemctl enable vboxservice
  run sudo systemctl start vboxservice
}

install_hacking_tools() {
  print_progress 40 "Installing hacking tools (pacman)"
  run sudo pacman -S --noconfirm nmap john

  print_progress 50 "Installing yay"
  run sudo pacman -S --needed --noconfirm git base-devel
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
  run yay -S --noconfirm \
    zsh-autosuggestions \
    gobuster \
    ffuf \
    burpsuite
}

setup_dotfiles() {
  print_progress 70 "Cloning dotfiles"
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

  print_progress 85 "Applying zshrc"
  cp "$HOME/dotfiles-arch-i3/zshrc/config" "$HOME/.zshrc"
}

setup_i3blocks_contrib() {
  print_progress 90 "Cloning i3blocks-contrib"
  mkdir -p "$HOME/.config/i3blocks/scripts"
  cd "$HOME/.config/i3blocks/scripts"
  if [ -d "$HOME/.config/i3blocks/scripts/i3blocks-contrib" ]; then
    cd i3blocks-contrib && run git pull
  else
    run git clone https://github.com/vivien/i3blocks-contrib.git
  fi
}

set_zsh_default() {
  print_progress 95 "Setting Zsh as default shell"
  run chsh -s "$(which zsh)"
  if [ "$SHELL" = "/bin/zsh" ]; then
    source "$HOME/.zshrc"
  else
    echo "\nℹ️ You're using Bash. Your Zsh config will apply after reboot or switching shell."
  fi
}

main() {
  $INSTALL_CORE && install_core_packages
  $INSTALL_HACKING && install_hacking_tools
  $INSTALL_DOTFILES && setup_dotfiles
  $INSTALL_I3BLOCKS && setup_i3blocks_contrib
  $SET_ZSH && set_zsh_default

  print_progress 100 "✅ Setup complete!"
  echo

  if $PROMPT_REBOOT; then
    echo
    read -p "🎉 Installation complete! Do you want to reboot now? (y/n): " answer
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