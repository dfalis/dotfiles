# vim:fileencoding=utf-8:foldmethod=marker

# Aliases {{{
alias check_open_ports="sudo netstat -tulpn"
alias get_cpu_temp="vcgencmd measure_temp"
alias sls="screen -ls"
alias la="lsd -la --group-dirs first"
alias ls="lsd"
alias vi="nvim"
alias vim="nvim"
alias tree="ls --tree"
alias gotop="gotop -c monokai"
# }}}

# Export variables {{{
export EDITOR=nvim
export VISUAL=nvim

# add to PATH
[[ -d /opt/vc/bin ]] && export PATH="/opt/vc/bin:$PATH"
[[ -d $HOME/.local/bin ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d $HOME/.npm-modules/bin ]] && export PATH="$HOME/.npm-modules/bin:$PATH"
# }}}

# Execute on startup {{{

# show greeting message
[[ -f ~/.zsh/greeting.zsh ]] && ~/.zsh/greeting.zsh

# }}}

# Start ssh-agent {{{

if ! pgrep -u "$USER" ssh-agent > /dev/null; then
        ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! "$SSH_AUTH_SOCK" ]]; then
        source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

# }}}
