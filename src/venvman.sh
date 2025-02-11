_venvman_err_msg_missing_option_value() {(
    COMMAND=$1
    INPUT_OPTION_TYPE=$2
    GIVE_USAGE=$3

    if [ -z "$GIVE_USAGE" ]; then
        GIVE_USAGE="true"
    fi

    echo "ERROR: Enter a value for ${INPUT_OPTION_TYPE}." >&2

    if [ "$GIVE_USAGE" = "true" ];then 
        echo "See 'venvman ${COMMAND} --help' for usage." >&2
    fi
)}


_venvman_err_msg_missing_options() {(
    MISSING_VALUE="$1"
    COMMAND="$2"
    shift 2
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --options)
                OPTIONS="$2"
                shift 2
                ;;
            --inputs)
                INPUTS="$2"
                shift 2
                ;;
            *)
                return 1
                ;;
        esac
    done

    NUM_OPTIONS=$(echo "$OPTIONS" | wc -w)
    NUM_INPUTS=$(echo "$INPUTS" | wc -w)

    if [ "$NUM_INPUTS" -gt "$NUM_OPTIONS" ]; then
        return 1
    fi

    MISSING=false
    i=1
    while [ "$i" -le "$NUM_OPTIONS" ]; do
        INPUT=$(echo "$INPUTS" | awk "{print \$$i}")
        OPTION=$(echo "$OPTIONS" | awk "{print \$$i}")
        
        if [ "$INPUT" = "$MISSING_VALUE" ]; then
            MISSING=true
            _venvman_err_msg_missing_option_value "$COMMAND" "$OPTION" false
        fi
        i=$((i + 1))  # Increment i
    done


    if [ "$MISSING" = true ]; then
        echo "See 'venvman $COMMAND --help' for usage." >&2
        return 1
    fi
)}


_venvman_err_msg_invalid_option() {(
    COMMAND=$1
    INPUTED_OPTION=$2
    echo "ERROR: Invalid option '${2}'" >&2
    echo "See 'venvman ${COMMAND} --help' for usage." >&2
)}


_venvman_unset_var_names() {
    for name in "$@"; do
        unset "$name"
    done
}


_venvman_command_help_tag() {
    COMMAND=$1
    shift

    OPTIONS=""
    OPTIONS_LENS=""
    OPTIONS_MAX_LEN=0
    OPTIONS_DESCRIPTIONS=""

    EXAMPLES=""
    EXAMPLES_LENS=""
    EXAMPLES_MAX_LEN=0
    EXAMPLES_DESCRIPTIONS=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --options)
                shift
                while [ "$#" -gt 0 ] && [ "${1}" != "--option-descriptions" ]; do
                    OPTIONS="${OPTIONS}\n  $1"
                    len=$(echo "$1" | wc -c)
                    OPTIONS_LENS="${OPTIONS_LENS} $len"
                    if [ $len -ge $OPTIONS_MAX_LEN ]; then
                        OPTIONS_MAX_LEN="$len"
                    fi
                    shift
                done
                ;;
            --option-descriptions)
                shift
                i=1
                while [ "$#" -gt 0 ] && [ "${1}" != "--examples" ]; do
                    len=$(echo "$OPTIONS_LENS" | awk -v i="$i" '{print $i}')
                    delta=$(( $OPTIONS_MAX_LEN - $len ))
                    spaces=$(printf '%*s' "$delta" '')
                    OPTIONS_DESCRIPTIONS="${OPTIONS_DESCRIPTIONS}\n$spaces : $1"
                    i=$((i + 1))
                    shift
                done
                ;;
            --examples)
                shift
                while [ "$#" -gt 0 ] && [ "${1}" != "--example-descriptions" ]; do
                    EXAMPLES="${EXAMPLES}\n  $1"
                    len=$(echo "$1" | wc -c)
                    EXAMPLES_LENS="${EXAMPLES_LENS} $len"
                    if [ "$len" -ge $EXAMPLES_MAX_LEN ]; then
                        EXAMPLES_MAX_LEN="$len"
                    fi
                    shift
                done
                ;;
            --example-descriptions)
                shift
                i=1
                while [ "$#" -gt 0 ] && [ "${1#--}" = "$1" ]; do
                    len=$(echo "$EXAMPLES_LENS" | awk -v i="$i" '{print $i}')
                    delta=$(( $EXAMPLES_MAX_LEN - $len ))
                    spaces=$(printf '%*s' "$delta" '')
                    EXAMPLES_DESCRIPTIONS="${EXAMPLES_DESCRIPTIONS}\n$spaces : $1"
                    i=$((i + 1))
                    shift
                done
                ;;
            *)
                return 1
                ;;
        esac
    done

    # Print the help message
    echo "Usage:"
    echo "  venvman $COMMAND [options]"
    echo
    echo "Options:"
    paste -d ' ' <(echo -e "$OPTIONS") <(echo -e "$OPTIONS_DESCRIPTIONS")
    echo
    echo "Examples:"
    paste -d ' ' <(echo -e "$EXAMPLES") <(echo -e "$EXAMPLES_DESCRIPTIONS")
}


