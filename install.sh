#!/usr/bin/env bash


try_profile() {
    if [[ -z $1 ]] || [[ ! -f $1 ]]; then
        return 1
    fi
    echo $1
}

detect_profile() {
    local DETECTED_PROFILE
    DETECTED_PROFILE=''

    if [[ "$SHELL" == *"bash"* ]]; then
        if [ -f "$HOME/.bashrc" ]; then
              DETECTED_PROFILE="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
              DETECTED_PROFILE="$HOME/.bash_profile"
        fi

    elif [[ "$SHELL" == *"zsh"* ]]; then
        DETECTED_PROFILE="$HOME/.zshrc"
    fi

    if [[ -z "$DETECTED_PROFILE" ]]; then
        echo "zzzz"
        for EACH_PROFILE in ".profile" ".bashrc" ".bash_profile" ".zshrc"; do
            if DETECTED_PROFILE="$(try_profile "${HOME}/${EACH_PROFILE}")"; then
                break
            fi
        done
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
    local VENVMAN_ROOT_DIR=$1
    local VENVMAN_ENVS_DIR=$2

    if [[ ! -n $VENVMAN_ROOT_DIR ]]; then
        local VENVMAN_ROOT_DIR=$HOME/.venvman
    fi

    if [[ ! -n $VENVMAN_ENVS_DIR ]]; then
        local VENVMAN_ENVS_DIR=${VENVMAN_ROOT_DIR}/envs
    fi

    local VENVMAN_CPYTHON_REPO_DIR=${VENVMAN_ROOT_DIR}/cpython
    local VENVMAN_PYTHON_BUILDS_DIR=${VENVMAN_ROOT_DIR}/builds/

    local VENVMAN_SRC_DIR=${VENVMAN_ROOT_DIR}/venvman/src
    local VENVMAN_UTILS_DIR=${VENVMAN_SRC_DIR}/venvman/utils
    local VENVMAN_COMMANDS_DIR=${VENVMAN_SRC_DIR}/venvman/commands

    local VENVMAN_URL="https://github.com/nickeisenberg/venvman.git"
    local VENVMAN_CPYTHON_REMOTE_URL="https://github.com/python/cpython.git"
    local VENVMAN_CPYTHON_REPO_DIR=${VENVMAN_ROOT_DIR}/cpython
    local VENVMAN_PYTHON_BUILDS_DIR=${VENVMAN_ROOT_DIR}/builds

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

    ### remove
    local VENVMAN_MAIN=${VENVMAN_ROOT_DIR}/venvman/src/main.sh
    local VENVMAN_COMPLETION=${VENVMAN_ROOT_DIR}/venvman/src/completion/completion.sh
    if [[ ! -f $VENVMAN_MAIN || ! -f $VENVMAN_COMPLETION ]]; then
        echo "ERROR: $VENVMAN_MAIN and/or $VENVMAN_COMPLETION cannot be found." >&2
        echo "Removing $VENVMAN_ROOT_DIR." >&2
        echo "Trying installing using the manual steps." >&2
        rm -rf $VENVMAN_ROOT_DIR 
        return 1
    fi
    ###
   
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
        "VENVMAN_ROOT_DIR=${VENVMAN_ROOT_DIR} # where the repo will be cloned to"
        "VENVMAN_ENVS_DIR=${VENVMAN_ENVS_DIR} # virtual enviornments save location"
        "source ${VENVMAN_ROOT_DIR}/venvman/src/completion/completion.sh"
        "venvman() {"
        "   unset -f venvman"
        "   source ${VENVMAN_ROOT_DIR}/venvman/src/main.sh"
        "   venvman $@"
        "}"
    )

    echo "The following will be appended to ${SHELL_PROFILE}"
    echo
    printf "%s\n" "${LINES_TO_APPEND[@]}"

    printf "%s\n" "${LINES_TO_APPEND[@]}" | tee -a $SHELL_PROFILE > /dev/null

    echo "Installation complete." 
    echo "Open a new shell to use venvman"
}


install $@
