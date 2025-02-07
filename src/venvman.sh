function _venvman_err_msg_missing_option_value() {
    local COMMAND=$1
    local INPUT_OPTION_TYPE=$2
    local GIVE_USAGE=$3

    if [[ -z $GIVE_USAGE ]]; then
        local GIVE_USAGE=true
    fi

    echo "ERROR: Enter a value for ${INPUT_OPTION_TYPE}."

    if [[ $GIVE_USAGE == true ]];then 
        echo "See 'venvman ${COMMAND} --help' for usage."
    fi
}


function _venvman_err_msg_invalid_option() {
    local COMMAND=$1
    local INPUTED_OPTION=$2
    echo "ERROR: Invalid option '${2}'"
    echo "See 'venvman ${COMMAND} --help' for usage."
}


function _venvman_make() {
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [[ -n $2 ]]; then
                    local NAME=$2
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "make" "--name"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    local VERSION=$2
                    local PYTHON_EXEC="python$VERSION"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "make" "--version"
                    return 1
                fi
                ;;
            -p | --path)
                if [[ -n $2 ]]; then
                    local VENV_PATH=$2
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "make" "--path"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venvman make [options]"
                echo
                echo "Options:"
                echo "  -n, --name <venv_name>              : Specify the name of the virtual environment to create."
                echo "  -v, --version <python_version>      : Specify the Python version to use for the virtual environment."
                echo "  -p, --path <venv_path>              : Manually specify the directory where the virtual environment should be created."
                echo "  -h, --help                          : Display this help message."
                echo
                echo "Examples:"
                echo "  venvman make -n project_env -v 3.10             : Create a virtual environment named 'project_env' using Python 3.10."
                echo "  venvman make -n myenv -v 3.9 -p /custom/path    : Create 'myenv' using Python 3.9 at '/custom/path'."
                return 0
                ;;
            *)
                _venvman_err_msg_invalid_option "make" "${1}"
                return 1
                ;;
        esac
    done

    if ! command $PYTHON_EXEC --version > /dev/null; then
        return 1
    fi

    if [[ -n $NAME  && -n $VERSION && ! -n $VENV_PATH ]]; then
        local VENV_PATH="$VENVMAN_ENVS_DIR/$VERSION/$NAME"
        if [[ ! -d $VENVMAN_ENVS_DIR/$VERSION ]]; then
            echo "WARNING: The directory ${VENVMAN_ENVS_DIR}/${VERSION} does not exist."
            echo "It must be created to continue."
            echo -n "Do you want to create it now? [y/N]: "
            read -r response

            if [[ $response =~ ^[Yy]$ ]]; then
                if ! mkdir -p $VENV_PATH; then
                    return 1
                fi
            fi
        fi

        $PYTHON_EXEC -m venv $VENV_PATH

    elif [[ -n $NAME  && -n $VERSION && -n $VENV_PATH ]]; then
        local VENV_PATH="$VENV_PATH/$NAME"

        if ! $PYTHON_EXEC -m venv $VENV_PATH; then
            return 1
        fi

        local PATH_TO_ACTIVATE=$(find $VENV_PATH -type f -name "activate")
        if [[ -d $VENV_PATH && -f $PATH_TO_ACTIVATE ]]; then
            echo "SUCCESS: The enviornment has been created at $VENV_PATH."
            return 0
        fi

    else 
        echo "ERROR: Invalid usage. see 'venvman make --help'."
        return 1
    fi
}


function _venvman_activate() {
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [[ -n $2 ]]; then
                    local NAME=$2
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "activate" "--name"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    local VERSION=$2
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "activate" "--version"
                    return 1
                fi
                ;;
            -p | --path)
                if [[ -n $2 ]]; then
                    local VENV_PATH=$2
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "activate" "--path"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venvman activate [options]"
                echo
                echo "Options:"
                echo "  -n, --name <venv_name>                   : Specify the name of the virtual environment to activate."
                echo "  -v, --version <python_version>           : Specify the Python version of the virtual environment."
                echo "  -p, --path <venv_path>                   : Manually specify the path of the virtual environment."
                echo "  -h, --help                               : Display this help message."
                echo
                echo "Examples:"
                echo "  venvman activate -n myenv -v 3.10           : Activate 'myenv' created with Python 3.10"
                echo "  venvman activate -p /custom/path/to/venv    : Activate virtual environment at a custom path."
                return 0
                ;;
            *)
                _venvman_err_msg_invalid_option "activate" "${1}"
                return 1
                ;;
        esac
    done
    
    if [[ -n $VENV_PATH  && -n $VERSION ]] || [[ -n $VENV_PATH  && -n $NAME ]]; then
        echo "ERROR: --path should not be used with --version and --name and vice versa."
        return 1

    elif [[ -n $NAME  && ! -n $VERSION ]] || [[ -n $VERSION  && ! -n $NAME ]]; then
        _venvman_err_msg_missing_option_value "activate" "--name and --version"
        return 1
    fi

    if [[ -n $NAME  && -n $VERSION  ]]; then
        local VENV_PATH="$VENVMAN_ENVS_DIR/$VERSION/$NAME"
    fi
    
    if [[ -d $VENV_PATH ]]; then
        local PATH_TO_ACTIVATE=$(find "${VENV_PATH}" -type f -name "activate")
    else
        echo "ERROR: ${VENV_PATH} does not exist."
        return 1
    fi

    if [[ -z $PATH_TO_ACTIVATE ]]; then
        echo "ERROR: The following command could not find the activate script:"
        echo "    'find "${VENV_PATH}" -type f -name "activate"'"
        return 1
    fi
    
    if ! source $PATH_TO_ACTIVATE; then
        return 1
    fi
}


