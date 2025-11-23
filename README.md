# My Dotfiles (Stow-powered)

Managed with GNU Stow → super clean, declarative symlinking, no more manual copying!

## Prerequisites

Make sure you have these installed:

```bash
# macOS
brew install stow zsh tmux neovim

# Ubuntu / Debian
sudo apt install stow zsh tmux neovim

# Arch Linux
sudo pacman -S stow zsh tmux neovim stow
```
## Quick Install (One-liner)

```bash
# Clone the repo (you can put it anywhere, ~/.dotfiles is conventional)
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Stow everything at once
stow --dotfiles -v */

# Or stow individually if you prefer
# stow --dotfiles -v zsh kitty tmux nvim karabiner yazi shellscript
```
# Detailed Per-Package Setup
### zsh + Oh My Zsh
```bash
# Oh My Zsh is installed automatically on first zsh launch
# thanks to zsh/.zshrc → just open a new terminal after stowing
```
### Tmux + TPM (Tmux Plugin Manager)
```bash
# After stowing tmux/
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Then inside tmux:
# Press prefix + I (default prefix is Ctrl-b) to install all plugins
```
### Neovim (lazy.nvim – default & recommended)
Just open Neovim after stowing:
```bash
nvim
```
### Kitty terminal
Automatically available after stow kitty (macOS + Linux).
### Karabiner-Elements (macOS only)
```bash
stow karabiner   # symlinks karabiner.json into ~/.config/karabiner/assets/complex_modifications/
```
### Yazi file manager
```bash
yazi
```
### Custom shell scripts (tns, etc.)
All scripts are symlinked into ~/scripts/ (or ~/.local/bin/ if you prefer).
Make sure the directory is in your $PATH.
Example usage after install:
```bash
tns m_d 3 s_n myproject ~/projects   # search max-depth 3, session name "myproject"
```
# Updating
```bash
cd ~/.dotfiles
git pull
stow --restow --dotfiles -v */   # or just the ones you changed
```
# Uninstalling / Removing a package
```bash
stow -D zsh        # example: remove only zsh symlinks
# or remove everything
stow -D --dotfiles */
```
Enjoy a clean, portable, and maintainable dotfiles setup!
