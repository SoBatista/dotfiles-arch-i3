#!/bin/bash

set -e

echo "📦 Updating system..."
sudo pacman -Syu --noconfirm

# -----------------------
# Core Utilities & Tools
# -----------------------

echo "🧰 Installing terminal, shell, guest utilities..."
sudo pacman -S --noconfirm \
  virtualbox-guest-utils \
  terminator \
  zsh \
  zsh-syntax-highlighting \
  less \
  pkgfile \
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
  john \
  nmap

sudo systemctl enable vboxservice
sudo systemctl start vboxservice
sudo pkgfile --update

# -----------------------
# Install yay (AUR helper)
# -----------------------

echo "📦 Installing yay..."
sudo pacman -S --needed --noconfirm git base-devel
cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ..
rm -rf yay

# -----------------------
# AUR Packages
# -----------------------

echo "📦 Installing AUR packages..."
yay -S --noconfirm \
  zsh-autosuggestions \
  gobuster \
  ffuf \
  burpsuite

# -----------------------
# Clone dotfiles and apply
# -----------------------

echo "📁 Downloading dotfiles from GitHub..."
git clone https://github.com/SoBatista/dotfiles-arch-i3 ~/dotfiles-arch-i3

echo "🛠️ Applying i3 config..."
mkdir -p ~/.config/i3
cp ~/dotfiles-arch-i3/i3/config ~/.config/i3/config

echo "🛠️ Applying i3blocks config..."
mkdir -p ~/.config/i3blocks
cp ~/dotfiles-arch-i3/i3blocks/config ~/.config/i3blocks/config

echo "🛠️ Applying zshrc..."
cp ~/dotfiles-arch-i3/zshrc ~/.zshrc

# -----------------------
# Setup i3blocks-contrib scripts
# -----------------------

echo "📁 Cloning i3blocks-contrib repo..."
mkdir -p ~/.config/i3blocks/scripts
cd ~/.config/i3blocks/scripts
git clone https://github.com/vivien/i3blocks-contrib.git

# -----------------------
# Set ZSH as default shell
# -----------------------

echo "💻 Setting ZSH as default shell..."
chsh -s "$(which zsh)"
source ~/.zshrc

# -----------------------
# Cleanup & Done
# -----------------------

echo "✅ Setup complete!"
echo
read -p "🎉 Installation complete! Do you want to reboot now? (y/n): " answer
case "$answer" in
    [Yy]* ) echo "🔄 Rebooting..."; reboot;;
    [Nn]* ) echo "✅ Done! You can reboot later to apply all changes.";;
    * ) echo "❓ Invalid option. Not rebooting. You can reboot manually later.";;
esac
