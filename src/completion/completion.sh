source_shell_completion() {
    [[ -n $VENVMAN_ROOT_DIR ]] || VENVMAN_ROOT_DIR="$HOME/.venvman" 
    if [[ $1 == "bash" ]]; then
        source $VENVMAN_ROOT_DIR/venvman/src/completion/venvman_bash_completion.sh
    elif [[ $1 == "zsh" ]]; then
        source $VENVMAN_ROOT_DIR/venvman/src/completion/venvman_zsh_completion.zsh
    fi
}

add_completion_to_venvman() {
    if [[ $1 == "bash" ]]; then
        complete -F _venvman_bash_completion venvman
    elif [[ $1 == "zsh" ]]; then
        compdef _venvman_zsh_completion venvman
    fi
}

main() {
    source_shell_completion $1
    add_completion_to_venvman $1
}

if [[ -n $BASH_VERSION ]]; then
    main "bash"
elif [[ -n $ZSH_VERSION ]]; then
    main "zsh"
fi

unset -f source_shell_completion
unset -f add_completion_to_venvman 
unset -f main 
