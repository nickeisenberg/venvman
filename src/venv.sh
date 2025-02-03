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


function _venv_activate() {
    local NAME VERSION VENV_PATH
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [[ -n $2 ]]; then
                    NAME=$2
                    shift 2
                else
                    echo "Enter a name for --name"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    VERSION=$2
                    shift 2
                else
                    echo "Enter a version for --version"
                    return 1
                fi
                ;;
            -p | --path)
                if [[ -n $2 ]]; then
                    VENV_PATH=$2
                    shift 2
                elif [[ ! -n $2 ]]; then
                    VENV_PATH="./.venv"
                else
                    echo "Enter a path for --path"
                    return 1
                fi
                ;;
            -h | --help)
                echo "help for activate"
                return 0
                ;;
            *)
                echo "something is wrong"
                return 1
                ;;
        esac
    done
    
    if [[ -n $VENV_PATH  && -n $VERSION ]] || [[ -n $VENV_PATH  && -n $NAME ]]; then
        echo bad
        return 1
    elif [[ -n $NAME  && ! -n $VERSION ]] || [[ -n $VERSION  && ! -n $NAME ]]; then
        echo bad
        return 1
    fi

    if [[ -n $NAME  && -n $VERSION && ! -n $VENV_PATH ]]; then
        VENV_PATH="$HOME/.venv/$VERSION/$NAME"
        if [[ -f "$VENV_PATH/bin/activate" ]]; then
            source "$VENV_PATH/bin/activate"
        else
            echo ""$VENV_PATH/bin/activate" does not exist"
        fi
    elif [[ -n $VENV_PATH ]]; then
        if [[ -f "$VENV_PATH/bin/activate" ]]; then
            source "$VENV_PATH/bin/activate"
        else
            echo ""$VENV_PATH/bin/activate" does not exist"
        fi
    fi
}


function _venv_make() {
    local NAME VERSION VENV_PATH PYTHON_EXEC
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [[ -n $2 ]]; then
                    NAME=$2
                    shift 2
                else
                    echo "Enter a name for --name"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    VERSION=$2
                    PYTHON_EXEC="python$VERSION"
                    shift 2
                else
                    echo "Enter a version for --version"
                    return 1
                fi
                ;;
            -p | --path)
                if [[ -n $2 ]]; then
                    VENV_PATH=$2
                    shift 2
                elif [[ ! -n $2 ]]; then
                    VENV_PATH="./.venv"
                else
                    echo "Enter a path for --path"
                    return 1
                fi
                ;;
            -h | --help)
                echo "help for make"
                return 0
                ;;
            *)
                echo "something is wrong"
                return 1
                ;;
        esac
    done

    if [[ -n $NAME  && -n $VERSION && ! -n $VENV_PATH ]]; then
        VENV_PATH="$HOME/.venv/$VERSION/$NAME"
        $PYTHON_EXEC -m venv $VENV_PATH

    elif [[ -n $NAME  && -n $VERSION && -n $VENV_PATH ]]; then
        VENV_PATH="$VENV_PATH/$NAME"
        $PYTHON_EXEC -m venv $VENV_PATH
    else 
        echo "invalid usage"
    fi
}


function _venv_list() {
    local VERSION VERSIONS NUM_VERSIONS VENV_PATH
    local VENV_PATH="$HOME/.venv/"
    while [ "$#" -gt 0 ]; do
        case $1 in
            -v | --version)
                if [[ -n $2 ]]; then
                    local VERSION=$2
                    local VENV_PATH="$VENV_PATH/$VERSION"
                    shift 2
                else
                    echo "Enter a version for --version"
                    return 1
                fi
                ;;
            -h | --help)
                echo "help for list"
                return 0
                ;;
            *)
                echo "something is wrong"
                return 1
                ;;
        esac
    done

    if [[ -n $VERSION ]]; then
        echo "Available virtual environments for Python $VERSION:"
        ls "$VENV_PATH"

    else
        local VERSIONS=($(ls "$HOME/.venv"))  # Store all versions in an array
        local NUM_VERSIONS=${#VERSIONS[@]}    # Get the total number of versions
    
        for ((i = 0; i < $NUM_VERSIONS; i++)); do
            local VERSION=${VERSIONS[i]}
            echo "Available virtual environments for Python $VERSION:"
            ls "$HOME/.venv/$VERSION"
            
            # Print echo unless it's the last item
            if [[ $i -lt $((NUM_VERSIONS - 1)) ]]; then
                echo
            fi
        done
    fi
}


