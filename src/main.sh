if [ -n "$ZSH_VERSION" ]; then
    setopt local_options KSH_ARRAYS
fi

. "${VENVMAN_ROOT_DIR}/venvman/src/venvman.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/completion/completion.sh"
