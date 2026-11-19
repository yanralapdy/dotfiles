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
# git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
git clone git@github.com:yanralapdy/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# stow the directory
stow zsh kitty tmux nvim karabiner yazi shellscript kiro pi
```

> Cross-platform: configs work on both macOS and Ubuntu/WSL. Paths use `$HOME`/`~`
> and OS detection, so the same repo runs on either machine regardless of username.
> `karabiner` is macOS-only.
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
### Custom shell scripts (tns, phone, etc.)
All scripts live in `shellscript/.local/scripts/` (stowed to `~/.local/scripts/`).
Example usage after install:
```bash
# Fuzzy-find project directory and attach/create tmux session
tns "path=$HOME/sites;m_d=4;s_n=prosper"

# Control Android phone with Mac mouse & keyboard via scrcpy UHID mode (requires: brew install scrcpy)
phone        # Auto-discover over Wi-Fi mDNS (or USB) and attach mouse/keyboard (no video by default)
phone -v     # Mirror Android screen video in a window on Mac + mouse/keyboard
phone -l     # Force phone into landscape (even portrait-only apps) and restore on exit
phone -l -w  # Landscape + keep screen awake
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
stow -D .
```

### Kiro CLI & Pi agent configs
```bash
stow kiro pi   # symlinks ~/.kiro, ~/.config/kiro, and ~/.config/pi
```
Agent skill references use `~`, so they resolve on any machine.

# Agent Skills (Optional)

The `agents-skills/` directory is the single canonical home for skills used by both **kiro** and **pi**. Skills are adapted from Matt Pocock's skills repository and formatted for kiro-cli / pi.

```bash
cd ~/.dotfiles/agents-skills
./scripts/install.sh list    # See available skills
./scripts/install.sh setup   # Create symlinks for kiro and pi
./scripts/install.sh status  # Verify symlinks
```

Skills include engineering workflows (`tdd`, `diagnose`, `grill-with-docs`), productivity tools (`caveman`, `handoff`), and misc utilities (`git-guardrails`, `setup-pre-commit`).

Run `./scripts/install.sh setup` once on each machine (macOS and WSL) to create the `~/.config/kiro/skills` and `~/.pi/agent/skills` symlinks.

Enjoy a clean, portable, and maintainable dotfiles setup!