function _venv_delete() {
    local NAME VERSION VENV_PATH
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [[ -n $2 ]]; then
                    NAME=$2
                    shift 2
                else
                    echo "Enter a name for --name"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    VERSION=$2
                    shift 2
                else
                    echo "Enter a version for --version"
                    return 1
                fi
                ;;
            -h | --help)
                echo "help for delete"
                return 0
                ;;
            *)
                echo "something is wrong"
                return 1
                ;;
        esac
    done
    
    local VENV_PATH="$HOME/.venv/$VERSION/$NAME"

    read -p "Are you sure you want to delete virtual environment $VENV_PATH? [y/N]: " response

    if [[ "$response" =~ ^[Yy]$ ]]; then
        rm -rf "$VENV_PATH"
        if [[ ! -d $VENV_PATH ]]; then
            echo "SUCCESS: Virtual environment $VENV_PATH has been deleted."
            return 0
        else
            echo "FAIL: Virtual environment $VENV_PATH has not been deleted."
            return 1
        fi
    else
        echo "Deletion cancelled."
        return 0
    fi
}


function _venv_site_packages() {
    local PKG
    local SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')
    while [ "$#" -gt 0 ]; do
        case $1 in
            -pkg | --package)
                if [[ -n $2 ]]; then
                    local PKG=$2
                    shift 2
                else
                    echo "Enter a package for --package"
                    return 1
                fi
                ;;
            -h | --help)
                echo "help for site-packages"
                return 0
                ;;
            *)
                echo "something is wrong"
                return 1
                ;;
        esac
    done
    
    if [[ ! -n $PKG ]]; then
        cd "$SITE_PACKAGES_DIR" || return
    elif [[ -d "$SITE_PACKAGES_DIR/$PKG" ]]; then
        cd "$SITE_PACKAGES_DIR/$PKG" || return
    else
        echo "Error: Package '$PKG' does not exist in $SITE_PACKAGES_DIR"
        return 1
    fi

}


