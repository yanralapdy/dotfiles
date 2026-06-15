#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KIRO_SKILLS_DIR="$HOME/.config/kiro/skills"
SKILLS_SRC_DIR="$REPO_ROOT/skills"

# Check if kiro-cli is installed
check_kiro_installed() {
    if ! command -v kiro-cli &> /dev/null; then
        echo -e "${RED}Error: kiro-cli is not installed or not in PATH${NC}"
        echo "Install kiro-cli first: https://kiro.dev/docs/cli/installation/"
        exit 1
    fi
}

# Find all skills in the repo
find_skills() {
    find "$SKILLS_SRC_DIR" -name "SKILL.md" -type f | while read -r skill_file; do
        local skill_dir="$(dirname "$skill_file")"
        local skill_name="$(basename "$skill_dir")"
        local category="$(basename "$(dirname "$skill_dir")")"
        echo "$category:$skill_name:$skill_dir"
    done
}

# Extract description from SKILL.md
get_skill_description() {
    local skill_dir="$1"
    local skill_file="$skill_dir/SKILL.md"
    
    if [[ -f "$skill_file" ]]; then
        # Extract description from YAML frontmatter
        awk '/^description:/ {print substr($0, index($0, $2)); exit}' "$skill_file" 2>/dev/null || echo "No description"
    else
        echo "No SKILL.md found"
    fi
}

# List all available skills
list_skills() {
    echo -e "${BLUE}Available skills:${NC}"
    echo "=================="
    
    for category in engineering productivity misc; do
        local category_dir="$SKILLS_SRC_DIR/$category"
        [[ -d "$category_dir" ]] || continue
        
        local has_skills=0
        for skill_dir in "$category_dir"/*/; do
            [[ -f "$skill_dir/SKILL.md" ]] && has_skills=1 && break
        done
        [[ $has_skills -eq 0 ]] && continue
        
        echo -e "\n${GREEN}$(echo "$category" | tr '[:lower:]' '[:upper:]'):${NC}"
        for skill_dir in "$category_dir"/*/; do
            [[ -f "$skill_dir/SKILL.md" ]] || continue
            local skill_name="$(basename "$skill_dir")"
            local installed=""
            if [[ -L "$KIRO_SKILLS_DIR/$skill_name" ]]; then
                installed=" ${GREEN}✓${NC}"
            fi
            local description="$(get_skill_description "$skill_dir")"
            echo -e "  $skill_name$installed"
            echo -e "    ${YELLOW}$description${NC}"
        done
    done
}

# Install a skill
install_skill() {
    local skill_name="$1"
    local skill_dir="$2"
    
    if [[ -z "$skill_dir" ]]; then
        # Find skill by name
        skill_dir=""
        while IFS=: read -r category found_name found_dir; do
            if [[ "$found_name" == "$skill_name" ]]; then
                skill_dir="$found_dir"
                break
            fi
        done < <(find_skills)
        
        if [[ -z "$skill_dir" ]]; then
            echo -e "${RED}Error: Skill '$skill_name' not found${NC}"
            return 1
        fi
    fi
    
    local target="$KIRO_SKILLS_DIR/$skill_name"
    
    # Check if already installed
    if [[ -L "$target" ]]; then
        local current_link="$(readlink "$target")"
        if [[ "$current_link" == "$skill_dir" ]]; then
            echo -e "${YELLOW}Skill '$skill_name' is already installed${NC}"
            return 0
        else
            echo -e "${YELLOW}Skill '$skill_name' is already installed from different source${NC}"
            echo -e "  Current: $current_link"
            echo -e "  New: $skill_dir"
            read -p "Overwrite? (y/N): " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && return 0
        fi
    fi
    
    # Create symlink
    mkdir -p "$KIRO_SKILLS_DIR"
    ln -sfn "$skill_dir" "$target"
    echo -e "${GREEN}Installed skill '$skill_name'${NC}"
}

# Install all skills
install_all() {
    echo -e "${BLUE}Installing all skills...${NC}"
    local count=0
    
    while IFS=: read -r category skill_name skill_dir; do
        if install_skill "$skill_name" "$skill_dir"; then
            ((count++))
        fi
    done < <(find_skills)
    
    echo -e "${GREEN}Installed $count skills${NC}"
}

# Install by category
install_category() {
    local target_category="$1"
    echo -e "${BLUE}Installing $target_category skills...${NC}"
    local count=0
    
    while IFS=: read -r category skill_name skill_dir; do
        if [[ "$category" == "$target_category" ]]; then
            if install_skill "$skill_name" "$skill_dir"; then
                ((count++))
            fi
        fi
    done < <(find_skills)
    
    echo -e "${GREEN}Installed $count $target_category skills${NC}"
}

# Uninstall a skill
uninstall_skill() {
    local skill_name="$1"
    local target="$KIRO_SKILLS_DIR/$skill_name"
    
    if [[ -L "$target" ]]; then
        rm "$target"
        echo -e "${GREEN}Uninstalled skill '$skill_name'${NC}"
    else
        echo -e "${YELLOW}Skill '$skill_name' is not installed${NC}"
    fi
}

# Show status
show_status() {
    echo -e "${BLUE}Installed skills:${NC}"
    echo "================="
    
    if [[ ! -d "$KIRO_SKILLS_DIR" ]]; then
        echo "No skills installed"
        return
    fi
    
    local found=0
    for skill_link in "$KIRO_SKILLS_DIR"/*; do
        if [[ -L "$skill_link" ]]; then
            local skill_name="$(basename "$skill_link")"
            local source="$(readlink "$skill_link")"
            local description="$(get_skill_description "$source")"
            
            echo -e "${GREEN}$skill_name${NC}"
            echo -e "  Source: $source"
            echo -e "  Description: ${YELLOW}$description${NC}"
            echo
            found=1
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        echo "No skills installed"
    fi
}

# Main
main() {
    check_kiro_installed
    
    case "${1:-}" in
        list)
            list_skills
            ;;
        install)
            case "${2:-}" in
                --all)
                    install_all
                    ;;
                --category)
                    if [[ -z "${3:-}" ]]; then
                        echo -e "${RED}Error: Category required${NC}"
                        echo "Usage: $0 install --category <engineering|productivity|misc>"
                        exit 1
                    fi
                    install_category "$3"
                    ;;
                *)
                    if [[ -z "${2:-}" ]]; then
                        echo -e "${RED}Error: Skill name required${NC}"
                        echo "Usage: $0 install <skill-name>"
                        exit 1
                    fi
                    install_skill "$2"
                    ;;
            esac
            ;;
        uninstall)
            if [[ -z "${2:-}" ]]; then
                echo -e "${RED}Error: Skill name required${NC}"
                echo "Usage: $0 uninstall <skill-name>"
                exit 1
            fi
            uninstall_skill "$2"
            ;;
        status)
            show_status
            ;;
        *)
            echo -e "${BLUE}kiro-skills installer${NC}"
            echo "======================"
            echo "Commands:"
            echo "  list                    - List all available skills"
            echo "  install <skill>         - Install specific skill"
            echo "  install --all           - Install all skills"
            echo "  install --category <cat>- Install all skills in category"
            echo "  uninstall <skill>       - Uninstall skill"
            echo "  status                  - Show installed skills"
            echo ""
            echo "Examples:"
            echo "  $0 list"
            echo "  $0 install tdd"
            echo "  $0 install --category engineering"
            echo "  $0 install --all"
            echo "  $0 uninstall tdd"
            echo "  $0 status"
            ;;
    esac
}

main "$@"