function _venvman_clone() {
    while [ "$#" -gt 0 ]; do
        case $1 in
            -p | --parent)
                if [[ -n $2 ]]; then
                    local PARENT=$2
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "clone" "--parent"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    local VERSION=$2
                    local PYTHON_EXEC="python$VERSION"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "clone" "--version"
                    return 1
                fi
                ;;
            -to | --clone-to)
                if [[ -n $2 ]]; then
                    local CLONE_TO=$2
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "clone" "--clone-to"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venvman clone [options]"
                echo
                echo "Options:"
                echo "  -p, --parent <venv_name>               : Specify the name of the parent virtual environment that will be cloned."
                echo "  -v, --version <python_version>         : Specify the Python version to use for the virtual environment."
                echo "  -to, --clone-to <venv_path>            : Specify the name of the name of the new enviornment"
                echo "  -h, --help                             : Display this help message."
                echo
                echo "Examples:"
                echo "venvman clone --parent myenv --version 3.10 --clone-to myenv_test   : Will clone myenv to myenv_test"
                return 0
                ;;
            *)
                _venvman_err_msg_invalid_option "clone" "${1}"
                return 1
                ;;
        esac
    done
    
    local OPTIONS=( "--parent" "--version" "--clone-to" )
    local INPUTS=(  $PARENT  $VERSION  $CLONE_TO )
    local MISSING_VALUE=false
    for ((i = 0; i < 3; i++)); do
        local OPTION=${OPTIONS[i]}
        local INPUT=${INPUTS[i]}
        if [[ -z $INPUT ]]; then
            local MISSING_VALUE=true
            _venvman_err_msg_missing_option_value "clone" "${OPTION}" false
        fi
    done
    if [[ "${MISSING_VALUE}" == true ]]; then
        echo "See 'venvman clone --help' for usage."
        return 1
    fi

    if [[ $PARENT == $CLONE_TO ]]; then
        echo "ERROR: The value for --parent must differ from --clone-to."
        return 1
    fi

    if ! command $PYTHON_EXEC --version > /dev/null; then
        return 1
    fi

    _venvman_activate --version $VERSION --name $PARENT
    local PARENT_SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')
    deactivate

    _venvman_make --version $VERSION --name $CLONE_TO
    _venvman_activate --version $VERSION --name $CLONE_TO
    local CLONE_SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')
    deactivate

    if ! cp -r $PARENT_SITE_PACKAGES_DIR/* $CLONE_SITE_PACKAGES_DIR/; then
        return 1
    fi
}


function _venvman_list() {
    local VERSION VERSIONS NUM_VERSIONS VENV_PATH
    local VENV_PATH="$VENVMAN_ENVS_DIR/"
    while [ "$#" -gt 0 ]; do
        case $1 in
            -v | --version)
                if [[ -n $2 ]]; then
                    local VERSION=$2
                    local VENV_PATH="$VENV_PATH/$VERSION"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "list" "--version"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venvman list [options]"
                echo
                echo "Options:"
                echo "  -v, --version <python_version>     : List virtual environments for a specific Python version."
                echo "  -h, --help                         : Display this help message."
                echo
                echo "Examples:"
                echo "  venvman list                            : List all available virtual environments grouped by Python version."
                echo "  venvman list -v 3.10                    : List virtual environments created with Python 3.10."
                return 0
                ;;
            *)
                _venvman_err_msg_invalid_option "list" "${1}"
                return 1
                ;;
        esac
    done

    if [[ -n $VERSION ]]; then
        echo "Available virtual environments for Python $VERSION:"
        if ! ls "$VENV_PATH"; then
            return 1
        fi

    else
        local VERSIONS=($(ls "$VENVMAN_ENVS_DIR"))
        local NUM_VERSIONS=${#VERSIONS[@]}
        for ((i = 0; i < NUM_VERSIONS; i++)); do
            VERSION=${VERSIONS[i]}
            echo "Available virtual environments for Python $VERSION:"
            ls "$VENVMAN_ENVS_DIR/$VERSION"
            if [[ $i -lt $((NUM_VERSIONS - 1)) ]]; then
                echo
            fi
        done
    fi
}


function _venvman_delete() {
    local NAME VERSION VENV_PATH
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [[ -n $2 ]]; then
                    local NAME=$2
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "delete" "--name"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    local VERSION=$2
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "delete" "--version"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venvman delete [options]"
                echo
                echo "Options:"
                echo "  -n, --name <venv_name>            : Specify the name of the virtual environment to delete."
                echo "  -v, --version <python_version>    : Specify the Python version associated with the virtual environment."
                echo "  -h, --help                        : Display this help message."
                echo
                echo "Examples:"
                echo "  venvman delete -n myenv -v 3.10      : Delete the virtual environment 'myenv' created with Python 3.10."
                return 0
                ;;
            *)
                _venvman_err_msg_invalid_option "delete" "${1}"
                return 1
                ;;
        esac
    done
    
    local VENV_PATH="$VENVMAN_ENVS_DIR/$VERSION/$NAME"

    echo -n "Are you sure you want to delete virtual environment $VENV_PATH? [y/N]: " 
    read -r response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        rm -rf "$VENV_PATH"
        if [[ ! -d $VENV_PATH ]]; then
            echo "SUCCESS: Virtual environment $VENV_PATH has been deleted."
            return 0
        else
            echo "ERROR: $VENV_PATH has not been deleted."
            return 1
        fi
    else
        echo "Deletion cancelled."
        return 0
    fi
}


function _venvman_site_packages() {
    while [ "$#" -gt 0 ]; do
        case $1 in
            -pkg | --package)
                if [[ -n $2 ]]; then
                    local PKG=$2
                    shift 2
                else
                    echo "Enter a package for --package"
                    _venvman_err_msg_missing_option_value "site-packages" "--package"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venvman site-package [options]"
                echo
                echo "Options:"
                echo "  -pkg, --package <package_name>   : Navigate to the directory of a specific installed package."
                echo "  -h, --help                       : Display this help message."
                echo
                echo "Examples:"
                echo "venvman site-package                  : Navigate to the site-packages directory of the active virtual environment."
                echo "venvman site-package -pkg numpy     : Navigate to the directory of the installed 'numpy' package."
                return 0
                ;;
            *)
                _venvman_err_msg_invalid_option "site-packages" "${1}"
                return 1
                ;;
        esac
    done

    local SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')
    
    if [[ ! -n $PKG ]]; then
        cd "$SITE_PACKAGES_DIR"
        return 0
    else
        if ! cd "$SITE_PACKAGES_DIR/$PKG"; then
            return 1
        fi
    fi
}


function venvman() {
    if [[ -z $VENVMAN_ROOT_DIR ]] || [[ -z $VENVMAN_ENVS_DIR ]]; then 
        echo "ERROR: VENVMAN_ROOT_DIR and VENVMAN_ENVS_DIR must be set."
        echo "The following is suggested to solve this problem."
        echo

        echo "1) Run the following in you shell:"
        echo
        local MSG_LINES=(
            "VENVMAN_ROOT_DIR=\$HOME/.venvman"
            "mkdir -p \$VENVMAN_ROOT_DIR"
            "git clone https://github.com/nickeisenberg/venvman.git "\${VENVMAN_ROOT_DIR}/venvman""
        )
        printf "%s\n" "${MSG_LINES[@]}"

        echo
        echo "2) Add the following in your shell's config:"
        echo
        local MSG_LINES=(
            "VENVMAN_ROOT_DIR=\$HOME/.venvman"
            "VENVMAN_ENVS_DIR=\$HOME/.venvman/envs"
            "source \$VENVMAN_ROOT_DIR/venvman/src/venvman.sh"
            "source \$VENVMAN_ROOT_DIR/venvman/src/completion/completion.sh"
        )
        printf "%s\n" "${MSG_LINES[@]}"

        echo
        echo "3) source your shell's config."

        return 1
    fi

    if [[ $# -lt 1 ]]; then
        echo "Usage: venvman <command> <python_version> [argument]"
        echo "Use 'venvman --help' for a list of available commands."
        return 1
    fi
        
    # 0 based indexing to match with bash
    if [[ -n $ZSH_VERSION ]]; then
        setopt local_options KSH_ARRAYS
    fi
    
    local COMMAND=$1
    shift 1
    
    case $COMMAND in
        m | make)
            _venvman_make $@
            ;;

        a | activate)
            _venvman_activate $@
            ;;

        c | clone)
            _venvman_clone $@
            ;;

        list)
            _venvman_list $@
            ;;

        d | delete)
            _venvman_delete $@
            ;;

        sp | site-packages)
            _venvman_site_packages $@
            ;;

        -h| --help)
            echo "Commands:"
            echo "  m , make             : Create a new virtual environment. Will create to PATH is specified."
            echo "  d , delete           : Delete the specified virtual environment."
            echo "  a , activate         : Activate the specified virtual environment."
            echo "  list                 : List all available virtual environments."
            echo "  sp , site-packages   : Navigate to the site-packages directory."
            echo "  -h , --help          : Display this help message."
            echo
            echo "Usage:"
            echo "  See \`venvman <command> --help\` for usage of each command."
            ;;

        *)
            echo "Invalid command. Use 'venvman h' or 'venvman help' for a list of available commands."
            return 1
            ;;
    esac
}
