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
[[ -d ~/.local/bin ]] && export PATH="~/.local/bin:$PATH"
# }}}

# Execute on startup {{{

# clear terminal and show greeting message
clear
[[ -f ~/.zsh/greeting.zsh ]] && ~/.zsh/greeting.zsh

# }}}
