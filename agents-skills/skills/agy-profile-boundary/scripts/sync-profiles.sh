#!/usr/bin/env bash
set -euo pipefail

# Synchronize shared host tool configs, skills, and always-on global rules into
# all Antigravity profiles (~/.antigravity-profiles/*) while keeping AGY auth,
# keychains, and conversation state strictly isolated per profile.

REAL_HOME="${HOME%/.antigravity-profiles/*}"
SKILLS_SRC="$REAL_HOME/.dotfiles/agents-skills/skills"
PLUGIN_SRC="$REAL_HOME/.dotfiles/agents-skills/agy-plugins/agy-profile-boundary"
GLOBAL_RULE="$REAL_HOME/.gemini/GEMINI.md"
PROFILES_ROOT="$REAL_HOME/.antigravity-profiles"

link_item() {
    local src="$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"

    if [[ -L "$dst" ]]; then
        local cur
        cur="$(readlink "$dst")"
        if [[ "$cur" == "$src" ]]; then
            echo "  ✓ $dst -> $src"
            return 0
        fi
        rm -f "$dst"
    elif [[ -e "$dst" ]]; then
        echo "  ⚠ Backing up existing $dst -> ${dst}.bak"
        rm -rf "${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi

    ln -s "$src" "$dst"
    echo "  ✓ Linked $dst -> $src"
}

echo "=== Syncing Main Antigravity ($REAL_HOME/.gemini) ==="
[[ -d "$SKILLS_SRC" ]] && link_item "$SKILLS_SRC" "$REAL_HOME/.gemini/config/skills"
[[ -d "$PLUGIN_SRC" ]] && link_item "$PLUGIN_SRC" "$REAL_HOME/.gemini/config/plugins/agy-profile-boundary"

if [[ -d "$PROFILES_ROOT" ]]; then
    for profile_dir in "$PROFILES_ROOT"/*; do
        [[ -d "$profile_dir" ]] || continue
        profile_name="$(basename "$profile_dir")"
        echo "=== Syncing Profile: $profile_name ($profile_dir) ==="

        # 1. Shared Antigravity skills & always-on global rule plugin
        [[ -d "$SKILLS_SRC" ]] && link_item "$SKILLS_SRC" "$profile_dir/.gemini/config/skills"
        [[ -d "$PLUGIN_SRC" ]] && link_item "$PLUGIN_SRC" "$profile_dir/.gemini/config/plugins/agy-profile-boundary"
        [[ -f "$GLOBAL_RULE" ]] && link_item "$GLOBAL_RULE" "$profile_dir/.gemini/GEMINI.md"

        # 2. Shared host dev credentials/configs (prevent split state when running CLI tools)
        [[ -e "$REAL_HOME/.android" ]]   && link_item "$REAL_HOME/.android"   "$profile_dir/.android"
        [[ -e "$REAL_HOME/.gitconfig" ]] && link_item "$REAL_HOME/.gitconfig" "$profile_dir/.gitconfig"
        [[ -e "$REAL_HOME/.ssh" ]]       && link_item "$REAL_HOME/.ssh"       "$profile_dir/.ssh"
    done
fi

echo "Done."
