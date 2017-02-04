setopt prompt_subst     # enable command substition in prompt

zle_highlight=(default:fg=cyan)     # greater visibility for typed commands
PROMPT='%F{green}%m%f %F{yellow}%~%f %# '

# Use my customized fancy zsh-git-prompt
[[ -d "${HOME}/.zsh/plugins/zsh-git-prompt" ]] && \
  source "${HOME}/.zsh/plugins/zsh-git-prompt//zsh-git-prompt.sh"
RPROMPT='' # no initial prompt, set dynamically

ASYNC_PROC=0
function precmd() {
    function async() {
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
    # read from temp file
    RPROMPT="$(cat /tmp/zsh_prompt_$$)"

    # reset proc number
    ASYNC_PROC=0

    # redisplay
    zle && zle reset-prompt
}
