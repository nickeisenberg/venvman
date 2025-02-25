#--------------------------------------------------
# venvman
#--------------------------------------------------
set_if_not_exists() {
    if [ -z $(eval "echo \$$1") ]; then
        eval "${1}=${2}"
    fi
}

set_if_not_exists "VENVMAN_ENVS_DIR" "${VENVMAN_ROOT_DIR}/envs"
export VENVMAN_ENVS_DIR

set_if_not_exists "VENVMAN_SRC_DIR" "${VENVMAN_ROOT_DIR}/venvman/src"
export VENVMAN_SRC_DIR
export VENVMAN_UTILS_DIR=${VENVMAN_SRC_DIR}/venvman/utils
export VENVMAN_COMMANDS_DIR=${VENVMAN_SRC_DIR}/venvman/commands

export VENVMAN_CPYTHON_REMOTE_URL="https://github.com/python/cpython.git"

set_if_not_exists "VENVMAN_CPYTHON_REPO_DIR" "${HOME}/.venvman/cpython"
export VENVMAN_CPYTHON_REPO_DIR

set_if_not_exists "VENVMAN_PYTHON_BUILDS_DIR" "${HOME}/.venvman/builds"
export VENVMAN_PYTHON_BUILDS_DIR
