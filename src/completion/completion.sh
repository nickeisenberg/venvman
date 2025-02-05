if [[ $SHELL == *"bash"*  ]]; then
    source $HOME/.venvman/completion/venvman_bash_completion.sh
    complete -F _venvman_bash_completion venvman
fi
