#!/usr/bin/env bash


detect_profile() {
    local DETECTED_PROFILE
    DETECTED_PROFILE=''

    if [[ "$SHELL" == *"bash"* ]]; then
        if [ -f "$HOME/.bash_profile" ]; then
              DETECTED_PROFILE="$HOME/.bash_profile"
        elif [ -f "$HOME/.bashrc" ]; then
              DETECTED_PROFILE="$HOME/.bashrc"
        fi

    elif [[ "$SHELL" == *"zsh"* ]]; then
        DETECTED_PROFILE="$HOME/.zshrc"
    fi

    if [[ -n "$DETECTED_PROFILE" ]]; then
        echo "$DETECTED_PROFILE"

    else
        echo "ERROR: A profile (eg, bashrc, zshrc) was not found. Stopping install." >&2
        echo "Continue with the manual installation steps found in the README" >&2
        return 1
    fi
}

make_dir_if_not_exitst() {
    if [[ -z $1 ]] || [[ -d $1 ]]; then
        echo "$1 already exists. This may be a mistake." >&2 
        echo "Stopping install to not overwrite anything." >&2
        return 1
    fi

    mkdir -p $1 || return 1

    if [[ -d $1 ]]; then
        echo "$1 was successfully created" 
        return 0

    else
        echo "$1 was not created. Stopping install." >&2
        return 1
    fi
}

install() {
    case "$1" in
        --prefix)
            VENVMAN_ROOT_DIR=$2
            shift 2
            ;;
        *)
            command ...
            ;;
    esac

    if [[ ! -n $VENVMAN_ROOT_DIR ]]; then
        local VENVMAN_ROOT_DIR="${HOME}/.venvman"
    fi

    local VENVMAN_ENVS_DIR=${VENVMAN_ROOT_DIR}/envs
    local VENVMAN_PYTHON_BUILDS_DIR=${VENVMAN_ROOT_DIR}/builds/
    local VENVMAN_CPYTHON_REPO_DIR=${VENVMAN_ROOT_DIR}/cpython
    local VENVMAN_CPYTHON_REMOTE_URL="https://github.com/python/cpython.git"
    local VENVMAN_URL="https://github.com/nickeisenberg/venvman.git"

    make_dir_if_not_exitst $VENVMAN_ROOT_DIR || return 1
    make_dir_if_not_exitst $VENVMAN_ENVS_DIR || return 1

    echo
    echo "--------------------"
    echo "Cloning ${VENVMAN_URL} to ${VENVMAN_ROOT_DIR}/venvman"
    echo "--------------------"
    echo

    if ! git clone "${VENVMAN_URL}" "${VENVMAN_ROOT_DIR}/venvman"; then
        return 1
    fi
   
    echo
    echo "--------------------"
    echo "Cloning ${CPYTHON_URL} to ${VENVMAN_CPYTHON_REPO_DIR}"
    echo "--------------------"
    echo

    mkdir -p ${VENVMAN_CPYTHON_REPO_DIR} || return 1
    git clone ${VENVMAN_CPYTHON_REMOTE_URL} ${VENVMAN_CPYTHON_REPO_DIR} || return 1

    mkdir -p ${VENVMAN_PYTHON_BUILDS_DIR} || return 1

    SHELL_PROFILE=$(detect_profile) || return 1
    
    LINES_TO_APPEND=(
        "source ${VENVMAN_ROOT_DIR}/venvman/src/main.sh"
    )

    echo "The following will be appended to ${SHELL_PROFILE}"
    echo
    printf "%s\n" "${LINES_TO_APPEND[@]}"

    printf "%s\n" "${LINES_TO_APPEND[@]}" | tee -a $SHELL_PROFILE > /dev/null

    echo "Installation complete." 
    echo "Open a new shell to use venvman"
}

install $@