_venvman_make() {(
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [ -n "$2" ]; then
                    NAME="$2"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "make" "--name"
                    return 1
                fi
                ;;
            -v | --version)
                if [ -n "$2" ]; then
                    VERSION="$2"
                    PYTHON_EXEC="python$VERSION"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "make" "--version"
                    return 1
                fi
                ;;
            -p | --path)
                if [ -n "$2" ]; then
                    VENV_PATH="$2"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "make" "--path"
                    return 1
                fi
                ;;
            -h | --help)
                _venvman_command_help_tag "make" \
                    --options \
                        "-n, --name <venv_name>" \
                        "-v, --version <python_version>" \
                        "-p, --path <venv_path>" \
                        "-h, --help" \
                    --option-descriptions \
                        "Specify the name of the virtual environment." \
                        "Specify the Python version to use." \
                        "Manually specify the directory." \
                        "Display this help message." \
                    --examples \
                        "venvman make -n project_env -v 3.10" \
                        "venvman make -n myenv -v 3.9 -p /custom/path" \
                    --example-descriptions \
                        "Create 'project_env' with Python 3.10." \
                        "Create 'myenv' with Python 3.9 at '/custom/path'."
                shift
                return 0
                ;;

            *)
                _venvman_err_msg_invalid_option "make" "$1"
                return 1
                ;;
        esac
    done

    "$PYTHON_EXEC" --version > /dev/null || return 1

    if [ -n "$NAME" ]  && [ -n "$VERSION" ] && [ -z "$VENV_PATH" ]; then
        VENV_PATH="${VENVMAN_ENVS_DIR}/${VERSION}/${NAME}"

        if [ ! -d "${VENVMAN_ENVS_DIR}/${VERSION}" ]; then
            echo "WARNING: The directory ${VENVMAN_ENVS_DIR}/${VERSION} does not exist."
            echo "It must be created to continue."
            printf "Do you want to create it now? [y/N]: "
            read -r response

            case "$response" in
                Y|y)
                    mkdir -p "$VENV_PATH" || return 1
                    ;;
                *)
                    echo "$VENV_PATH was not created."
                    return 1
                    ;;
            esac

        fi

    elif [ -n "$NAME" ]  && [ -n "$VERSION" ] && [ -n "$VENV_PATH" ]; then
        VENV_PATH="${VENV_PATH}/${NAME}"

    else 
        echo "ERROR: Invalid usage. see 'venvman make --help'." >&2
        return 1
    fi

    "$PYTHON_EXEC" -m venv $VENV_PATH || return 1

    PATH_TO_ACTIVATE=$(find "$VENV_PATH" -type f -name "activate")
    if [ -d "$VENV_PATH" ] && [ -f "$PATH_TO_ACTIVATE" ]; then
        echo "SUCCESS: The enviornment has been created at $VENV_PATH."
        return 0
    fi
)}


