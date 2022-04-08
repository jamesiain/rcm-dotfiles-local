setopt prompt_subst     # enable command substition in prompt
setopt print_exit_value # enable printing exit code when non-zero

zle_highlight=(default:fg=cyan)     # greater visibility for typed commands

running_in_docker() {
    if [[ ${OSTYPE} = 'linux'* ]]; then
        (awk -F/ '$2 == "docker"' /proc/self/cgroup | read non_empty_input)
    else
        false
    fi
}

preexec() {
    [[ -z $BUFFER ]] && cmd_empty=TRUE
}

precmd() {
    if [[ -n $cmd_empty ]]; then
        echo ""
    fi

    unset cmd_empty
}

zmodload zsh/datetime

function zle-line-init zle-keymap-select {
    # Git status information for shell prompt
    [[ -d $(brew --prefix)/opt/gitstatus ]] && \
        source $(brew --prefix)/opt/gitstatus/gitstatus.prompt.zsh

    PROMPT=""

    running_in_docker && \
        PROMPT+="%F{blue}%B[ %b%f"

    if [[ -n $SSH_CONNECTION ]]; then
        LOCAL_COLOR="magenta"
    else
        LOCAL_COLOR="green"
    fi

    ZSH_THEME_VIRTUALENV_PREFIX="%F{cyan}["
    ZSH_THEME_VIRTUALENV_SUFFIX="]%f "

    PROMPT+="\$(virtualenv_prompt_info)"
    PROMPT+="%F{%(!.red.blue)}%n%f"
    PROMPT+="%F{cyan}@%f%F{${LOCAL_COLOR}}%m%f %F{yellow}%3~%f %# "

    NORMAL_MODE="%{$fg[black]%} %{$bg[yellow]%} NORMAL %{$reset_color%}"
    VI_RPROMPT="${${KEYMAP/vicmd/$NORMAL_MODE}/(main|viins)/}"

    RPROMPT="${VI_RPROMPT} ${GITSTATUS_PROMPT}"

    running_in_docker && \
        RPROMPT+="%F{blue}%B ]%b%f"

    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

function change-prompt-on-accept-line {
    # PROMPT="%F{magenta}%D %*%f %# "
    PROMPT="%F{magenta}%D{%F %T}%f %# "
    RPROMPT=""

    zle reset-prompt
    zle accept-line
}

zle -N change-prompt-on-accept-line
bindkey "^M" change-prompt-on-accept-line
