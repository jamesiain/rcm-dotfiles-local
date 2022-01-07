setopt prompt_subst     # enable command substition in prompt

zle_highlight=(default:fg=cyan)     # greater visibility for typed commands

preexec() {
    cmd_timestamp=$(( EPOCHREALTIME*1000 ))

    [[ -z $BUFFER ]] && cmd_empty=TRUE
}

precmd() {
    local stop=$(( EPOCHREALTIME*1000 ))
    local start=${cmd_timestamp:-$stop}
    integer elapsed=$stop-$start

    if [[ -n $cmd_empty ]]; then
        echo "$fg[black]$bg[magenta] ELAPSED TIME: $elapsed ms $reset_color"
        echo ""    # Print a blank line before rendering the new prompt
    fi

    unset cmd_timestamp
    unset cmd_empty
}

zmodload zsh/datetime

function zle-line-init zle-keymap-select {
    # Git status information for shell prompt
    [[ -d $(brew --prefix)/opt/gitstatus ]] && \
      source $(brew --prefix)/opt/gitstatus/gitstatus.prompt.zsh

    if [[ -n $SSH_CONNECTION ]]; then
        LOCAL_COLOR="magenta"
    else
        LOCAL_COLOR="green"
    fi

    PROMPT="%F{${LOCAL_COLOR}}%n@%m%f %F{yellow}%3~%f %# "

    NORMAL_MODE="%{$fg[black]%} %{$bg[yellow]%} NORMAL %{$reset_color%}"
    VI_RPROMPT="${${KEYMAP/vicmd/$NORMAL_MODE}/(main|viins)/}"

    RPROMPT="${VI_RPROMPT} ${GITSTATUS_PROMPT}"

    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

function change-prompt-on-accept-line {
    PROMPT="%# "
    if [[ -n $BUFFER ]]; then
        RPROMPT="%F{magenta} %D %* %f"
    else
        RPROMPT=""
    fi
    zle reset-prompt
    zle accept-line
}

zle -N change-prompt-on-accept-line
bindkey "^M" change-prompt-on-accept-line
