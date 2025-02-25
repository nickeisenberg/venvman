if [ -z "$VENVMAN_ROOT_DIR" ]; then
    VENVMAN_ROOT_DIR="${HOME}/.venvman"
fi

if [ ! -d $VENVMAN_ROOT_DIR ]; then
    mkdir -p $VENVMAN_ROOT_DIR
fi

. "${VENVMAN_ROOT_DIR}/venvman/src/variables.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/venvman/venvman.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/completion/completion.sh"
