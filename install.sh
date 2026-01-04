#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "================================"
echo "GNOME Dotfiles Installation"
echo "================================"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Function to backup existing files/directories
backup_if_exists() {
    local path="$1"
    if [ -e "$path" ] && [ ! -L "$path" ]; then
        echo "Backing up $path"
        local backup_path="$BACKUP_DIR/$(basename "$path")"
        mv "$path" "$backup_path"
    fi
}

# Install packages
echo ""
echo "Installing required packages..."
sudo apt update
sudo apt install -y git stow dconf-editor gnome-tweaks gnome-shell-extensions fish

# Install Oh My Fish (if not already installed)
if [ ! -d "$HOME/.local/share/omf" ]; then
    echo "Installing Oh My Fish..."
    curl -L https://get.oh-my.fish | fish
fi

# Create necessary directories
mkdir -p ~/.config
mkdir -p ~/.local/bin

# Backup existing configs that stow will manage
echo ""
echo "Backing up existing configurations..."
backup_if_exists ~/.gitconfig
backup_if_exists ~/.config/gtk-3.0
backup_if_exists ~/.config/gtk-4.0
backup_if_exists ~/.config/omf
backup_if_exists ~/.config/zed
backup_if_exists ~/.config/fish

# Symlink configs using Stow
echo ""
echo "Creating symlinks with GNU Stow..."
cd "$DOTFILES_DIR"

# Stow each package
stow -v -t ~ shell   # Fish shell configs -> ~/.config/fish/
stow -v -t ~ config  # GTK, OMF, Zed configs -> ~/.config/
stow -v -t ~ git     # Git config -> ~/.gitconfig

# Copy wallpapers if any exist
if [ -d "$DOTFILES_DIR/wallpapers" ] && [ "$(ls -A $DOTFILES_DIR/wallpapers)" ]; then
    echo ""
    echo "Copying wallpapers..."
    mkdir -p ~/Pictures/Wallpapers
    cp -r "$DOTFILES_DIR/wallpapers/"* ~/Pictures/Wallpapers/
    echo "Wallpapers copied to ~/Pictures/Wallpapers/"
fi

# Install custom fonts if any exist
if [ -d "$DOTFILES_DIR/fonts" ] && [ "$(ls -A $DOTFILES_DIR/fonts)" ]; then
    echo ""
    echo "Installing fonts..."
    mkdir -p ~/.local/share/fonts
    cp -r "$DOTFILES_DIR/fonts/"* ~/.local/share/fonts/
    fc-cache -fv
    echo "Fonts installed!"
fi

# Copy scripts to local bin if any exist
if [ -d "$DOTFILES_DIR/scripts" ] && [ "$(ls -A $DOTFILES_DIR/scripts)" ]; then
    echo ""
    echo "Installing scripts..."
    cp "$DOTFILES_DIR/scripts/"* ~/.local/bin/
    chmod +x ~/.local/bin/*
    echo "Scripts installed to ~/.local/bin/"
fi

# Load GNOME settings
echo ""
echo "Loading GNOME settings..."

if [ -f "$DOTFILES_DIR/gnome/desktop.dconf" ]; then
    echo "Loading desktop settings..."
    dconf load /org/gnome/desktop/ < "$DOTFILES_DIR/gnome/desktop.dconf"
fi

if [ -f "$DOTFILES_DIR/gnome/shell.dconf" ]; then
    echo "Loading shell settings..."
    dconf load /org/gnome/shell/ < "$DOTFILES_DIR/gnome/shell.dconf"
fi

if [ -f "$DOTFILES_DIR/gnome/terminal.dconf" ]; then
    echo "Loading terminal settings..."
    dconf load /org/gnome/terminal/ < "$DOTFILES_DIR/gnome/terminal.dconf"
fi

if [ -f "$DOTFILES_DIR/gnome/keybindings.dconf" ]; then
    echo "Loading keybindings..."
    dconf load /org/gnome/desktop/wm/keybindings/ < "$DOTFILES_DIR/gnome/keybindings.dconf"
fi

if [ -f "$DOTFILES_DIR/gnome/media-keys.dconf" ]; then
    echo "Loading media keys..."
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$DOTFILES_DIR/gnome/media-keys.dconf"
fi

# Install GNOME extensions (if you have a list)
if [ -f "$DOTFILES_DIR/gnome/extensions-list.txt" ]; then
    echo ""
    echo "================================================"
    echo "GNOME Extensions detected:"
    cat "$DOTFILES_DIR/gnome/extensions-list.txt"
    echo "================================================"
    echo "Note: You'll need to manually install extensions from:"
    echo "https://extensions.gnome.org"
    echo ""
fi

# Set Fish as default shell
echo ""
read -p "Set Fish as your default shell? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    chsh -s $(which fish)
    echo "Fish set as default shell. You'll need to log out and back in."
fi

echo ""
echo "================================"
echo "Installation complete!"
echo "================================"
echo "Backups saved to: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "1. Log out and log back in for full effect"
echo "2. Install GNOME extensions from extensions.gnome.org"
echo "3. Open GNOME Tweaks to verify theme settings"
echo "4. Check that Fish shell is working: fish --version"
echo "5. OMF themes can be installed with: omf install <theme-name>"
echo ""
echo "Your configurations:"
echo "  - Fish config: ~/.config/fish/"
echo "  - GTK themes: ~/.config/gtk-3.0/ and gtk-4.0/"
echo "  - Zed editor: ~/.config/zed/"
echo "  - Git config: ~/.gitconfig"
echo "================================"
