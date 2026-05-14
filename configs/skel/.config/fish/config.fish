set -g fish_greeting

if status is-interactive
    if type -q starship
        starship init fish | source
    end

    if not set -q BYTEFALL_NO_FASTFETCH
        if not set -q BYTEFALL_FASTFETCH_SHOWN
            if type -q fastfetch
                set -gx BYTEFALL_FASTFETCH_SHOWN 1
                fastfetch --config bytefall
            end
        end
    end
end

if type -q eza
    alias ls='eza --group-directories-first --icons=auto'
    alias ll='eza -la --group-directories-first --icons=auto'
end

if type -q bat
    alias cat='bat --paging=never'
end

if type -q rg
    alias grep='rg'
end

if type -q btop
    alias top='btop'
end
