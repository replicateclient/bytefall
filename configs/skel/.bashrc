if [[ -f /usr/share/bytefall/branding/ascii/bytefall.ansi ]]; then
  sed 's/\\e/\x1b/g' /usr/share/bytefall/branding/ascii/bytefall.ansi
fi

PS1='\[\e[38;2;103;232;249m\][Bytefall]\[\e[0m\] \[\e[38;2;139;92;246m\]\w\[\e[0m\] \$ '

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

if [[ -z "${BYTEFALL_NO_FASTFETCH:-}" && -z "${BYTEFALL_FASTFETCH_SHOWN:-}" && $- == *i* ]] && command -v fastfetch >/dev/null 2>&1; then
  export BYTEFALL_FASTFETCH_SHOWN=1
  fastfetch --config bytefall
fi

alias ls='eza --group-directories-first --icons=auto'
alias ll='eza -la --group-directories-first --icons=auto'
alias cat='bat --paging=never'
alias grep='rg'
alias top='btop'
