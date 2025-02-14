#--------------------------------------------------
# Helpers
#--------------------------------------------------
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
    if [[ -n "$VIRTUAL_ENV" ]]; then

        if [[ $(python --version) != *"$TEST_VERSION"* ]]; then
            return 1
        fi

        if [[ $VIRTUAL_ENV == *"${TEST_NAME}"* ]]; then
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
        $PYTHON_EXEC -m venv $TEST_VENV_PATH
        if ! $(venv_is_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
              return 1
        fi
    fi
    return 0
}
#--------------------------------------------------


#--------------------------------------------------
# Tests 
#--------------------------------------------------
test_install_venvman() {
    echo
    echo "----------------------------"
    echo "Testing venvman install"
    echo "----------------------------"

    local LOCAL_PS1="$(whoami)@$(hostname)"
    local USE_INSTALL_SH=false

    local TEST_VENVMAN_ROOT_DIR="$(pwd)/_test_here"
    local TEST_VENVMAN_ENVS_DIR=$(pwd)/_test_here/envs


    if [[ $LOCAL_PS1 == "nicholas@lenovo" ]]; then
        if [[ -z $VENVMAN_ROOT_DIR ]]; then
            VENVMAN_ROOT_DIR=$HOME/.venvman
        fi
        if [[ -z $VENVMAN_ENVS_DIR ]]; then
            VENVMAN_ENVS_DIR=$HOME/.venvman/envs
        fi

        if $USE_INSTALL_SH; then
            echo "Running install.sh from nicholas@lenovo"
            bash $HOME/.venvman/venvman/install.sh $TEST_VENVMAN_ROOT_DIR $TEST_VENVMAN_ENVS_DIR
            source $TEST_VENVMAN_ROOT_DIR/venvman/src/venvman.sh
            source $TEST_VENVMAN_ROOT_DIR/venvman/src/completion/completion.sh

        elif ! $USE_INSTALL_SH; then
            if [[ -d $TEST_VENVMAN_ROOT_DIR ]]; then
                echo "$TEST_VENVMAN_ROOT_DIR exists"
                return 1
            fi
            mkdir -p "${TEST_VENVMAN_ROOT_DIR}/venvman"
            mkdir -p $TEST_VENVMAN_ENVS_DIR
            cp -r "${HOME}/.venvman/venvman/src" "${TEST_VENVMAN_ROOT_DIR}/venvman"

            if ! source $TEST_VENVMAN_ROOT_DIR/venvman/src/venvman.sh; then
                rm -rf $TEST_VENVMAN_ROOT_DIR
                return 1
            fi
            if ! source $TEST_VENVMAN_ROOT_DIR/venvman/src/completion/completion.sh; then
                rm -rf $TEST_VENVMAN_ROOT_DIR
                return 1
            fi
        fi  

        if ! venvman --help &> /dev/null; then
            echo "venvman was not sourced"
            rm -rf $TEST_VENVMAN_ROOT_DIR
            return 1
        fi

        rm -rf $TEST_VENVMAN_ROOT_DIR
        echo
        echo "Install success."

    else
        echo "not running on github workflow"
    fi
}


