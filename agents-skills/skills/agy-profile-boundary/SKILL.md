---
name: agy-profile-boundary
description: Enforce path and environment boundaries between the real host home directory and isolated Antigravity multi-account profiles (~/.antigravity-profiles/*). Use when running inside an agy-alt profile, editing dotfiles or shell scripts, configuring CLI tools (git, adb, ssh, docker, npm, brew), or managing Antigravity skills, rules, plugins, and profile state.
---

# Antigravity Profile vs. Host Boundary (`agy-alt`)

Antigravity secondary profiles (`agyalt`, `agyalt2`, `agyalt3`, `agy-alt*`) launch with `HOME` overridden to `~/.antigravity-profiles/<profile>` so each account keeps an isolated macOS Keychain, OAuth token, and Electron user-data directory.

Consequently, `$HOME` and `~` inside an `agy-alt` session point to the **sandboxed profile directory**, NOT the real host user home.

## 1. Resolve `REAL_HOME` vs. `PROFILE_HOME`

Before reading/writing user files or running host CLI tools, resolve both roots:

```bash
PROFILE_HOME="$HOME"
REAL_HOME="${HOME%/.antigravity-profiles/*}"
```

- On main Antigravity (`agymain`), `REAL_HOME` and `PROFILE_HOME` are identical (`/Users/<user>`).
- On secondary profiles (`alt`, `alt2`, `alt3`), `REAL_HOME` is `/Users/<user>` and `PROFILE_HOME` is `/Users/<user>/.antigravity-profiles/<profile>`.

## 2. Routing Matrix: What Goes Where

| Target Category | Root to Use | Examples |
| :--- | :--- | :--- |
| **Dotfiles & Shell Config** | `REAL_HOME` | `$REAL_HOME/.dotfiles/`, `$REAL_HOME/.zshrc`, `$REAL_HOME/.secrets` |
| **User Scripts & Binaries** | `REAL_HOME` | `$REAL_HOME/.local/scripts/`, `$REAL_HOME/.local/bin/` |
| **Shared Agent Skills** | `REAL_HOME` | `$REAL_HOME/.dotfiles/agents-skills/skills/` (symlinked into every profile) |
| **Global Always-On Rules** | `REAL_HOME` | `$REAL_HOME/.gemini/GEMINI.md` (symlinked into every profile's `.gemini/GEMINI.md`) |
| **Host Dev Tools & Auth** | `REAL_HOME` | `.gitconfig`, `.ssh/`, `.android/`, `.config/docker/`, `.colima/`, `.npm/`, `.nvm/`, `.bun/`, `.cargo/` |
| **Workspaces & Notes** | `REAL_HOME` | `$REAL_HOME/sites/`, `$REAL_HOME/brain-dump/` |
| **AGY Account Auth (Isolated)** | `PROFILE_HOME` | `$PROFILE_HOME/.gemini/jetski-standalone-oauth-token`, `$PROFILE_HOME/Library/Keychains/login.keychain-db` |
| **AGY App State & Conversations** | `PROFILE_HOME` | `$PROFILE_HOME/.gemini/antigravity/` (`brain/`, `conversations/`, `scratch/`, `daemon/`), `$PROFILE_HOME/.gemini/config/config.json` |
| **AGY IDE Extensions & UI Data** | `PROFILE_HOME` | `$PROFILE_HOME/Library/Application Support/Antigravity/`, `$PROFILE_HOME/.antigravity/extensions/` |

## 3. Rules for Running Commands & Editing Configs

1. **Never write host tool configs into `$PROFILE_HOME`:**
   When installing or configuring apps, CLIs, or dotfiles (`git`, `adb`, `scrcpy`, `docker`, `npm`, `zsh`, `nvim`, `tmux`), always target `$REAL_HOME`.
2. **Pass `HOME="$REAL_HOME"` to host-stateful daemons:**
   Daemons like `adb start-server`, `colima`, or `git commit` read `$HOME`. Either prefix with `HOME="$REAL_HOME"` or ensure `.android`, `.gitconfig`, and `.ssh` are symlinked from `$PROFILE_HOME` to `$REAL_HOME`.
3. **Never cross-link isolated Antigravity auth/state:**
   Never symlink or copy `jetski-standalone-oauth-token`, `Library/Keychains`, `Library/Application Support/Antigravity`, or `.gemini/antigravity/conversations` across profiles.
4. **Canonical Skill & Rule Synchronization:**
   - Author all shared skills in `$REAL_HOME/.dotfiles/agents-skills/skills/<skill-name>/SKILL.md`.
   - Repair profile symlinks anytime by running:
     [sync-profiles.sh](./scripts/sync-profiles.sh)
