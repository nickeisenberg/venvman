function _venv_remove_trailing_dir_sep() {
    local LEN LEN_MINUS_ONE LAST_CHAR
    LEN=${#1}
    LEN_MINUS_ONE=$((LEN - 1))
    LAST_CHAR=${1:LEN_MINUS_ONE:LEN}
    if [[ $LAST_CHAR == "/"  ]]; then
        _venv_remove_trailing_dir_sep ${1:0:LEN_MINUS_ONE}
    else
        echo $1
    fi
}


function _venv_check_system_availablity_of_py_version() {
    local COMMAND VERSION
    if [[ $# -ne 1 ]]; then
        echo "Enter a python version"
        return 1
    fi
    VERSION=$1
    COMMAND=python$1
    if ! command -v $COMMAND &> /dev/null; then
        echo "Python version not available on system"
        return 1
    fi
}


function _venv_get_py_versions_in_venv_dir() {
    if [[ -d $HOME/.venv ]]; then
        x=$(ls $HOME/.venv)
        for VAR in $x 
        do
            echo "$VAR"
        done
    else
        echo "$HOME/.venv does not exist. Create it."
        return 1
    fi
}


function _venv_check_py_version_in_venv_dir() {
    local FOUND="false"
    for VAR in $(_venv_get_py_versions_in_venv_dir); do
        if [[ $VAR == "$1" ]]; then
            FOUND="true"
        fi
    done
    if [[ $FOUND == "false" ]]; then
        echo "python version not found in $HOME/.venv"
        return 1
    fi
}


_venv_completion() {
    local VENV_VERSIONS=$(ls ~/.venv)
    local WORDS=("${COMP_WORDS[@]}")
    local COMMANDS="make activate site-packages list delete help"


    if [[ ${#WORDS[@]} -eq 2 ]]; then
        # Complete commands after `venv`
        COMPREPLY=($(compgen -W "$COMMANDS" -- "${COMP_WORDS[COMP_CWORD]}"))
    elif [[ ${#WORDS[@]} -eq 3 && "${COMP_WORDS[COMP_CWORD-1]}" =~ ^(m|make|a|activate|sp|list|d|delete)$ ]]; then
        # Complete Python versions after `venv <command>`
        COMPREPLY=($(compgen -W "$VENV_VERSIONS" -- "${COMP_WORDS[COMP_CWORD]}"))
    elif [[ ${#WORDS[@]} -eq 4 && "${COMP_WORDS[COMP_CWORD-2]}" =~ ^(a|activate|d|delete)$ ]]; then
        # Suggest virtual environment names
        VENV_DIR="$HOME/.venv/${COMP_WORDS[2]}"
        if [[ -d "$VENV_DIR" ]]; then
            COMPREPLY=($(compgen -W "$(ls "$VENV_DIR")" -- "${COMP_WORDS[COMP_CWORD]}"))
        else
            COMPREPLY=()
        fi
    else
        COMPREPLY=()
    fi
}


function venv() {
    local COMMAND PYTHON_VERSION PYTHON_EXEC VENV_DIR SITE_PACKAGES_DIR

    if [[ $# -lt 1 ]]; then
        echo "Usage: venv <command> <python_version> [argument]"
        echo "Use 'venv h' for a list of available commands."
        return 1
    fi
    
    COMMAND=$1
    PYTHON_VERSION=$2
    shift 2
    
    if [[ $PYTHON_VERSION ]]; then
        _venv_check_system_availablity_of_py_version $PYTHON_VERSION
        _venv_check_py_version_in_venv_dir $PYTHON_VERSION
        PYTHON_EXEC="python$PYTHON_VERSION"
        VENV_DIR="$HOME/.venv/$PYTHON_VERSION"
    fi
    
    case $COMMAND in
        m | make)
            if [[ $# -ge 3 ]]; then
                echo "Usage: venv m $PYTHON_VERSION [path]"
                return 1
            fi
            if [[ $# == 1 ]]; then
                $PYTHON_EXEC -m venv "$VENV_DIR/$1"
                echo "Virtual environment '$1' successfully created in $VENV_DIR/$1"
            elif [[ $# == 2 ]]; then
                if [[ $2 == "/" ]]; then
                    echo "Cannot create an venv in /"
                    return 1
                fi
                local SAVE_TO=$(_venv_remove_trailing_dir_sep $2)
                if [[ -d $SAVE_TO ]]; then
                    $PYTHON_EXEC -m venv "$SAVE_TO/$1"
                    echo "Virtual environment '$1' successfully created in $SAVE_TO/$1"
                else
                    echo "$2 is not a dir"
                fi
            fi
            ;;

        a | activate)
            if [[ $# -eq 1 ]]; then
                if [[ -f ".venv/bin/activate" ]]; then
                    source ".venv/bin/activate"
                else
                    echo "Error: .venv/bin/activate not found. Specify a venv directly."
                    return 1
                fi
            elif [[ -d "$VENV_DIR/$1" ]]; then
                if [[ -f "$VENV_DIR/$1/bin/activate" ]]; then
                    source "$VENV_DIR/$1/bin/activate"
                else
                    echo ""$VENV_DIR/$1/bin/activate" does not exist"
                fi
            else
                echo "Error: Virtual environment '$1' does not exist in $VENV_DIR"
                return 1
            fi
            ;;

        list)
            echo "Available virtual environments for Python $PYTHON_VERSION:"
            ls "$VENV_DIR"
            ;;

        d | delete)
            if [[ $# -ne 1 ]]; then
                echo "Usage: venv del $PYTHON_VERSION <venv_name>"
                return 1
            fi
            if [[ ! -d "$VENV_DIR/$1" ]]; then
                echo "Error: Virtual environment '$1' does not exist in $VENV_DIR"
                return 1
            fi
            read -p "Are you sure you want to delete virtual environment '$1'? [y/N]: " response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                rm -rf "$VENV_DIR/$1"
                echo "Virtual environment '$1' has been deleted."
            else
                echo "Deletion cancelled."
            fi
            ;;


        sp | site-packages)
            SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')
            if [[ ! $SITE_PACKAGES_DIR ]]; then
                echo "Error: Could not determine site-packages location for Python $PYTHON_EXEC."
                return 1
            fi
            if [[ $# -eq 0 ]]; then
                cd "$SITE_PACKAGES_DIR" || return
            elif [[ -d "$SITE_PACKAGES_DIR/$1" ]]; then
                cd "$SITE_PACKAGES_DIR/$1" || return
            else
                echo "Error: Package '$1' does not exist in $SITE_PACKAGES_DIR"
                return 1
            fi
            ;;

        h|help)
            echo "Usage:"
            echo "  venv <command> <python_version> [argument]"
            echo
            echo "Commands:"
            echo "  m <python_version> [PATH]            : Create a new virtual environment. Will create to PATH is specified"
            echo "  del <python_version> <venv_name>     : Delete the specified virtual environment."
            echo "  a <python_version> <venv_name>       : Activate the specified virtual environment."
            echo "  da                                   : Deactivate the currently active virtual environment."
            echo "  ls <python_version>                  : List all available virtual environments."
            echo "  sp <python_version> [PACKAGE]        : Navigate to the site-packages directory."
            echo "  h, help                              : Display this help message."
            ;;

        *)
            echo "Invalid command. Use 'venv h' or 'venv help' for a list of available commands."
            return 1
            ;;
    esac
}


complete -F _venv_completion venv