test_venvman_make() {
    echo
    echo "----------------------------"
    echo "Testing venvman make"
    echo "----------------------------"
    
    setup_venvman_test 
    
    local TEST_VERSION=3.10
    local TEST_NAME="test_env"
    local CLEANUP=true

    echo
    echo "Creating virtual enviornment"
    echo "python version: ${TEST_VERSION}"
    echo "name: ${TEST_NAME}"
    echo

    yes | venvman make -n $TEST_NAME -v $TEST_VERSION

    local TEST_VENV_PATH="${VENVMAN_ENVS_DIR}/${TEST_VERSION}/${TEST_NAME}"
    
    echo
    echo "Validating virtual enviornment"
    if ! $(venv_is_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
        echo "venvman make: FAIL"
        cleanup_venvman_test
        return 1
    fi
    
    if $CLEANUP; then
        rm -rf $TEST_VENV_PATH
        if $(venv_is_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
            echo "venvman make: FAIL. cleanup fail."
            cleanup_venvman_test
            return 1
        fi
    fi

    cleanup_venvman_test

    echo "venvmake make: SUCCESS"
}


test_venvman_activate(){
    echo
    echo "----------------------------"
    echo "Testing venvman activate"
    echo "----------------------------"

    setup_venvman_test 

    local TEST_VERSION=3.10
    local TEST_NAME="test_env"
    VENVMAN_ENVS_DIR=$(ensure_env_var_exists $VENVMAN_ENVS_DIR)
    local TEST_VENV_PATH="${VENVMAN_ENVS_DIR}/${TEST_VERSION}/${TEST_NAME}"

    if ! create_venv_if_not_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH; then
        echo "venvman activate: FAIL. venv does not exist and could not be created."
        echo "Attempted VENV_PATH: $TEST_VENV_PATH"
        cleanup_venvman_test
        return 1
    fi

    echo "Activating virtual environment"
    echo "python version: ${TEST_VERSION}"
    echo "name: ${TEST_NAME}"

    venvman activate -v $TEST_VERSION -n $TEST_NAME

    if ! venv_is_activated $TEST_VERSION $TEST_NAME; then
        echo "venvman activate: FAILED. No venv was activated."
        cleanup_venvman_test
        return 1
    fi

    deactivate
    if [[ -n $VIRTUAL_ENV ]]; then
        echo "venvman activate: FAIL. venv could not be deactivated."
        cleanup_venvman_test
        return 1
    fi
    
    cleanup_venvman_test 

    echo "venvmake activate: SUCCESS"
}


test_venvman_clone() {
    echo 
    echo "----------------------------"
    echo "Testing venvman clone"
    echo "----------------------------"

    setup_venvman_test    

    local TEST_VERSION=3.10
    local TEST_PARENT="test_env"
    local TEST_CLONE_TO="test_env_clone"
    local CLEANUP=true

    local TEST_PARENT_PATH="${VENVMAN_ENVS_DIR}/${TEST_VERSION}/${TEST_PARENT}"
    local TEST_CLONE_TO_PATH="${VENVMAN_ENVS_DIR}/${TEST_VERSION}/${TEST_CLONE_TO}"


    if ! $(create_venv_if_not_valid $TEST_VERSION $TEST_PARENT $TEST_PARENT_PATH); then
        echo "venvman clone: FAIL. TEST_PARENT venv does not exist"
        echo "TEST_PARENT: $TEST_PARENT_PATH"
        cleanup_venvman_test 
        return 1
    fi

    venvman clone --version $TEST_VERSION --parent $TEST_PARENT --clone-to $TEST_CLONE_TO

    if ! $(venv_is_valid $TEST_VERSION $TEST_CLONE_TO $TEST_CLONE_TO_PATH); then
        echo "venvman clone: FAIL. TEST_CLONE_TO venv is not valid"
        echo "TEST_CLONE_TO: $TEST_CLONE_TO_PATH"
        cleanup_venvman_test 
        return 1
    fi

    local TEST_PARENT_SITE_PACKAGE_DIR=$(find $TEST_PARENT_PATH -type d -name "site-packages")
    local CLONE_VENV_SITE_PACKAGE_DIR=$(find $TEST_CLONE_TO_PATH -type d -name "site-packages")

    if [[ ! -d $TEST_PARENT_SITE_PACKAGE_DIR && ! -d $CLONE_VENV_SITE_PACKAGE_DIR ]]; then
        echo "venvman clone: FAIL. Could not find site package dirs."
        cleanup_venvman_test 
        return 1
    fi

    local TEST_PARENT_PACKAGES=$(ls $TEST_PARENT_SITE_PACKAGE_DIR)
    local CLONE_PACKAGES=$(ls $CLONE_VENV_SITE_PACKAGE_DIR)

    local DIFF=$(diff <(echo "$TEST_PARENT_PACKAGES" | sort) <(echo "$CLONE_PACKAGES" | sort))
    if [[ -n $DIFF ]]; then
        echo "venvman clone: FAIL. site-packages differ."
        echo "SITE_PACKAGES: $TEST_PARENT_PACKAGES"
        echo "CLONE_SITE_PACKAGES: $CLONE_PACKAGES"
        cleanup_venvman_test 
        return 1
    fi

    if $CLEANUP; then
        rm -rf $TEST_PARENT_PATH
        rm -rf $TEST_CLONE_TO_PATH
        if $(venv_is_valid $TEST_VERSION $TEST_CLONE_TO $TEST_CLONE_TO_PATH); then
            echo "venvman clone: FAIL. Cleanup fail"
            cleanup_venvman_test 
            return 1
        fi

        if $(venv_is_valid $TEST_VERSION $TEST_PARENT $TEST_PARENT_PATH); then
            echo "venvman clone: FAIL. Cleanup fail"
            cleanup_venvman_test 
            return 1
        fi
    fi
    
    cleanup_venvman_test

    echo "venvmake clone: SUCCESS"
}


test_venvman_list() {
    echo
    echo "----------------------------"
    echo "Testing venvman list"
    echo "----------------------------"

    setup_venvman_test 

    local TEST_VERSION_1=3.10
    local VENVS_PATH_1="${VENVMAN_ENVS_DIR}/${TEST_VERSION_1}"
    local TEST_VERSION_2=3.11
    local VENVS_PATH_2="${VENVMAN_ENVS_DIR}/${TEST_VERSION_2}"

    mkdir -p "$VENVS_PATH_1"
    mkdir -p "$VENVS_PATH_1/env1"

    mkdir -p "$VENVS_PATH_2"
    mkdir -p "$VENVS_PATH_2/env1"
    mkdir -p "$VENVS_PATH_2/env2"

    if [[ ! -d $VENVS_PATH_1 && ! -d $VENVS_PATH_2 ]]; then
        echo "venvman list: FAIL. $VENVS_PATH_1 and/or $VENVS_PATH_2 does not exist."
        cleanup_venvman_test 
        return 1
    fi

    local OUTPUT_ALL=$(venvman list)
    local EXPECTED_ALL_LINES=(
        ""
        "Available virtual environments for Python ${TEST_VERSION_1}:"
        "$(ls $VENVS_PATH_1)"
        ""
        "Available virtual environments for Python ${TEST_VERSION_2}:"
        "$(ls $VENVS_PATH_2)"
    )
    local EXPECTED_ALL=$(printf "%s\n" "${EXPECTED_ALL_LINES[@]}")
    local DIFF_ALL=$(diff <(echo "$EXPECTED_ALL") <(echo "$OUTPUT_ALL"))

    if [[ -n $DIFF_ALL ]]; then
        echo "venvman list: FAIL."
        echo "DIFF_ALL:"
        echo "$DIFF_ALL"
        echo "output all:"
        echo "$OUTPUT_ALL"
        echo "expected all:"
        echo "$EXPECTED_ALL"
        cleanup_venvman_test 
        return 1
    fi

    local OUTPUT_V2=$(venvman list --version $TEST_VERSION_2)
    local EXPECTED_V2_LINES=(
        ""
        "Available virtual environments for Python ${TEST_VERSION_2}:"
        "$(ls $VENVS_PATH_2)"
    )
    local EXPECTED_V2=$(printf "%s\n" "${EXPECTED_V2_LINES[@]}")
    local DIFF_V2=$(diff <(echo "$EXPECTED_V2") <(echo "$OUTPUT_V2"))
    
    if [[ -n $DIFF_V2 ]]; then
        echo "venvman list: FAIL."
        echo "DIFF_V2:"
        echo "$DIFF_V2"
        echo "output v2:"
        echo "$OUTPUT_V2"
        echo "expected v2:"
        echo "$EXPECTED_V2"
        cleanup_venvman_test 
        return 1
    fi

    cleanup_venvman_test
    echo "venvman list: SUCCESS"
}


test_venvman_delete() {
    echo
    echo "----------------------------"
    echo "Testing venvman delete"
    echo "----------------------------"

    setup_venvman_test 

    local TEST_VERSION=3.10
    local TEST_NAME="test_env"
    local TEST_VENV_PATH="${VENVMAN_ENVS_DIR}/${TEST_VERSION}/${TEST_NAME}"

    if ! $(create_venv_if_not_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
        echo "venvman delete FAIL: could not make the venv to delete"
        cleanup_venvman_test 
        return 1
    fi

    if ! $(venv_is_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
        echo "venvman delete: Fail. No venv exists with given name and version."
        cleanup_venvman_test 
        return 1
    fi

    yes | venvman delete -n $TEST_NAME -v $TEST_VERSION

    if $(venv_is_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
        echo "venvman delete: Fail. venv still exists."
        cleanup_venvman_test 
        return 1
    fi

    cleanup_venvman_test

    echo "venvman delete: SUCCESS."
    return 0
}


test_venvman_site_packages() {
    echo
    echo "----------------------------"
    echo "Testing venvman site-packages"
    echo "----------------------------"

    setup_venvman_test 

    local TEST_VERSION="3.10"
    local TEST_NAME="test_env"
    local TEST_PACKAGE="numpy"

    local TEST_VENV_PATH="${VENVMAN_ENVS_DIR}/${TEST_VERSION}/${TEST_NAME}"

    if ! $(create_venv_if_not_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
        echo "venvman delete FAIL: could not make the venv to delete"
        cleanup_venvman_test 
        return 1
    fi

    local SITE_PACKAGE_DIR=$(find $TEST_VENV_PATH -type d -name "site-packages")

    if [[ ! -d $SITE_PACKAGE_DIR ]]; then
        echo "venvman site-packages: FAIL. couldnt find site-packages dir"
        cleanup_venvman_test 
        return 1
    fi

    local MY_PWD=$(pwd)

    if ! $(venv_is_valid $TEST_VERSION $TEST_NAME $TEST_VENV_PATH); then
        echo "venvman site-packages: FAIL. No venv exists with given name and version."
        cleanup_venvman_test 
        return 1
    fi

    local PATH_TO_ACTIVATE=$(find $TEST_VENV_PATH -type f -name "activate")
    if [[ ! -n $PATH_TO_ACTIVATE ]]; then
        echo "Fail. activate script could not be found."
        cleanup_venvman_test 
        return 1
    fi

    source $PATH_TO_ACTIVATE
    if ! $(venv_is_activated $TEST_VERSION $TEST_NAME); then
        echo "Fail. The venv is not activated"
        cleanup_venvman_test 
        return 1
    fi

    venvman site-packages
    if [[ ! $(pwd) == $SITE_PACKAGE_DIR ]]; then
        echo "venvman site-packages does not work"
        echo "PWD: $(pwd)"
        echo "SITE-PACKAGES: ${SITE_PACKAGE_DIR}"
        cleanup_venvman_test 
        return 1
    fi

    cd $MY_PWD

    pip install $TEST_PACKAGE

    venvman site-packages --package $TEST_PACKAGE
    if [[ ! $(pwd) == "${SITE_PACKAGE_DIR}/${TEST_PACKAGE}" ]]; then
        echo "PWD: $(pwd)"
        echo "SITE-PACKAGES: ${SITE_PACKAGE_DIR}/${TEST_PACKAGE}"
        cleanup_venvman_test 
        return 1
    fi
        
    cd $MY_PWD

    cleanup_venvman_test
    echo "venvman site-packages: SUCCESS"
}
#--------------------------------------------------


test() {
    set -e
    
    if [[ -n $ZSH_VERSION ]]; then
        autoload -Uz compinit
        compinit
    fi

    # Ensure cleanup happens if any command fails
    trap '"Test failed"; return 1' ERR

    test_install_venvman
    test_venvman_make
    test_venvman_activate
    test_venvman_site_packages
    test_venvman_clone
    test_venvman_list
    test_venvman_delete

    # Disable trap on success
    trap - ERR

    echo
    echo "----------------------------"
    echo "All tests passed!"
    echo "----------------------------"
}


test
