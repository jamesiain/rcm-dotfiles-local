setopt prompt_subst     # enable command substition in prompt

zle_highlight=(default:fg=cyan)     # greater visibility for typed commands

function zle-line-init zle-keymap-select {
    # Git status information for shell prompt
    [[ -d $(brew --prefix)/opt/gitstatus ]] && \
      source $(brew --prefix)/opt/gitstatus/gitstatus.prompt.zsh

    PROMPT='%F{green}%n@%m%f %F{yellow}%3~%f %# '

    NORMAL_MODE="%{$fg[black]%} %{$bg[yellow]%} NORMAL %{$reset_color%}"
    VI_RPROMPT="${${KEYMAP/vicmd/$NORMAL_MODE}/(main|viins)/}"

    RPROMPT="${VI_RPROMPT} ${GITSTATUS_PROMPT}"

    zle reset-prompt    # redisplay
}

zle -N zle-line-init
zle -N zle-keymap-select
