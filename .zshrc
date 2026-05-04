# ---- history ----
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt append_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt hist_verify

# ---- editing ----
bindkey -v
KEYTIMEOUT=1

# ---- completion ----
autoload -Uz compinit
compinit

# ---- fzf ----
if command -v fzf >/dev/null 2>&1; then
  export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
  source <(fzf --zsh)
fi

# ---- starship prompt ----
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# ---- sane defaults ----
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export LESS="-R"

alias ls='ls -G'
alias ll='ls -lah'
alias grep='grep --color=auto'
alias ports='ss -tulpn | bat --file-name "LISTENING PORTS"'
alias v='nvim'
alias myip="$HOME/Scripts/ip_lookup.sh"
alias la='ls -A'
alias lsa='ls -als'
alias l='ls -CF'
alias ..='cd ..'
alias newvenv='python3 -m venv .venv && . .venv/bin/activate'
alias activate='. .venv/bin/activate'
alias zconf='v ~/.zshrc'
alias downloads='cd ~/Downloads/ && ls -alsh'
