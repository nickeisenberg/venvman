. "${VENVMAN_ROOT_DIR}/venvman/src/commands/helpers.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/helpers.sh"


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


    if ! PYTHON_EXEC=$(_venvman_get_python_bin_path "$VERSION"); then  
        echo
        echo "A binary could not be found for python${VERSION} from the following methods:"
        echo
        echo "  1) A python${VERSION} binary could not be found in ${VENVMAN_PYTHON_VERSIONS_DIR}"
        echo "  2) The command 'which python${VERSION}' showed nothing."
        echo
        echo "Searching ${CPYTHON_URL} at ${VENVMAN_PYTHON_DIR} ..."
    
        if ! _venvman_build_python_version_from_source $VERSION; then
            echo "Python ${VERSION} will not be installed." >&2
            echo "Cannot continue without a python${VERSION} binary." >&2
            echo "Exiting" >&2
            return 1
        fi 
    fi

    if ! $($PYTHON_EXEC --version > /dev/null); then
        echo "$PYTHON_EXEC is corrupted." >&2
        return 1
    fi

    if [ -n "$NAME" ]  && [ -n "$VERSION" ] && [ -z "$VENV_PATH" ]; then
        VENV_PATH="${VENVMAN_ENVS_DIR}/${VERSION}/${NAME}"

    elif [ -n "$NAME" ]  && [ -n "$VERSION" ] && [ -n "$VENV_PATH" ]; then
        VENV_PATH="${VENV_PATH}/${NAME}"

    else 
        echo
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
        unset _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1

    elif { [ -n "$_NAME" ]  && [ -z "$_VERSION" ] ;} || { [ -n "$_VERSION" ]  && [ -z "$_NAME" ] ;}; then
        _venvman_err_msg_missing_option_value "activate" "--name and --version"
        unset _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1
    fi

    if [ -n "$_NAME" ]  && [ -n "$_VERSION" ]; then
        _VENV_PATH="${VENVMAN_ENVS_DIR}/${_VERSION}/${_NAME}"
    fi
    
    if [ -d "$_VENV_PATH" ]; then
        _PATH_TO_ACTIVATE=$(find "${_VENV_PATH}" -type f -name "activate")
    else
        echo "ERROR: ${_VENV_PATH} does not exist."
        unset _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1
    fi

    if [ -z "$_PATH_TO_ACTIVATE" ]; then
        echo "ERROR: The following command could not find the activate script:"
        echo "    'find "${_VENV_PATH}" -type f -name "activate"'"
        unset _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1
    fi
    
    if ! . "$_PATH_TO_ACTIVATE"; then
        unset _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1
    fi
    unset _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
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
        unset PKG SITE_PACKAGES_DIR
        return 0
    else
        if ! cd "${SITE_PACKAGES_DIR}/${PKG}"; then
            unset PKG SITE_PACKAGES_DIR
            return 1
        fi
    fi
    unset PKG SITE_PACKAGES_DIR
}
