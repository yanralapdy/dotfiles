# This file is loaded by zsh for ALL sessions (including non-interactive)
# Use this for essential PATH/environment variables

export NVM_DIR="$HOME/.nvm"

# Load nvm as a function (OS-aware)
if [[ "$(uname -s)" == "Darwin" ]] && command -v brew &>/dev/null; then
    # macOS with Homebrew-installed nvm
    [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
    . "$NVM_DIR/nvm.sh"
fi

# Set default node version if not set
if [[ -z "$NODE_PATH" ]]; then
    if [[ -d "$(brew --prefix)/opt/nvm/versions/node" ]] 2>/dev/null; then
        NODE_VERSIONS_DIR="$(brew --prefix)/opt/nvm/versions/node"
    elif [[ -d "$NVM_DIR/versions/node" ]]; then
        NODE_VERSIONS_DIR="$NVM_DIR/versions/node"
    fi
    if [[ -n "$NODE_VERSIONS_DIR" ]]; then
        LTS_VERSION=$(ls -1 "$NODE_VERSIONS_DIR" 2>/dev/null | grep "^v20" | sort -V | tail -1)
        if [[ -n "$LTS_VERSION" ]]; then
            export PATH="$NODE_VERSIONS_DIR/$LTS_VERSION/bin:$PATH"
        fi
    fi
fi

export KIRO_HOME="$HOME/.config/kiro"
. "$HOME/.cargo/env"

# Neovim (Ubuntu/local install) - must be early in PATH
if [[ -d "$HOME/.local/nvim/bin" ]]; then
    export PATH="$HOME/.local/nvim/bin:$PATH"
fi
