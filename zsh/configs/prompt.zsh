setopt prompt_subst     # enable command substition in prompt

zle_highlight=(default:fg=cyan)     # greater visibility for typed commands
PROMPT='%F{green}%m%f %F{yellow}%~%f %# '

# Use my customized fancy zsh-git-prompt
[[ -d "${HOME}/.zsh/plugins/zsh-git-prompt" ]] && \
  source "${HOME}/.zsh/plugins/zsh-git-prompt//zsh-git-prompt.sh"

function zle-keymap-select redraw-prompt {
    NORMAL_MODE="%{$fg[black]%} %{$bg[yellow]%} NORMAL %{$reset_color%}"
    VI_RPROMPT="${${KEYMAP/vicmd/$NORMAL_MODE}/(main|viins)/}"

    RPROMPT="${VI_RPROMPT}"

    # read from git status from temp file
    [[ -r /tmp/zsh_prompt_$$ ]] && \
        RPROMPT+=" $(cat /tmp/zsh_prompt_$$)"

    # redisplay
    zle && zle reset-prompt
}

zle -N zle-keymap-select

ASYNC_PROC=0
function precmd() {
    function async() {
        # guard against missing $(git_super_status)
        [[ ! -f "${HOME}/.zsh/plugins/zsh-git-prompt//zsh-git-prompt.sh" ]] && \
            return

        # save to temp file
        printf "%s" "$(git_super_status)" > "/tmp/zsh_prompt_$$"

        # signal parent
        kill -s USR1 $$
    }

    # do not clear RPROMPT, let it persist

    # kill child if necessary
    if [[ "${ASYNC_PROC}" != 0 ]]; then
        kill -s HUP $ASYNC_PROC >/dev/null 2>&1 || :
    fi

    # start background computation
    async &!
    ASYNC_PROC=$!
}

function TRAPUSR1() {
    # reset proc number
    ASYNC_PROC=0

    redraw-prompt
}
