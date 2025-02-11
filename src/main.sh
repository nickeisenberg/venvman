if [ -z "$VENVMAN_ROOT_DIR" ] || [ -z "$VENVMAN_ENVS_DIR" ]; then 
    echo "ERROR: VENVMAN_ROOT_DIR and VENVMAN_ENVS_DIR must be set."
    echo "The following is suggested to solve this problem."
    echo

    echo "1) Run the following in you shell:"
    echo
    MSG_LINES=(
        "VENVMAN_ROOT_DIR=\$HOME/.venvman"
        "mkdir -p \$VENVMAN_ROOT_DIR"
        "git clone https://github.com/nickeisenberg/venvman.git "\${VENVMAN_ROOT_DIR}/venvman""
    )
    printf "%s\n" "${MSG_LINES[@]}"

    echo
    echo "2) Add the following in your shell's config:"
    echo
    MSG_LINES=(
        "VENVMAN_ROOT_DIR=\$HOME/.venvman"
        "VENVMAN_ENVS_DIR=\$HOME/.venvman/envs"
        "source \$VENVMAN_ROOT_DIR/venvman/src/venvman.sh"
        "source \$VENVMAN_ROOT_DIR/venvman/src/completion/completion.sh"
    )
    printf "%s\n" "${MSG_LINES[@]}"

    echo
    echo "3) source your shell's config."

    unset MSG_LINES COMMAND
    return 1
fi

. "${VENVMAN_ROOT_DIR}/venvman/src/helpers.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/venvman.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/completion/completion.sh"
