. "${VENVMAN_ROOT_DIR}/venvman/src/commands/helpers.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/helpers.sh"


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
