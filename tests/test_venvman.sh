#!/usr/bin/env bash

test_install_venvman() {
    local VENVMAN_ROOT_DIR=$1
    local VENVMAN_ENVS_DIR=$2

    local LOCAL_PS1="$(whoami)@$(hostname)"
    
    if [[ $LOCAL_PS1 == "nicholas@lenovo" ]]; then
        echo "Running install.sh from nicholas@lenovo"
        bash $HOME/.venvman/venvman/install.sh $VENVMAN_ROOT_DIR $VENVMAN_ENVS_DIR
        source $VENVMAN_ROOT_DIR/venvman/src/venvman.sh
        source $VENVMAN_ROOT_DIR/venvman/src/completion/completion.sh
    else
        echo "Curling install.sh"
        curl -sSL https://raw.githubusercontent.com/nickeisenberg/venvman/master/install.sh -o install.sh 
        echo "Installing install.sh"
        bash install.sh $VENVMAN_ROOT_DIR $VENVMAN_ENVS_DIR
        source $VENVMAN_ROOT_DIR/venvman/src/venvman.sh
        source $VENVMAN_ROOT_DIR/venvman/src/completion/venvman.sh
    fi

    if ! venvman --help &> /dev/null; then
        echo "venvman was not sourced"
        return 1
    fi

    cd $VENVMAN_ROOT_DIR
    if [[ ! $(pwd) == *"${VENVMAN_ROOT_DIR}"*  ]]; then
        echo "pwd: $(pwd)"
        echo "should be in $VENVMAN_ROOT_DIR"
        return 1
    fi
}


set_env_variables_source_venvman() {
    local VENVMAN_ROOT_DIR=$1
    local VENVMAN_ENVS_DIR=$2
    if [[ ! -n $VENVMAN_ROOT_DIR && ! -n $VENVMAN_ENVS_DIR ]]; then
        echo "VENVMAN_ROOT_DIR VENVMAN_ENVS_DIR were not set"
        return 1
    fi
}

create_env_with_venvman() {
    local VERSION=$1
    local NAME=$2
    echo "Creating virtual environment..."
    yes | venvman make -n $NAME -v $VERSION
    if [[ ! -d $VENVMAN_ENVS_DIR/$VERSION/$NAME ]]; then
        echo "venvman make: Fail"
        return 1
    fi
}

activate_env_with_venvman_create_req_txt(){
    local VERSION=$1
    local NAME=$2
    local PACKAGES=$3

    echo "🚀 Activating virtual environment..."
    venvman activate -v $VERSION -n $NAME

    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "venvman make: SUCCESS"
        echo "venvman activate: SUCCESS"
    else
        echo "venvman make: Fail"
        echo "venvman activate: FAILED"
        return 1
    fi

    local PACKAGES="numpy"
    pip install numpy
    pip freeze > ${NAME}_req.txt
}

deactivate_enviornment() {
    deactivate
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "deactivate fail"
        return 1
    fi
}

clone_venv_with_venvman() {
    local VERSION=$1
    local PARENT=$2
    local CLONE_TO=$3

    echo "Cloning the repo"
    venvman clone --version $VERSION --parent $PARENT --clone-to $CLONE_TO
    
    if [[ ! -d $VENVMAN_ENVS_DIR/$VERSION/${CLONE_TO} ]]; then
        echo "venvman clone: Fail"
        return 1
    fi
}

check_freeze_req_files() {
    if diff -q $1 $2 > /dev/null; then
        echo "Cloned enviornments are identical"
        rm $1
        rm $2
        if [[ -f $1 && -f $2 ]]; then
            echo "req file not successfully deleted"
        fi
    else
        echo "Cloned enviornments are not identical"
        return 1
    fi
}

list_envs_with_venvman() {
    local VERSION=$1
    local VENV=$2
    local VENV_CLONE=$3
    local OUTPUT=$(venvman list --version $VERSION)
    local EXPECTED_LINES=(
        "Available virtual environments for Python 3.11:"
        "$VENV"
        "$VENV_CLONE"
    )
    local EXPECTED=$(printf "%s\n" "${EXPECTED_LINES[@]}")

    echo "Testing venvman list"
    if [[ $OUTPUT != $EXPECTED ]]; then
        echo "ERROR: venvman list is not working"
        echo "output: $OUTPUT"
        echo "expected: $EXPECTED"
        return 1
    fi
}

delete_venv_with_venvman() {
    local VERSION=$1
    local NAME=$2

    yes | venvman delete -n $NAME -v $VERSION
    if [[ -d $VENVMAN_ENVS_DIR/$VERSION/$NAME ]]; then
        echo "venvman delete: Fail"
        return 1
    fi
    echo "venvman delete: SUCCESS deleteing $NAME"
}

navigate_to_site_packages_with_venvman() {
    local VENV=$1
    local PACKAGE=$2
    local MY_PWD=$(pwd)
    echo "Testing venvman site-packages"
    venvman site-packages
    if [[ ! $(pwd) == *"$VENV"* ]]; then
        echo "venvman site-packages does not work"
        echo $(pwd)
        return 1
    fi
    cd $MY_PWD
    venvman site-packages --package $PACKAGE
    if [[ ! $(pwd) == *"$PACKAGE"* && ! $(pwd) == *"$VENV"* ]]; then
        echo "venvman site-packages does not work"
        echo $(pwd)
        return 1
    fi
    cd $MY_PWD
}

test() {
    set -e
    local TESTING_DIR="$(pwd)/_test_here"
    local VENVMAN_ROOT_DIR=$TESTING_DIR
    local VENVMAN_ENVS_DIR=${TESTING_DIR}/envs
    local VENV="test_env"
    local VENV_CLONE="test_env_clone"
    local VERSION=3.11
    local PACKAGES="numpy"
    local PACKAGE_TO_CHECK="numpy"

    # Ensure cleanup happens if any command fails
    trap 'rm -rf "$TESTING_DIR"; echo "Test failed. Cleaned up $TESTING_DIR"; return 1' ERR

    test_install_venvman "$VENVMAN_ROOT_DIR" "$VENVMAN_ENVS_DIR"
    set_env_variables_source_venvman "$VENVMAN_ROOT_DIR" "$VENVMAN_ENVS_DIR"
    create_env_with_venvman "$VERSION" "$VENV"
    activate_env_with_venvman_create_req_txt "$VERSION" "$VENV" $PACKAGES
    navigate_to_site_packages_with_venvman $VENV $PACKAGE_TO_CHECK
    deactivate_enviornment
    clone_venv_with_venvman "$VERSION" "$VENV" "$VENV_CLONE"
    activate_env_with_venvman_create_req_txt "$VERSION" "$VENV_CLONE" $PACKAGES
    navigate_to_site_packages_with_venvman $VENV_CLONE $PACKAGE_TO_CHECK
    deactivate_enviornment
    check_freeze_req_files "${VENV}_req.txt" "${VENV_CLONE}_req.txt"
    list_envs_with_venvman $VERSION $VENV $VENV_CLONE
    delete_venv_with_venvman "$VERSION" "$VENV" 
    delete_venv_with_venvman "$VERSION" "$VENV_CLONE"

    # Disable trap on success
    trap - ERR
    echo "All tests passed!"
    rm -rf $TESTING_DIR
}

test
