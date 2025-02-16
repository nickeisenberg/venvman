. "${VENVMAN_ROOT_DIR}/venvman/src/commands/helpers.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/helpers.sh"


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
