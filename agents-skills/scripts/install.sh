#!/bin/bash
set -e

# Setup script for agents-skills
# Creates symlinks from kiro/pi skill directories to the canonical source.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CANONICAL_DIR="$REPO_ROOT/skills"

# All locations that should resolve to the canonical skills directory.
# Format: "target_dir|relative_symlink_path"
# The relative path is computed from target_dir's *physical* parent back to
# CANONICAL_DIR. Note that ~/.config/kiro and ~/.kiro are themselves symlinks
# into ~/.dotfiles/kiro/, so their skill paths share inodes with the dotfiles
# paths below and are intentionally omitted.
LINK_TARGETS=(
    "$HOME/.dotfiles/kiro/.config/kiro/skills|../../../agents-skills/skills"
    "$HOME/.dotfiles/kiro/.kiro/skills|../../agents-skills/skills"
    "$HOME/.dotfiles/pi/.config/pi/agent/skills|../../../../agents-skills/skills"
    "$HOME/.pi/agent/skills|../../.dotfiles/agents-skills/skills"
)

# List all skills in the canonical directory
list_skills() {
    echo -e "${BLUE}Available skills (${CANONICAL_DIR}):${NC}"
    echo "================================"

    local count=0
    for skill_dir in "$CANONICAL_DIR"/*/; do
        [[ -f "$skill_dir/SKILL.md" ]] || continue
        local skill_name="$(basename "$skill_dir")"
        local description="$(get_skill_description "$skill_dir")"
        echo -e "  ${GREEN}$skill_name${NC}"
        echo -e "    ${YELLOW}$description${NC}"
        ((count++))
    done

    echo ""
    echo -e "Total: ${GREEN}$count${NC} skills"
}

# Extract description from SKILL.md YAML frontmatter
get_skill_description() {
    local skill_dir="$1"
    local skill_file="$skill_dir/SKILL.md"

    if [[ -f "$skill_file" ]]; then
        awk '/^description:/ {sub(/^description:[[:space:]]*/, ""); print; exit}' "$skill_file" 2>/dev/null || echo "No description"
    else
        echo "No SKILL.md found"
    fi
}

# Create or repair symlinks for all configured locations
setup_links() {
    echo -e "${BLUE}Setting up agents-skills symlinks...${NC}"

    local fixed=0
    for entry in "${LINK_TARGETS[@]}"; do
        local target="${entry%%|*}"
        local rel_link="${entry##*|}"

        # Create parent directory if it doesn't exist
        local parent
        parent="$(dirname "$target")"
        mkdir -p "$parent"

        if [[ -L "$target" ]]; then
            local current_link
            current_link="$(readlink "$target")"
            if [[ "$current_link" == "$rel_link" ]]; then
                echo -e "  ${GREEN}✓${NC} $target"
                continue
            else
                echo -e "  ${YELLOW}↻${NC} $target (wrong target: $current_link)"
                rm "$target"
            fi
        elif [[ -e "$target" ]]; then
            echo -e "  ${YELLOW}⚠${NC} $target exists as real file/dir — moving to $target.backup"
            mv "$target" "$target.backup"
        fi

        ln -s "$rel_link" "$target"
        echo -e "  ${GREEN}✓${NC} $target -> $rel_link"
        ((fixed++))
    done

    echo ""
    echo -e "${GREEN}Done.${NC} $fixed new/repaired symlinks."
}

# Show status of all configured locations and installed skills
show_status() {
    echo -e "${BLUE}Symlink status:${NC}"
    echo "==============="

    local all_ok=1
    for entry in "${LINK_TARGETS[@]}"; do
        local target="${entry%%|*}"
        local expected="${entry##*|}"

        if [[ -L "$target" ]]; then
            local current_link
            current_link="$(readlink "$target")"
            if [[ "$current_link" == "$expected" ]]; then
                echo -e "  ${GREEN}✓${NC} $target -> $current_link"
            else
                echo -e "  ${YELLOW}⚠${NC} $target -> $current_link (expected: $expected)"
                all_ok=0
            fi
        elif [[ -e "$target" ]]; then
            echo -e "  ${RED}✗${NC} $target is a real file/dir, not a symlink"
            all_ok=0
        else
            echo -e "  ${RED}✗${NC} $target missing"
            all_ok=0
        fi
    done

    echo ""
    if [[ $all_ok -eq 1 ]]; then
        echo -e "${GREEN}All symlinks OK.${NC}"
    else
        echo -e "${YELLOW}Run '$0 setup' to repair.${NC}"
    fi

    echo ""
    echo -e "${BLUE}Skills in canonical directory:${NC} $(ls -1 "$CANONICAL_DIR"/*/SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
}

# Verify that all symlinked locations can read the same skill files
verify() {
    echo -e "${BLUE}Verifying skill visibility...${NC}"

    local first_count
    first_count=$(ls "$CANONICAL_DIR" | wc -l | tr -d ' ')

    # Check runtime access paths (kiro is reached through ~/.config/kiro which
    # symlinks into ~/.dotfiles/kiro/.config/kiro).
    local check_paths=(
        "$HOME/.config/kiro/skills"
        "$HOME/.kiro/skills"
        "$HOME/.pi/agent/skills"
    )

    for target in "${check_paths[@]}"; do
        if [[ ! -e "$target" ]]; then
            echo -e "  ${RED}✗${NC} $target missing"
            continue
        fi
        local count
        count=$(ls "$target" | wc -l | tr -d ' ')
        if [[ "$count" == "$first_count" ]]; then
            echo -e "  ${GREEN}✓${NC} $target -> $count skills"
        else
            echo -e "  ${RED}✗${NC} $target -> $count skills (expected $first_count)"
        fi
    done
}

# Print usage
usage() {
    echo -e "${BLUE}agents-skills setup${NC}"
    echo "===================="
    echo "Commands:"
    echo "  list       - List all available skills"
    echo "  setup      - Create/repair all symlinks to the canonical source"
    echo "  status     - Show symlink and skill status"
    echo "  verify     - Verify kiro/pi see the same skills"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 setup"
    echo "  $0 status"
    echo "  $0 verify"
}

main() {
    case "${1:-}" in
        list)
            list_skills
            ;;
        setup)
            setup_links
            verify
            ;;
        status)
            show_status
            ;;
        verify)
            verify
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
