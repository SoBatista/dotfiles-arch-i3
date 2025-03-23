#!/bin/bash

set -e

install_core_packages() {
  echo "📦 Updating system..."
  sudo pacman -Syu --noconfirm

  echo "🧰 Installing core utilities, shell, theming tools..."
  sudo pacman -S --noconfirm \
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

  echo "⚙️ Enabling VirtualBox guest services..."
  sudo systemctl enable vboxservice
  sudo systemctl start vboxservice
}

install_hacking_tools() {
  echo "💀 Installing hacking tools (pacman)..."
  sudo pacman -S --noconfirm \
    nmap \
    john

  echo "📦 Installing yay (AUR helper)..."
  sudo pacman -S --needed --noconfirm git base-devel
  cd "$HOME"
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay

  echo "💥 Installing hacking tools (AUR)..."
  yay -S --noconfirm \
    zsh-autosuggestions \
    gobuster \
    ffuf \
    burpsuite
}

setup_dotfiles() {
  echo "📁 Cloning dotfiles..."
  git clone https://github.com/SoBatista/dotfiles-arch-i3 "$HOME/dotfiles-arch-i3"

  echo "🛠️ Applying i3 config..."
  mkdir -p "$HOME/.config/i3"
  cp "$HOME/dotfiles-arch-i3/i3/config" "$HOME/.config/i3/config"

  echo "🛠️ Applying i3blocks config..."
  mkdir -p "$HOME/.config/i3blocks"
  cp "$HOME/dotfiles-arch-i3/i3blocks/config" "$HOME/.config/i3blocks/config"

  echo "🛠️ Applying zshrc..."
  cp "$HOME/dotfiles-arch-i3/zshrc" "$HOME/.zshrc"
}

setup_i3blocks_contrib() {
  echo "📁 Cloning i3blocks-contrib scripts..."
  mkdir -p "$HOME/.config/i3blocks/scripts"
  cd "$HOME/.config/i3blocks/scripts"
  git clone https://github.com/vivien/i3blocks-contrib.git
}

set_zsh_default() {
  echo "💻 Setting ZSH as default shell..."
  chsh -s "$(which zsh)"
  if [ "$SHELL" = "/bin/zsh" ]; then
    source "$HOME/.zshrc"
  else
    echo "ℹ️ You're using Bash. Your Zsh config will apply after reboot or switching shell."
  fi
}

main() {
  install_core_packages
  install_hacking_tools
  setup_dotfiles
  setup_i3blocks_contrib
  set_zsh_default

  echo
  echo "✅ Setup complete!"
  echo
  read -p "🎉 Installation complete! Do you want to reboot now? (y/n): " answer
  case "$answer" in
      [Yy]* ) echo "🔄 Rebooting..."; reboot;;
      [Nn]* ) echo "✅ Done! You can reboot later to apply all changes.";;
      * ) echo "❓ Invalid option. Not rebooting. You can reboot manually later.";;
  esac
}

# 🚀 Start the script
main