_venvman_activate() {
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [ -n "$2" ]; then
                    _NAME="$2"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "activate" "--name"
                    return 1
                fi
                ;;
            -v | --version)
                if [ -n "$2" ]; then
                    _VERSION="$2"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "activate" "--version"
                    return 1
                fi
                ;;
            -p | --path)
                if [ -n "$2" ]; then
                    _VENV_PATH="$2"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "activate" "--path"
                    return 1
                fi
                ;;
            -h | --help)
                _venvman_command_help_tag "activate"\
                    --options \
                        "-n, --name <venv_name>" \
                        "-v, --version <python_version>" \
                        "-p, --path <venv_path>" \
                        "-h, --help" \
                    --option-descriptions \
                        "Specify the name of the virtual environment to activate." \
                        "Specify the Python version of the virtual environment." \
                        "Manually specify the path of the virtual environment." \
                        "Display this help message." \
                    --examples \
                        "venvman activate -n myenv -v 3.10" \
                        "venvman activate -p /custom/path/to/venv" \
                    --example-descriptions \
                        "Activate 'myenv' created with Python 3.10" \
                        "Activate virtual environment at a custom path."
                return 0
                ;;
            *)
                _venvman_err_msg_invalid_option "activate" "$1"
                return 1
                ;;
        esac
    done
    
    if { [ -n "$_VENV_PATH" ]  && [ -n "$_VERSION" ] ;} || { [ -n "$_VENV_PATH" ]  && [ -n "$_NAME" ] ;}; then
        echo "ERROR: --path should not be used with --version and --name and vice versa."
        _venvman_unset_var_names _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1

    elif { [ -n "$_NAME" ]  && [ -z "$_VERSION" ] ;} || { [ -n "$_VERSION" ]  && [ -z "$_NAME" ] ;}; then
        _venvman_err_msg_missing_option_value "activate" "--name and --version"
        _venvman_unset_var_names _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1
    fi

    if [ -n "$_NAME" ]  && [ -n "$_VERSION" ]; then
        _VENV_PATH="${VENVMAN_ENVS_DIR}/${_VERSION}/${_NAME}"
    fi
    
    if [ -d "$_VENV_PATH" ]; then
        _PATH_TO_ACTIVATE=$(find "${_VENV_PATH}" -type f -name "activate")
    else
        echo "ERROR: ${_VENV_PATH} does not exist."
        _venvman_unset_var_names _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1
    fi

    if [ -z "$_PATH_TO_ACTIVATE" ]; then
        echo "ERROR: The following command could not find the activate script:"
        echo "    'find "${_VENV_PATH}" -type f -name "activate"'"
        _venvman_unset_var_names _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1
    fi
    
    if ! . "$_PATH_TO_ACTIVATE"; then
        _venvman_unset_var_names _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1
    fi
    _venvman_unset_var_names _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
}


_venvman_clone() {(
    while [ "$#" -gt 0 ]; do
        case $1 in
            -p | --parent)
                if [ -n "$2" ]; then
                    PARENT="$2"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "clone" "--parent"
                    return 1
                fi
                ;;
            -v | --version)
                if [ -n "$2" ]; then
                    VERSION="$2"
                    PYTHON_EXEC="python${VERSION}"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "clone" "--version"
                    return 1
                fi
                ;;
            -to | --clone-to)
                if [ -n "$2" ]; then
                    CLONE_TO="$2"
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
                _venvman_err_msg_invalid_option "clone" "$1"
                return 1
                ;;
        esac
    done

    _venvman_err_msg_missing_options "/__MISSING__/" "clone" \
        --options "--parent --version --clone-to" \
        --inputs "${PARENT:-/__MISSING__/} ${VERSION:-/__MISSING__/} ${CLONE_TO:-/__MISSING__/}" || return 1


    if [ "$PARENT" = "$CLONE_TO" ]; then
        echo "ERROR: The value for --parent must differ from --clone-to."
        return 1
    fi

    "$PYTHON_EXEC" --version > /dev/null || return 1

    _venvman_activate --version "$VERSION" --name "$PARENT" > /dev/null || return 1

    PARENT_SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')

    deactivate > /dev/null || return 1
   
    _venvman_make --version "$VERSION" --name "$CLONE_TO" || rm -rf "${CLONE_SITE_PACKAGES_DIR}" return 1
    
    _venvman_activate --version "$VERSION" --name "$CLONE_TO" || rm -rf "${CLONE_SITE_PACKAGES_DIR}" return 1

    CLONE_SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')

    deactivate > /dev/null || return 1

    cp -r "${PARENT_SITE_PACKAGES_DIR}/"* "${CLONE_SITE_PACKAGES_DIR}/" || rm -rf "${CLONE_SITE_PACKAGES_DIR}" return 1
)}


_venvman_list() {(
    while [ "$#" -gt 0 ]; do
        case $1 in
            -v | --version)
                if [ -n "$2" ]; then
                    VERSION="$2"
                    VENV_PATH="${VENVMAN_ENVS_DIR}/${VERSION}"
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
                echo "  venvman list                       : List all available virtual environments grouped by Python version."
                echo "  venvman list -v 3.10               : List virtual environments created with Python 3.10."
                return 0
                ;;
            *)
                _venvman_err_msg_invalid_option "list" "$1"
                return 1
                ;;
        esac
    done

    if [ -n "$VERSION" ]; then
        echo
        echo "Available virtual environments for Python ${VERSION}:"
        ls "$VENV_PATH" || return 1
        echo

    else
        echo
        for VERSION in $(find "$VENVMAN_ENVS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort -t. -k1,1n -k2,2n); do
            echo "Available virtual environments for Python $VERSION:"
            ls "${VENVMAN_ENVS_DIR}/${VERSION}" || return 1
            echo
        done
    fi
)}


