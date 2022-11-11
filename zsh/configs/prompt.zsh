setopt prompt_subst     # enable command substition in prompt

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

function zle-line-init zle-keymap-select zle-line-pre-redraw {
    if [[ ! -z $ACCEPT_LINE ]]; then
        ACCEPT_LINE=""
        return
    fi

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

    if [[ "$KEYMAP" == vicmd ]]; then
        local VISUAL_MODE="%{$fg[black]%} %{$bg[cyan]%} VISUAL %{$reset_color%}"
        local NORMAL_MODE="%{$fg[black]%} %{$bg[yellow]%} NORMAL %{$reset_color%}"

        if (( REGION_ACTIVE )); then
            VI_MODE="$VISUAL_MODE"
        else
            VI_MODE="$NORMAL_MODE"
        fi
    else
        VI_MODE=""
    fi

    RPROMPT="${VI_MODE} ${GITSTATUS_PROMPT}$(svn_prompt_info)"

    running_in_docker && \
        RPROMPT+="%F{blue}%B ]%b%f"

    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select
zle -N zle-line-pre-redraw

ACCEPT_LINE=""
function change-prompt-on-accept-line {
    ACCEPT_LINE="true"
    PROMPT="%F{magenta}%D{%F %T}%f %# "
    RPROMPT=""

    if [[ ! -z $BUFFER ]]; then
        zle reset-prompt
        zle accept-line
    fi
}

zle -N change-prompt-on-accept-line
bindkey -M viins "^M" change-prompt-on-accept-line
bindkey -M vicmd "^M" change-prompt-on-accept-line
