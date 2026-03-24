# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    git
    you-should-use
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Detect OS
case "$(uname -s)" in
    Linux*)     OS="Linux";;
    Darwin*)    OS="macOS";;
    *)          OS="Unknown";;
esac

# Editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# ============ ALIASES ============
# Python
alias pip='pip3'
alias pip3='pip3'
alias python='python3'

# Node - use nvm directly, no need for version switchers
# Run `nvm use <version>` or set default with `nvm alias default <version>`

# PHP - use brew pin or shims
alias php83='brew link --overwrite php@8.3'
alias php82='brew link --overwrite php@8.2'

# Flutter
alias flutter='fvm flutter'
alias dart='fvm dart'

# Tools
alias f2v='vim $(fzf -m --preview="bat --color=always {}")'
alias tns='~/.local/scripts/tmux-new-session'
alias cnmt='curl --connect-timeout 0 --max-time 0'
alias vim='NVIM_APPNAME=nvim nvim'
alias code='NVIM_APPNAME=nvim nvim'
alias g++='clang++ -std=c++17'

# ============ PATH CONFIGURATION ============
# Base paths
if [[ "$OS" == "macOS" ]]; then
    export PATH="/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin"
    
    # Homebrew Java
    if [[ -d "/opt/homebrew/opt/openjdk@11/bin" ]]; then
        export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
    fi
    
    # PostgreSQL
    if [[ -d "/opt/homebrew/opt/postgresql@16/bin" ]]; then
        export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
    fi
    
    # Ruby
    if [[ -d "/opt/homebrew/opt/ruby/bin" ]]; then
        export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    fi
    
    # MySQL (macOS only)
    if [[ -d "/usr/local/mysql-8.0.32-macos13-arm64/bin" ]]; then
        export PATH="$PATH:/usr/local/mysql-8.0.32-macos13-arm64/bin"
    fi
elif [[ "$OS" == "Linux" ]]; then
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$HOME/.local/bin"
    
    # Linuxbrew paths
    if [[ -d "/home/linuxbrew/.linuxbrew/bin" ]]; then
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    fi
    
    # PostgreSQL (Linux)
    if [[ -d "/usr/lib/postgresql/16/bin" ]]; then
        export PATH="/usr/lib/postgresql/16/bin:$PATH"
    fi
fi

# User paths
export PATH="$HOME/.composer/vendor/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.pub-cache/bin:$PATH"

# Android
if [[ -d "$HOME/Library/Android/sdk" ]]; then
    export ANDROID_HOME=$HOME/Library/Android/sdk
    export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools"
fi

# Kafka (if exists)
if [[ -d "$HOME/Sites/kafka_2.13-3.6.1" ]]; then
    export KAFKA_HOME="$HOME/Sites/kafka_2.13-3.6.1"
fi

# ============ VERSION MANAGERS ============
# NVM (Node.js)
export NVM_DIR="$HOME/.nvm"
if [[ "$OS" == "macOS" ]]; then
    [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"
    [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
else
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Conda (Python) - only initialize if exists
if [[ -d "$HOME/anaconda3" ]]; then
    __conda_setup="$('$HOME/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/anaconda3/etc/profile.d/conda.sh" ]; then
            . "$HOME/anaconda3/etc/profile.d/conda.sh"
        fi
    fi
    unset __conda_setup
fi

# goenv (Go)
export GOENV_ROOT="$HOME/.goenv"
if [[ -d "$GOENV_ROOT" ]]; then
    export PATH="$GOENV_ROOT/bin:$PATH"
    eval "$(goenv init -)"
    export PATH="$GOROOT/bin:$PATH"
    export PATH="$PATH:$GOPATH/bin"
fi

# SDKMAN (Java) - must be at end
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# ============ DOCKER ============
export DOCKER_CONFIG="$HOME/.config/docker"

# ============ FUZZY FINDER ============
if command -v fzf &> /dev/null; then
    source <(fzf --zsh)
fi

# ============ ZOXIDE ============
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# ============ FLUTTER / FVM ============
if [[ -d "$HOME/fvm/default/bin" ]]; then
    export PATH="$HOME/fvm/default/bin:$PATH"
fi
if [[ -d "$HOME/.fvm/versions/stable/bin" ]]; then
    export PATH="$HOME/.fvm/versions/stable/bin:$PATH"
fi

# ============ YAZI ============
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

# ============ DART ============
if [[ -f "$HOME/.dart-cli-completion/zsh-config.zsh" ]]; then
    . "$HOME/.dart-cli-completion/zsh-config.zsh"
fi

# p10k instant prompt
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
