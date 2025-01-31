function venv() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: venv <command> <python_version> [argument]"
        echo "Use 'venv h' for a list of available commands."
        return 1
    fi

    COMMAND=$1
    PYTHON_VERSION=$2
    shift 2
    
    if [[ $PYTHON_VERSION ]]; then
        if [[ "$PYTHON_VERSION" != "310" && "$PYTHON_VERSION" != "311" ]]; then
            echo "Error: Unsupported Python version. Use '310' or '311'."
            return 1
        fi
        PYTHON_EXEC="python${PYTHON_VERSION:0:1}.${PYTHON_VERSION:1}"
        VENV_DIR="$HOME/.venv$PYTHON_VERSION"
        if [[ ! -d "$VENV_DIR" ]]; then
            echo "Error: The directory '$VENV_DIR' does not exist. Please create this directory and try again."
            return 1
        fi
    fi


    case $COMMAND in
        m)
            if [[ $# -ne 1 ]]; then
                echo "Usage: venv m $PYTHON_VERSION"
                return 1
            fi
            $PYTHON_EXEC -m venv "$VENV_DIR/default"
            echo "Virtual environment 'default' successfully created in $VENV_DIR/default"
            ;;

        a)
            if [[ $# -eq 1 ]]; then
                if [[ -f ".venv/bin/activate" ]]; then
                    source ".venv/bin/activate"
                else
                    echo "Error: .venv/bin/activate not found. Specify a venv directly."
                    return 1
                fi
            elif [[ -d "$VENV_DIR/$1" ]]; then
                source "$VENV_DIR/$1/bin/activate"
            else
                echo "Error: Virtual environment '$1' does not exist in $VENV_DIR"
                return 1
            fi
            ;;

        ls)
            echo "Available virtual environments for Python $PYTHON_VERSION:"
            ls "$VENV_DIR"
            ;;

        del)
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

        da)
            if [[ -z "$VIRTUAL_ENV" ]]; then
                echo "No virtual environment is currently activated."
                return 1
            fi
            deactivate
            ;;

        sp)
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
            echo "Usage: venv <command> <python_version> [argument]"
            echo "Commands:"
            echo "  m <python_version>                  : Create a new virtual environment."
            echo "  del <python_version> <venv_name>     : Delete the specified virtual environment."
            echo "  a <python_version> <venv_name>       : Activate the specified virtual environment."
            echo "  da                                   : Deactivate the currently active virtual environment."
            echo "  ls <python_version>                  : List all available virtual environments."
            echo "  sp <python_version> [package]        : Navigate to the site-packages directory."
            echo "  h, help                              : Display this help message."
            ;;

        *)
            echo "Invalid command. Use 'venv h' or 'venv help' for a list of available commands."
            return 1
            ;;
    esac
}

_venv_completion() {
    local current_word prev_word words
    local venv_versions="310 311"
    local commands="m a sp da ls del h"

    current_word="${COMP_WORDS[COMP_CWORD]}"
    prev_word="${COMP_WORDS[COMP_CWORD-1]}"
    prevprev_word="${COMP_WORDS[COMP_CWORD-2]}"
    words=("${COMP_WORDS[@]}")

    if [[ ${#words[@]} -eq 2 ]]; then
        # Complete commands after `venv`
        COMPREPLY=($(compgen -W "$commands" -- "$current_word"))
    elif [[ ${#words[@]} -eq 3 && "$prev_word" =~ ^(m|a|sp|ls|del)$ ]]; then
        # Complete Python versions after `venv <command>`
        COMPREPLY=($(compgen -W "$venv_versions" -- "$current_word"))
    elif [[ ${#words[@]} -eq 4 && "$prevprev_word" =~ ^(a|del)$ ]]; then
        # Suggest virtual environment names
        VENV_DIR="$HOME/.venv${COMP_WORDS[2]}"
        if [[ -d "$VENV_DIR" ]]; then
            COMPREPLY=($(compgen -W "$(ls "$VENV_DIR")" -- "$current_word"))
        else
            COMPREPLY=()
        fi
    else
        COMPREPLY=()
    fi
}

# Attach the completion function to `venv`
complete -F _venv_completion venv