function _venv_completion() {
    local cur prev words
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    words=("${COMP_WORDS[@]}")

    # Available commands
    local commands="make activate list delete site-packages help"

    # List available Python versions dynamically
    local version_options=$(ls -1 "$HOME/.venv" 2>/dev/null)

    # Track entered flags in the correct order
    local has_version=false
    local has_name=false
    local has_path=false
    local version_provided=""
    local name_provided=""

    for ((i = 1; i < COMP_CWORD; i++)); do
        case "${COMP_WORDS[i]}" in
            --version)
                has_version=true
                if [[ -n "${COMP_WORDS[i+1]}" && ! "${COMP_WORDS[i+1]}" =~ ^-- ]]; then
                    version_provided="${COMP_WORDS[i+1]}"
                fi
                ;;
            --name)
                has_name=true
                if [[ -n "${COMP_WORDS[i+1]}" && ! "${COMP_WORDS[i+1]}" =~ ^-- ]]; then
                    name_provided="${COMP_WORDS[i+1]}"
                fi
                ;;
            --path) has_path=true ;;
        esac
    done

    # Top-level command completion
    if [[ ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return 0
    fi

    # Identify which command is being used
    local subcommand="${COMP_WORDS[1]}"

    case "$subcommand" in
        make)
            # Only allow `--version` first
            if [[ "$prev" == "make" && "$has_version" == false ]]; then
                COMPREPLY=($(compgen -W "--version" -- "$cur"))
                return 0
            elif [[ "$prev" == "--version" ]]; then
                COMPREPLY=($(compgen -W "$version_options" -- "$cur"))
                return 0
            elif [[ "$has_version" == true && "$has_name" == false && "$prev" != "--name" ]]; then
                COMPREPLY=($(compgen -W "--name" -- "$cur"))
                return 0
            elif [[ "$prev" == "--name" ]]; then
                # Don't auto-complete, let the user enter a name manually
                return 0
            elif [[ "$has_version" == true && "$has_name" == true && "$has_path" == false ]]; then
                COMPREPLY=($(compgen -W "--path" -- "$cur"))
                return 0
            elif [[ "$prev" == "--path" ]]; then
                COMPREPLY=($(compgen -o filenames -o nospace -A directory -- "$cur"))
                return 0
            fi
            ;;


        activate)
            # First tab should suggest --version or --path
            if [[ "$prev" == "activate" && "$has_version" == false && "$has_path" == false ]]; then
                COMPREPLY=($(compgen -W "--version --path" -- "$cur"))
                return 0
            fi

            # If --version is given, suggest only --name
            if [[ "$prev" == "--version" ]]; then
                COMPREPLY=($(compgen -W "$version_options" -- "$cur"))
                return 0
            elif [[ "$has_version" == true && "$has_name" == false ]]; then
                COMPREPLY=($(compgen -W "--name" -- "$cur"))
                return 0
            fi

            # If --name is given, suggest available environments under the selected version
            if [[ "$prev" == "--name" ]]; then
                if [[ -n "$version_provided" ]]; then
                    local venv_dir="$HOME/.venv/$version_provided"
                    if [[ -d "$venv_dir" ]]; then
                        local name_options=$(ls -1 "$venv_dir" 2>/dev/null)
                        COMPREPLY=($(compgen -W "$name_options" -- "$cur"))
                        return 0
                    fi
                fi
            fi

            # If --path is given, no more options (user enters a custom path)
            if [[ "$prev" == "--path" ]]; then
                COMPREPLY=($(compgen -o filenames -o nospace -A directory -- "$cur"))
                return 0
            fi
            ;;


        list)
            if [[ "$prev" == "list" ]]; then
                COMPREPLY=($(compgen -W "--version" -- "$cur"))
                return 0
            elif [[ "$prev" == "--version" ]]; then
                COMPREPLY=($(compgen -W "$version_options" -- "$cur"))
                return 0
            fi
            ;;

        delete)
            if [[ "$prev" == "delete" ]]; then
                COMPREPLY=($(compgen -W "--version" -- "$cur"))
                return 0
            elif [[ "$prev" == "--version" ]]; then
                COMPREPLY=($(compgen -W "$version_options" -- "$cur"))
                return 0
            elif [[ "$prev" == "--name" ]]; then
                if [[ -n "$version_provided" ]]; then
                    local venv_dir="$HOME/.venv/$version_provided"
                    if [[ -d "$venv_dir" ]]; then
                        local name_options=$(ls -1 "$venv_dir" 2>/dev/null)
                        COMPREPLY=($(compgen -W "$name_options" -- "$cur"))
                        return 0
                    fi
                fi
            elif [[ "$has_version" == true && "$has_name" == false ]]; then
                COMPREPLY=($(compgen -W "--name" -- "$cur"))
                return 0
            fi
            ;;


        site-packages)
            if [[ "$prev" == "site-packages" ]]; then
                COMPREPLY=($(compgen -W "--package" -- "$cur"))
                return 0
            elif [[ "$prev" == "--package" ]]; then
                # Get the correct site-packages directory of the active virtual environment
                local site_packages_dir=$(python -c "import sys; print(next(p for p in sys.path if 'site-packages' in p))" 2>/dev/null)

                # Check if the site-packages directory exists
                if [[ -d "$site_packages_dir" ]]; then
                    local packages=$(ls -1 "$site_packages_dir" 2>/dev/null)
                    COMPREPLY=($(compgen -W "$packages" -- "$cur"))
                    return 0
                fi
            fi
    ;;

    esac

    COMPREPLY=()
}


function venv() {
    local COMMAND PYTHON_VERSION PYTHON_EXEC VENV_DIR SITE_PACKAGES_DIR

    if [[ $# -lt 1 ]]; then
        echo "Usage: venv <command> <python_version> [argument]"
        echo "Use 'venv h' for a list of available commands."
        return 1
    fi
    
    COMMAND=$1
    shift 1
    
    case $COMMAND in
        m | make)
            _venv_make $@
            ;;

        a | activate)
            _venv_activate $@
            ;;

        list)
            _venv_list $@
            ;;

        d | delete)
            _venv_delete $@
            ;;

        sp | site-packages)
            _venv_site_packages $@
            ;;

        -h| --help)
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
            echo "  -h, --help                           : Display this help message."
            ;;

        *)
            echo "Invalid command. Use 'venv h' or 'venv help' for a list of available commands."
            return 1
            ;;
    esac
}


complete -F _venv_completion venv
