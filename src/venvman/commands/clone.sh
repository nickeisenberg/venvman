. "${VENVMAN_ROOT_DIR}/venvman/src/commands/helpers.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/helpers.sh"


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
