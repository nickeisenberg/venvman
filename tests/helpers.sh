ensure_env_var_exists() {
    if [[ ! -n $1 ]]; then
        echo "$1 does not exist"
        return 1
    fi
    echo $1
}


setup_venvman_test() {
    VENVMAN_ROOT_DIR=$(ensure_env_var_exists $VENVMAN_ROOT_DIR)
    source $VENVMAN_ROOT_DIR/venvman/src/main.sh
    _VENVMAN_ENVS_DIR=$(ensure_env_var_exists $VENVMAN_ENVS_DIR)
    VENVMAN_ENVS_DIR=$(pwd)/_test_here/envs
    VENVMAN_TEST_LOCATION=$(pwd)/_test_here
}


cleanup_venvman_test() {
    VENVMAN_TEST_LOCATION=$(ensure_env_var_exists $VENVMAN_TEST_LOCATION)
    VENVMAN_ENVS_DIR=$(ensure_env_var_exists $VENVMAN_ENVS_DIR)
    _VENVMAN_ENVS_DIR=$(ensure_env_var_exists $_VENVMAN_ENVS_DIR)
    rm -rf $VENVMAN_TEST_LOCATION
    VENVMAN_ENVS_DIR=$_VENVMAN_ENVS_DIR
    unset _VENVMAN_ENVS_DIR
    unset VENVMAN_TEST_LOCATION
}


venv_is_activated() {
    local TEST_VERSION=$1
    local TEST_NAME=$2
    _VIRTUAL_ENV="${VENVMAN_ENVS_DIR}/${TEST_VERSION}/${TEST_NAME}"
    PATH_1=$(echo "$(echo "$PATH" | tr ':' ' ')" | awk "{print \$ 1}")
    if [[ -n "$VIRTUAL_ENV" ]]; then
        if [[ $VIRTUAL_ENV == $_VIRTUAL_ENV && $PATH_1 == "${_VIRTUAL_ENV}/bin" ]]; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}


venv_is_valid() {
    local TEST_VERSION=$1
    local TEST_NAME=$2
    local TEST_VENV_PATH=$3

    if [[ ! -d $TEST_VENV_PATH ]]; then
        return 1
    fi

    local PATH_TO_ACTIVATE=$(find $TEST_VENV_PATH -type f -name "activate")
    if [[ ! -n $PATH_TO_ACTIVATE ]]; then
        return 1
    fi

    source $PATH_TO_ACTIVATE
    if ! $(venv_is_activated $TEST_VERSION $TEST_NAME); then
        return 1
    fi

    deactivate
    if [[ -n $VIRTUAL_ENV ]]; then
        return 1
    fi
    return 0
}


create_venv_if_not_valid() {
    local TEST_VERSION=$1
    local TEST_NAME=$2
    local TEST_VENV_PATH=$3
    local PYTHON_EXEC="python${TEST_VERSION}"

    if ! $(venv_is_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
        if [[ -d $TEST_VENV_PATH ]];then
            echo "ERROR: ${TEST_VENV_PATH} exists"
            return 1
        fi
        $PYTHON_EXEC -m venv $TEST_VENV_PATH || return 1
        if ! $(venv_is_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
              return 1
        fi
    fi
    return 0
}
