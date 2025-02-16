err_missing_option_value() {
    _venvman_err_msg_missing_option_value "$@"
}


venvman_command_help_tag() {
    _venvman_command_help_tag "$@"
}


err_invalid_option() {
    _venvman_err_msg_invalid_option "$@"
}


venvman_activate() {
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [ -n "$2" ]; then
                    _NAME="$2"
                    shift 2
                else
                    err_missing_option_value "activate" "--name"
                    return 1
                fi
                ;;
            -v | --version)
                if [ -n "$2" ]; then
                    _VERSION="$2"
                    shift 2
                else
                    err_missing_option_value "activate" "--version"
                    return 1
                fi
                ;;
            -p | --path)
                if [ -n "$2" ]; then
                    _VENV_PATH="$2"
                    shift 2
                else
                    err_missing_option_value "activate" "--path"
                    return 1
                fi
                ;;
            -h | --help)
                venvman_command_help_tag "activate"\
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
                err_invalid_option "activate" "$1"
                return 1
                ;;
        esac
    done
    
    if { [ -n "$_VENV_PATH" ]  && [ -n "$_VERSION" ] ;} || { [ -n "$_VENV_PATH" ]  && [ -n "$_NAME" ] ;}; then
        echo "ERROR: --path should not be used with --version and --name and vice versa."
        unset _NAME _VERSION _VENV_PATH _PATH_TO_ACTIVATE
        return 1

    elif { [ -n "$_NAME" ]  && [ -z "$_VERSION" ] ;} || { [ -n "$_VERSION" ]  && [ -z "$_NAME" ] ;}; then
        err_missing_option_value "activate" "--name and --version"
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
