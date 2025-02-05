source_shell_completion() {
    local SHELL_NAME=$1
    local COMPLETION_PATH=$VENVMAN_ROOT_DIR/venvman/src/completion/venvman_${SHELL_NAME}_completion.sh
    source $COMPLETION_PATH || echo "ERROR: $COMPLETION_PATH could not be sourced. venvman will have no tab-completion."
    complete -F _venvman_bash_completion venvman || echo "ERROR: completion could not be added to venvman."
}

if [[ $SHELL == *"bash"*  ]]; then
    source_shell_completion "bash"
elif [[ $SHELL == *"zsh"*  ]]; then
    source_shell_completion "zsh"
fi

unset -f source_shell_completion
