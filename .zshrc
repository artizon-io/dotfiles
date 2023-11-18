# https://apple.stackexchange.com/questions/388622/zsh-zprofile-zshrc-zlogin-what-goes-where
# https://unix.stackexchange.com/questions/71253/what-should-shouldnt-go-in-zshenv-zshrc-zlogin-zprofile-zlogout

# Warp still hasn't supported zsh completions yet (i.e. compdef, compctl, compsys, etc.)
# https://github.com/warpdotdev/Warp/issues/2179

# Custom lib
source ~/.config/zsh/tailscale.sh
source ~/.config/zsh/utils.sh
source ~/.config/zsh/pandoc.sh
source ~/.config/zsh/image.sh
source ~/.config/zsh/browser.sh

# fzf-tab
# https://github.com/Aloxaf/fzf-tab/wiki/Configuration
source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
# preview directory's content with exa when completing cd or ls
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'exa -1 --color=always $realpath'
zstyle ':fzf-tab:*' fzf-min-height 1000

# zsh-autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# zsh-syntax-highlighting
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable zsh completion
autoload -U compinit; compinit
compaudit || (compaudit | xargs chmod go-w)  # Remove group & other write permission for all insecure directories if there are any

check_command_exists() {
    if command -v $1 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

if [ $(arch) = "i386" ]  # OSX rosetta
then
    eval "$($HOME/homebrew-x86/bin/brew shellenv)"

    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    export PYENV_ROOT="$HOME/.pyenv-x86"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pip completion --zsh)"

elif [ $(arch) = "x86_64" ]  # Linux / NixOS
then
    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    if check_command_exists pyenv; then
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"
    fi
    check_command_exists pip && eval "$(pip completion --zsh)"

    export PATH="/usr/local/cuda/bin:$PATH"

    # ZLE bindings
    bindkey "^[[H" beginning-of-line
    bindkey "^[[F" end-of-line
    bindkey "^H" backward-kill-word

    if [[ $(uname -a) =~ "nixos" ]]  # NixOS
    then
        alias nix-gc='nix-collect-garbage -d'
        alias nix-dev='nix develop -c zsh'
        alias kitty-save='kitty @ ls | python ~/.config/kitty/kitty-convert-dump.py > ~/.kitty-session.kitty'
        alias kitty-load='kitty --session ~/.kitty-session.kitty'

        if [[ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]]  # Hyprland
        then
            alias nixos-reload='sudo nixos-rebuild switch --flake ~/nixos-config#hyprland --install-bootloader'
            alias screen-record="bash ~/.config/hypr/screen-record.sh"
        else  # GNOME
            alias nixos-reload='sudo nixos-rebuild switch --flake ~/nixos-config#gnome --install-bootloader'
            alias code='code --disable-gpu'
        fi
    fi
   
else  # OSX m1
    eval "$(/opt/homebrew/bin/brew shellenv)"

    eval "$(starship init zsh)"

    eval "$(zoxide init zsh)"

    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pip completion --zsh)"
fi

export PATH=$HOME/bin:${PATH}

alias ssha='eval $(ssh-agent) && ssh-add'
alias manfzf='man $(echo $(man -k . | fzf) | cut -d " " -f 1)'
alias duf='duf -theme ansi'
alias ll='exa -l'
alias deff='delta --raw'
alias ts-get='sudo tailscale file get'  # Move files out of tailscale inbox
alias ts-send='tailscale_send'  # Move files out of tailscale inbox
alias jq='gojq'

# FZF
# https://github.com/junegunn/fzf/blob/master/ADVANCED.md
FZF_COLORS=$(cat << EOT | tr -d "\n "  # Remove newlines and spaces
    --color=
    bg+:#333333,
    preview-bg:#111111,
    bg:#000000,
    border:#555555,
    spinner:#4C9BFF,
    hl:#777777,
    fg:#777777,
    header:#7E8E91,
    info:#4C9BFF,
    pointer:#4C9BFF,
    marker:#FE946E,
    fg+:#CBD1DA,
    prompt:#FE946E,
    hl+:#FE946E
EOT
)
export FZF_DEFAULT_OPTS="$FZF_COLORS --layout=reverse --info=inline --border --margin=1 --padding=1"

# ZSH history
setopt share_history
export HISTFILE=~/.zhistory
export SAVEHIST=100 # Capacity of no. lines
export HISTSIZE=50 # Capacity of no. lines for a session


export SHELL="$(which zsh)"
export PAGER="bat"
export EDITOR="nvim"
export BROWSER="firefox"
