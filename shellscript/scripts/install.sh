#!/bin/bash

set -e

DOTFILES_DIR="$HOME/.dotfiles"
OS="$(uname -s)"

echo "=== Dotfiles Installation Script ==="
echo "Detected OS: $OS"
echo "======================================"

# Detect if running interactively
if [[ ! -t 0 ]]; then
    echo "Error: This script must be run interactively"
    exit 1
fi

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://brew.sh)"
fi

# Install core tools
echo "Installing core tools..."
brew install stow zsh tmux neovim kitty fd fzf bat

# Install version managers
echo "Installing version managers..."
brew install nvm goenv

# Install database
if [[ "$OS" == "Darwin" ]]; then
    brew install postgresql@16
fi

# Install CLI apps
echo "Installing CLI apps..."
brew install age zoxide ffmpeg

# Install GUI apps (macOS only)
if [[ "$OS" == "Darwin" ]]; then
    echo "Installing GUI apps..."
    brew install --cask karabiner-elements
    brew install --cask raycast
    brew install --cask warp
    brew install --cask magnet
    brew install --cask hidden-bar
fi

# Install tmux plugin manager
echo "Setting up tmux plugins..."
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Install Oh My Zsh
echo "Setting up Oh My Zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install zsh plugins
echo "Installing zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# powerlevel10k
if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# you-should-use
if [[ ! -d "$ZSH_CUSTOM/plugins/you-should-use" ]]; then
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$ZSH_CUSTOM/plugins/you-should-use"
fi

# Install SDKMAN (Java)
echo "Setting up SDKMAN..."
if [[ ! -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    curl -s "https://get.sdkman.io" | bash
fi

# Clone dotfiles if not exists
echo "Setting up dotfiles..."
if [[ ! -d "$DOTFILES_DIR" ]]; then
    echo "Cloning dotfiles..."
    git clone git@github.com:yanralapdy/dotfiles.git "$DOTFILES_DIR"
fi

# Stow configs
echo "Stowing configurations..."
cd "$DOTFILES_DIR"
stow zsh kitty tmux nvim karabiner yazi shellscript

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.local/scripts"
mkdir -p "$HOME/.config/docker"

# Change shell to zsh
echo "Changing default shell to zsh..."
if [[ "$OS" == "Darwin" ]]; then
    if [[ "$SHELL" != "/bin/zsh" ]]; then
        chsh -s /bin/zsh
    fi
elif [[ "$OS" == "Linux" ]]; then
    if command -v zsh &> /dev/null; then
        if [[ "$SHELL" != "/bin/zsh" ]]; then
            chsh -s /bin/zsh
        fi
    fi
fi

# Initialize version managers in current shell
echo "Initializing version managers..."
export NVM_DIR="$HOME/.nvm"
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    . "$NVM_DIR/nvm.sh"
fi

export GOENV_ROOT="$HOME/.goenv"
if [[ -d "$GOENV_ROOT" ]]; then
    export PATH="$GOENV_ROOT/bin:$PATH"
    eval "$(goenv init -)"
fi

if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    . "$HOME/.sdkman/bin/sdkman-init.sh"
fi

echo ""
echo "======================================"
echo "Installation complete!"
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: exec zsh"
echo "2. Install NVM Node versions: nvm install --lts"
echo "3. Install Go versions: goenv install 1.22"
echo "4. Install Java: sdk install java 21.0.2-tem"
echo "5. Press Ctrl+b I in tmux to install plugins"
echo "======================================"
