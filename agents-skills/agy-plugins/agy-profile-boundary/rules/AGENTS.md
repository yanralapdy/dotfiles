# Antigravity Profile vs. Host Boundary (`agy-alt`)

Antigravity secondary profiles (`agyalt`, `agyalt2`, `agyalt3`, `agy-alt*`) run with `HOME` set to `~/.antigravity-profiles/<profile>` to isolate per-account OAuth tokens, macOS Keychains, and Electron user data.

Whenever `$HOME` matches `*/.antigravity-profiles/*`, always resolve both roots before accessing user files or running host CLI tools:
- `REAL_HOME="${HOME%/.antigravity-profiles/*}"` (the real host user home, e.g. `/Users/tnkapdy`)
- `PROFILE_HOME="$HOME"` (the isolated Antigravity profile directory)

## Mandatory Routing Rules

1. **Use `REAL_HOME` for all host tools, dotfiles, scripts, and workspaces:**
   - Dotfiles & shell config: `$REAL_HOME/.dotfiles/`, `$REAL_HOME/.zshrc`, `$REAL_HOME/.secrets`
   - User scripts & binaries: `$REAL_HOME/.local/scripts/`, `$REAL_HOME/.local/bin/`
   - Shared agent skills: `$REAL_HOME/.dotfiles/agents-skills/skills/`
   - Dev tools & credentials: `$REAL_HOME/.gitconfig`, `$REAL_HOME/.ssh/`, `$REAL_HOME/.android/`, `$REAL_HOME/.config/docker/`, `$REAL_HOME/.colima/`, `$REAL_HOME/.npm/`, `$REAL_HOME/.nvm/`, `$REAL_HOME/.bun/`, `$REAL_HOME/.cargo/`
   - Projects & notes: `$REAL_HOME/sites/`, `$REAL_HOME/brain-dump/`
   - When starting host-stateful daemons (`adb`, `colima`, `docker`), pass `HOME="$REAL_HOME"` or ensure their config directory is symlinked to `$REAL_HOME`.

2. **Use `PROFILE_HOME` ONLY for Antigravity per-account state (never merge across profiles):**
   - `$PROFILE_HOME/.gemini/jetski-standalone-oauth-token`
   - `$PROFILE_HOME/Library/Keychains/login.keychain-db`
   - `$PROFILE_HOME/Library/Application Support/Antigravity/`
   - `$PROFILE_HOME/.gemini/antigravity/` (`brain/`, `conversations/`, `scratch/`, `daemon/`)
   - `$PROFILE_HOME/.gemini/config/config.json`

3. **Full Reference & Sync Helper:**
   - Read the `agy-profile-boundary` skill (`$REAL_HOME/.dotfiles/agents-skills/skills/agy-profile-boundary/SKILL.md`) or run `$REAL_HOME/.dotfiles/agents-skills/skills/agy-profile-boundary/scripts/sync-profiles.sh` when setting up or repairing profile symlinks.
