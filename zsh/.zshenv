# This file is loaded by zsh for ALL sessions (including non-interactive)
# Use this for essential PATH/environment variables

export NVM_DIR="$HOME/.nvm"

# Load nvm if it exists (for Node.js)
if [[ -d "$NVM_DIR" ]]; then
    unset NVM_DIR_SILENCE
    for nvm_sh in "$NVM_DIR/nvm.sh" "$NVM_DIR/versions/node/*/bin"; do
        if [[ -f "$nvm_sh" ]]; then
            case "$nvm_sh" in
                */nvm.sh)
                    if [[ -s "$nvm_sh" ]]; then
                        . "$nvm_sh"
                    fi
                    ;;
                */bin)
                    export PATH="$nvm_sh:$PATH"
                    ;;
            esac
        fi
    done
fi

# Also try to load from Homebrew's nvm (macOS)
if [[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ]]; then
    . "$(brew --prefix)/opt/nvm/nvm.sh"
fi