_venvman_delete() {(
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [ -n "$2" ]; then
                    NAME="$2"
                    shift 2
                else
                    _venvman_err_msg_missing_option_value "delete" "--name"
                    return 1
                fi
                ;;
            -v | --version)
                if [ -n "$2" ]; then
                    VERSION="$2"
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
                echo "  venvman delete -n myenv -v 3.10   : Delete the virtual environment 'myenv' created with Python 3.10."
                return 0
                ;;
            *)
                _venvman_err_msg_invalid_option "delete" "$1"
                return 1
                ;;
        esac
    done
    
    VENV_PATH="${VENVMAN_ENVS_DIR}/${VERSION}/${NAME}"

    printf "The following enviornment is going to be deleted\n" 
    printf "${VENV_PATH}?\n" 
    printf "Do you want to continue [y/N]?: " 
    read -r response

    case "$response" in
        Y|y)
            rm -rf "$VENV_PATH"
            if [ ! -d "$VENV_PATH" ]; then
                echo "SUCCESS: Virtual environment $VENV_PATH has been deleted."
                return 0
            else
                echo "ERROR: $VENV_PATH has not been deleted."
                return 1
            fi
            ;;
        *)
            echo "Deletion cancelled."
            return 0
            ;;
    esac
)}


_venvman_site_packages() {
    while [ "$#" -gt 0 ]; do
        case $1 in
            -pkg | --package)
                if [ -n "$2" ]; then
                    PKG="$2"
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


    SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')
    
    if [ -z "$PKG" ]; then
        cd "$SITE_PACKAGES_DIR"
        _venvman_unset_var_names PKG SITE_PACKAGES_DIR
        return 0
    else
        if ! cd "${SITE_PACKAGES_DIR}/${PKG}"; then
            _venvman_unset_var_names PKG SITE_PACKAGES_DIR
            return 1
        fi
    fi
    _venvman_unset_var_names PKG SITE_PACKAGES_DIR
}


venvman() {
    if [ -z "$VENVMAN_ROOT_DIR" ] || [ -z "$VENVMAN_ENVS_DIR" ]; then 
        echo "ERROR: VENVMAN_ROOT_DIR and VENVMAN_ENVS_DIR must be set."
        echo "The following is suggested to solve this problem."
        echo

        echo "1) Run the following in you shell:"
        echo
        MSG_LINES=(
            "VENVMAN_ROOT_DIR=\$HOME/.venvman"
            "mkdir -p \$VENVMAN_ROOT_DIR"
            "git clone https://github.com/nickeisenberg/venvman.git "\${VENVMAN_ROOT_DIR}/venvman""
        )
        printf "%s\n" "${MSG_LINES[@]}"

        echo
        echo "2) Add the following in your shell's config:"
        echo
        MSG_LINES=(
            "VENVMAN_ROOT_DIR=\$HOME/.venvman"
            "VENVMAN_ENVS_DIR=\$HOME/.venvman/envs"
            "source \$VENVMAN_ROOT_DIR/venvman/src/venvman.sh"
            "source \$VENVMAN_ROOT_DIR/venvman/src/completion/completion.sh"
        )
        printf "%s\n" "${MSG_LINES[@]}"

        echo
        echo "3) source your shell's config."

        _venvman_unset_var_names MSG_LINES COMMAND
        return 1
    fi

    if [ "$#" -lt 1 ]; then
        echo "Usage: venvman <command> <python_version> [argument]"
        echo "Use 'venvman --help' for a list of available commands."
        _venvman_unset_var_names MSG_LINES COMMAND
        return 1
    fi
        
    # 0 based indexing to match with bash
    if [ -n "$ZSH_VERSION" ]; then
        setopt local_options KSH_ARRAYS
    fi
    
    COMMAND=$1
    shift 1
    
    case $COMMAND in
        m | make)
            _venvman_make "$@"
            ;;

        a | activate)
            _venvman_activate "$@"
            ;;

        c | clone)
            _venvman_clone "$@"
            ;;

        list)
            _venvman_list "$@"
            ;;

        d | delete)
            _venvman_delete "$@"
            ;;

        sp | site-packages)
            _venvman_site_packages "$@"
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
    _venvman_unset_var_names MSG_LINES COMMAND
}
