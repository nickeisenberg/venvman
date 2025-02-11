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
        echo "ERROR: A profile (eg, bashrc, zshrc) was not found. Stopping install."
        return 1
    fi
}

make_dir_if_not_exitst() {
    if [[ -z $1 ]] || [[ -d $1 ]]; then
        echo "$1 already exists. This may be a mistake. Stopping install to not overwrite anything."
        return 1
    fi
    mkdir -p $1 && [[ -d $1 ]] && echo "$1 was successfully created" return 0 || \
        echo "$1 was not created. Stopping install." return 1
}

append_text_to_file() {
    local TEXT=$1
    local FILE=$2
    [[ -z $TEXT || -z $FILE ]] && echo "Invalid usages of. Supply text and file" return 1
    printf "%s\n" "" | tee -a $FILE &> /dev/null
    printf "%s\n" "$TEXT" | tee -a $FILE &> /dev/null
}

install() {
    local VENVMAN_ROOT_DIR=$1
    local VENVMAN_ENVS_DIR=$2

    if [[ ! -n $VENVMAN_ROOT_DIR ]]; then
        VENVMAN_ROOT_DIR=$HOME/.venvman
    fi

    if [[ ! -n $VENVMAN_ENVS_DIR ]]; then
        VENVMAN_ENVS_DIR=${VENVMAN_ROOT_DIR}/envs
    fi

    echo "FROM INSTALL ROOT $VENVMAN_ENVS_DIR"

    make_dir_if_not_exitst $VENVMAN_ROOT_DIR || return 1
    make_dir_if_not_exitst $VENVMAN_ENVS_DIR || return 1

    git clone https://github.com/nickeisenberg/venvman.git "${VENVMAN_ROOT_DIR}/venvman" || \
        echo "ERROR: git clone https://github.com/nickeisenberg/venvman.git did not work." return 1

    local VENVMAN_SRC=${VENVMAN_ROOT_DIR}/venvman/src/venvman.sh
    local VENVMAN_COMPLETION=${VENVMAN_ROOT_DIR}/venvman/src/completion/completion.sh
    if [[ ! -f $VENVMAN_SRC || ! -f $VENVMAN_COMPLETION ]]; then
        echo "ERROR: $VENVMAN_SRC and/or $VENVMAN_COMPLETION cannot be found.
Removing $VENVMAN_ROOT_DIR.
Trying installing using the manual steps." 
        rm -rf $VENVMAN_ROOT_DIR 
        return 1
    fi

    local SHELL_PROFILE=$(detect_profile)

    append_text_to_file \
"VENVMAN_ROOT_DIR=${VENVMAN_ROOT_DIR} # there the repo will be cloned to
VENVMAN_ENVS_DIR=${VENVMAN_ENVS_DIR} # where the virtual enviornments will be saved to
source ${VENVMAN_ROOT_DIR}/venvman/src/completion/completion.sh
venvman() {
    unset -f venvman
    source ${VENVMAN_ROOT_DIR}/venvman/src/main.sh
    venvman $@
}"

    printf "%s\n" "Installation complete. Open a new shell to use venvman
or run \`source $SHELL_PROFILE\` to run in this current shell session"
}

install $@
