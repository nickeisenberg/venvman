function _venv_activate() {
    local NAME VERSION VENV_PATH
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [[ -n $2 ]]; then
                    local NAME=$2
                    shift 2
                else
                    echo "Enter a name for --name"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    local VERSION=$2
                    shift 2
                else
                    echo "Enter a version for --version"
                    return 1
                fi
                ;;
            -p | --path)
                if [[ -n $2 ]]; then
                    local VENV_PATH=$2
                    shift 2
                elif [[ ! -n $2 ]]; then
                    local VENV_PATH="./.venv"
                else
                    echo "Enter a path for --path"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venv activate [options]"
                echo
                echo "Options:"
                echo "  -n, --name <venv_name>                   : Specify the name of the virtual environment to activate."
                echo "  -v, --version <python_version>           : Specify the Python version of the virtual environment."
                echo "  -p, --path <venv_path>                   : Manually specify the path of the virtual environment."
                echo "  -h, --help                               : Display this help message."
                echo
                echo "Examples:"
                echo "  venv activate -n myenv -v 3.10           : Activate 'myenv' created with Python 3.10"
                echo "  venv activate -p /custom/path/to/venv    : Activate virtual environment at a custom path."
                return 0
                ;;
            *)
                echo "something is wrong"
                return 1
                ;;
        esac
    done
    
    if [[ -n $VENV_PATH  && -n $VERSION ]] || [[ -n $VENV_PATH  && -n $NAME ]]; then
        echo "--path should not be used with --version and --name and vice versa."
        return 1
    elif [[ -n $NAME  && ! -n $VERSION ]] || [[ -n $VERSION  && ! -n $NAME ]]; then
        echo "--path should not be used with --version and --name and vice versa."
        return 1
    fi

    if [[ -n $NAME  && -n $VERSION && ! -n $VENV_PATH ]]; then
        local VENV_PATH="$HOME/.venv/$VERSION/$NAME"
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
                    local NAME=$2
                    shift 2
                else
                    echo "Enter a name for --name"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    local VERSION=$2
                    local PYTHON_EXEC="python$VERSION"
                    shift 2
                else
                    echo "Enter a version for --version"
                    return 1
                fi
                ;;
            -p | --path)
                if [[ -n $2 ]]; then
                    local VENV_PATH=$2
                    shift 2
                elif [[ ! -n $2 ]]; then
                    local VENV_PATH="./.venv"
                else
                    echo "Enter a path for --path"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venv make [options]"
                echo
                echo "Options:"
                echo "  -n, --name <venv_name>                       : Specify the name of the virtual environment to create."
                echo "  -v, --version <python_version>               : Specify the Python version to use for the virtual environment."
                echo "  -p, --path <venv_path>                       : Manually specify the directory where the virtual environment should be created."
                echo "  -h, --help                                   : Display this help message."
                echo
                echo "Examples:"
                echo "  venv make -n project_env -v 3.10             : Create a virtual environment named 'project_env' using Python 3.10."
                echo "  venv make -n myenv -v 3.9 -p /custom/path    : Create 'myenv' using Python 3.9 at '/custom/path'."
                return 0
                ;;
            *)
                echo "something is wrong"
                return 1
                ;;
        esac
    done

    if ! command -v $PYTHON_EXEC &> /dev/null; then
        echo "Python version $VERSION not available on this system."
        return 1
    fi

    if [[ -n $NAME  && -n $VERSION && ! -n $VENV_PATH ]]; then
        local VENV_PATH="$HOME/.venv/$VERSION/$NAME"
        $PYTHON_EXEC -m venv $VENV_PATH

    elif [[ -n $NAME  && -n $VERSION && -n $VENV_PATH ]]; then
        local VENV_PATH="$VENV_PATH/$NAME"
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
                echo "Usage:"
                echo "  venv ls [options]"
                echo
                echo "Options:"
                echo "  -v, --version <python_version>     : List virtual environments for a specific Python version."
                echo "  -h, --help                         : Display this help message."
                echo
                echo "Examples:"
                echo "  venv ls                            : List all available virtual environments grouped by Python version."
                echo "  venv ls -v 3.10                    : List virtual environments created with Python 3.10."
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
                    local NAME=$2
                    shift 2
                else
                    echo "Enter a name for --name"
                    return 1
                fi
                ;;
            -v | --version)
                if [[ -n $2 ]]; then
                    local VERSION=$2
                    shift 2
                else
                    echo "Enter a version for --version"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venv delete [options]"
                echo
                echo "Options:"
                echo "  -n, --name <venv_name>            : Specify the name of the virtual environment to delete."
                echo "  -v, --version <python_version>    : Specify the Python version associated with the virtual environment."
                echo "  -h, --help                        : Display this help message."
                echo
                echo "Examples:"
                echo "  venv delete -n myenv -v 3.10      : Delete the virtual environment 'myenv' created with Python 3.10."
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
                echo "Usage:"
                echo "  venv site-package [options]"
                echo
                echo "Options:"
                echo "  -pkg, --package <package_name>   : Navigate to the directory of a specific installed package."
                echo "  -h, --help                       : Display this help message."
                echo
                echo "Examples:"
                echo "venv site-package                  : Navigate to the site-packages directory of the active virtual environment."
                echo "  venv site-package -pkg numpy     : Navigate to the directory of the installed 'numpy' package."
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
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local words=("${COMP_WORDS[@]}")

    # Available commands
    local commands="make activate list delete site-packages"

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
                local has_version=true
                if [[ -n "${COMP_WORDS[i+1]}" && ! "${COMP_WORDS[i+1]}" =~ ^-- ]]; then
                    local version_provided="${COMP_WORDS[i+1]}"
                fi
                ;;
            --name)
                local has_name=true
                if [[ -n "${COMP_WORDS[i+1]}" && ! "${COMP_WORDS[i+1]}" =~ ^-- ]]; then
                    local name_provided="${COMP_WORDS[i+1]}"
                fi
                ;;
            --path) local has_path=true ;;
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
    local COMMAND

    if [[ $# -lt 1 ]]; then
        echo "Usage: venv <command> <python_version> [argument]"
        echo "Use 'venv h' for a list of available commands."
        return 1
    fi
    
    local COMMAND=$1
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
            echo "Commands:"
            echo "  m , make             : Create a new virtual environment. Will create to PATH is specified."
            echo "  d , delete           : Delete the specified virtual environment."
            echo "  a , activate         : Activate the specified virtual environment."
            echo "  list                 : List all available virtual environments."
            echo "  sp , site-packages   : Navigate to the site-packages directory."
            echo "  -h , --help          : Display this help message."
            echo
            echo "Usage:"
            echo "  See \`venv <command> --help\` for usage of each command."
            ;;

        *)
            echo "Invalid command. Use 'venv h' or 'venv help' for a list of available commands."
            return 1
            ;;
    esac
}


complete -F _venv_completion venv
