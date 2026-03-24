# This file is loaded by zsh for ALL sessions (including non-interactive)
# Use this for essential PATH/environment variables

export NVM_DIR="$HOME/.nvm"

# Load nvm as a function
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    . "$NVM_DIR/nvm.sh"
fi

# Set default node version if not set
if [[ -z "$NODE_PATH" ]] && [[ -d "$NVM_DIR/versions/node" ]]; then
    # Use the latest LTS version
    LTS_VERSION=$(ls -1 "$NVM_DIR/versions/node" | grep "^v20" | sort -V | tail -1)
    if [[ -n "$LTS_VERSION" ]]; then
        export PATH="$NVM_DIR/versions/node/$LTS_VERSION/bin:$PATH"
    fi
fi
