function venv() {
    # Validate Python version
    if [[ $# -lt 2 ]]; then
        echo "Usage: venv <python_version> <option> [argument]"
        echo "Use 'venv <python_version> h' for a list of available options."
        return 1
    fi

    PYTHON_VERSION=$1
    shift

    if [[ "$PYTHON_VERSION" != "310" && "$PYTHON_VERSION" != "311" ]]; then
        echo "Error: Unsupported Python version. Use '310' or '311'."
        return 1
    fi

    PYTHON_EXEC="python${PYTHON_VERSION:0:1}.${PYTHON_VERSION:1}"
    VENV_DIR="$HOME/.venv$PYTHON_VERSION"

    if [[ ! -d "$VENV_DIR" ]]; then
        echo "Error: The directory specified in VENV_DIR ('$VENV_DIR') does not exist. Please create this directory and try again."
        return 1
    fi

    if [ ! -d $VENV_DIR ]; then
        echo "$VENV_DIR does not exist. Create it"
        return 1
    fi

    # Check the action to perform
    case $1 in
        m)
            if [[ $# -ne 2 ]]; then
                echo "Usage: venv $PYTHON_VERSION make <venv_name>"
                return 1
            fi
            $PYTHON_EXEC -m venv "$VENV_DIR/$2"
            if [[ $? -ne 0 ]]; then
                echo "Error: Failed to create virtual environment. Ensure the venv module is installed for Python $PYTHON_EXEC."
                return 1
            fi
            echo "Virtual environment '$2' successfully created in $VENV_DIR/$2"
            ;;

        a)
            if [[ $# == 1 ]]; then
                if [[ -f ".venv/bin/activate" ]]; then
                    source ".venv/bin/activate"
                else
                    echo ".venv/bin/activate was not found. Specify a venv directly"
                    return 1
                fi
            elif [[ $# -ne 2 ]]; then 
                echo "echo "Usage: venv $PYTHON_VERSION make <venv_name>""
                return 1
            else
                if [[ -d "$VENV_DIR/$2" ]]; then
                    source "$VENV_DIR/$2/bin/activate"
                else
                    echo "Error: Virtual environment '$2' does not exist in $VENV_DIR"
                fi
            fi
            ;;

        sp)
            SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')
            if [[ ! $SITE_PACKAGES_DIR ]]; then
                echo "Error: Could not determine site-packages location for Python $PYTHON_EXEC."
                return 1
            fi
            if [[ $# -eq 1 ]]; then
                cd "$SITE_PACKAGES_DIR" || return
            elif [[ $# -eq 2 ]]; then
                if [[ -d "$SITE_PACKAGES_DIR/$2" ]]; then
                    cd "$SITE_PACKAGES_DIR/$2" || return
                else
                    echo "Error: Package '$2' does not exist in $SITE_PACKAGES_DIR"
                    return 1
                fi
            else
                echo "Usage: venv $PYTHON_VERSION site-packages [package_name]"
                return 1
            fi
            ;;

        da)
            if [[ -z "$VIRTUAL_ENV" ]]; then
                echo "No virtual environment is currently activated."
                return 1
            fi
            deactivate
            ;;

        ls)
            echo "Available virtual environments for Python $PYTHON_VERSION:"
            if [[ -d "$VENV_DIR" ]]; then
                ls "$VENV_DIR"
            else
                echo "No virtual environments found in $VENV_DIR"
            fi
            ;;

        del)
            if [[ $# -ne 2 ]]; then
                echo "Usage: venv $PYTHON_VERSION delete <venv_name>"
                return 1
            fi
            if [[ ! -d "$VENV_DIR/$2" ]]; then
                echo "Error: Virtual environment '$2' does not exist in $VENV_DIR"
                return 1
            fi
            read -p "Are you sure you want to delete virtual environment '$2'? [y/N]: " response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                rm -rf "$VENV_DIR/$2"
                echo "Virtual environment '$2' has been deleted."
            else
                echo "Deletion cancelled."
            fi
            ;;

        h|help)
            echo "Usage: venv <python_version> <option> [argument]"
            echo "Options:"
            echo "  m <venv_name>                  : Create a new virtual environment."
            echo "  del                            : Delete the specified virtual environment."
            echo "  a <venv_name>                  : Activate the specified virtual environment."
            echo "  da                             : Deactivate the currently active virtual environment."
            echo "  ls                             : List all available virtual environments in $VENV_DIR."
            echo "  sp [package]                   : Navigate to the site-packages directory or specified package directory."
            echo "  h, help                        : Display this help message."
            ;;

        *)
            echo "Invalid option. Use 'venv $PYTHON_VERSION h' or 'venv $PYTHON_VERSION help' for a list of available options."
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
    words=("${COMP_WORDS[@]}")

    if [[ ${#words[@]} -eq 2 ]]; then
        # Complete Python versions after `venv`
        COMPREPLY=($(compgen -W "$venv_versions" -- "$current_word"))
    elif [[ ${#words[@]} -eq 3 && "$prev_word" =~ ^(310|311)$ ]]; then
        # Complete commands after `venv <version>`
        COMPREPLY=($(compgen -W "$commands" -- "$current_word"))
    elif [[ ${#words[@]} -eq 4 && "$prev_word" =~ ^(a|del)$ ]]; then
        # Suggest virtual environment names for `venv <version> ls <TAB>`
        VENV_DIR="$HOME/.venv${COMP_WORDS[1]}"
        if [[ -d "$VENV_DIR" ]]; then
            COMPREPLY=($(compgen -W "$(ls "$VENV_DIR")" -- "$current_word"))
        else
            COMPREPLY=()
        fi
    else
        # Fallback: no completion
        COMPREPLY=()
    fi
}

# Attach the completion function to `venv`
complete -F _venv_completion venv
