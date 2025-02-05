#!/usr/bin/env bash

VENVMAN_SAVE_DIR=$HOME/.venvman


function _venvman_make() {
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
                    local VENV_PATH="./.venvman"
                else
                    echo "Enter a path for --path"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venvman make [options]"
                echo
                echo "Options:"
                echo "  -n, --name <venv_name>                       : Specify the name of the virtual environment to create."
                echo "  -v, --version <python_version>               : Specify the Python version to use for the virtual environment."
                echo "  -p, --path <venv_path>                       : Manually specify the directory where the virtual environment should be created."
                echo "  -h, --help                                   : Display this help message."
                echo
                echo "Examples:"
                echo "  venvman make -n project_env -v 3.10             : Create a virtual environment named 'project_env' using Python 3.10."
                echo "  venvman make -n myenv -v 3.9 -p /custom/path    : Create 'myenv' using Python 3.9 at '/custom/path'."
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
        local VENV_PATH="$VENVMAN_SAVE_DIR/$VERSION/$NAME"
        if [[ ! -d $VENVMAN_SAVE_DIR/$VERSION ]]; then
            echo "The directory $VENVMAN_SAVE_DIR/$VERSION does not exit. Creating now."
            mkdir -p $VENV_PATH
            if [[ -d $VENV_PATH ]]; then
                echo "SUCCESS: $VENVMAN_SAVE_DIR/$VERSION has been created."
            else
                echo "FAIL: $VENVMAN_SAVE_DIR/$VERSION has not been created."
                return 1
            fi
        fi
        $PYTHON_EXEC -m venv $VENV_PATH

    elif [[ -n $NAME  && -n $VERSION && -n $VENV_PATH ]]; then
        local VENV_PATH="$VENV_PATH/$NAME"
        $PYTHON_EXEC -m venv $VENV_PATH

    else 
        echo "invalid usage"
    fi
}


function _venvman_activate() {
    local NAME VERSION VENV_PATH
    while [ "$#" -gt 0 ]; do
        case $1 in
            -n | --name)
                if [[ -n $2 ]]; then
                    local NAME=$2
                    shift 2
                else
                    echo "ACTIVATION ERROR: Enter a name for --name"
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
                    local VENV_PATH="./.venvman"
                else
                    echo "Enter a path for --path"
                    return 1
                fi
                ;;
            -h | --help)
                echo "Usage:"
                echo "  venvman activate [options]"
                echo
                echo "Options:"
                echo "  -n, --name <venv_name>                   : Specify the name of the virtual environment to activate."
                echo "  -v, --version <python_version>           : Specify the Python version of the virtual environment."
                echo "  -p, --path <venv_path>                   : Manually specify the path of the virtual environment."
                echo "  -h, --help                               : Display this help message."
                echo
                echo "Examples:"
                echo "  venvman activate -n myenv -v 3.10           : Activate 'myenv' created with Python 3.10"
                echo "  venvman activate -p /custom/path/to/venv    : Activate virtual environment at a custom path."
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
        local VENV_PATH="$VENVMAN_SAVE_DIR/$VERSION/$NAME"
        local PATH_TO_ACTIVATE=$(find $VENV_PATH -type f -name "activate")
        if [[ -n $PATH_TO_ACTIVATE ]]; then
            source $PATH_TO_ACTIVATE
        else
            echo "activate script cannot be found"
        fi

    elif [[ -n $VENV_PATH && ! -n $NAME  && ! -n $VERSION  ]]; then
        local PATH_TO_ACTIVATE=$(find $VENV_PATH -type f -name "activate")
        if [[ -n $PATH_TO_ACTIVATE ]]; then
            source $PATH_TO_ACTIVATE
        else
            echo "activate script cannot be found does"
        fi
    fi
}


function _venvman_clone() {
    local PARENT VERSION VENV_PATH PYTHON_EXEC
    while [ "$#" -gt 0 ]; do
        case $1 in
            -p | --parent)
                if [[ -n $2 ]]; then
                    local PARENT=$2
                    shift 2
                else
                    echo "Enter a name for the parent venv with --parent"
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
            -to | --clone-to)
                if [[ -n $2 ]]; then
                    local CLONE_TO=$2
                    shift 2
                else
                    echo "Enter a version for --clone-to"
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
                echo "something is wrong"
                return 1
                ;;
        esac
    done

    if ! command -v $PYTHON_EXEC &> /dev/null; then
        echo "Python version $VERSION not available on this system."
        return 1
    fi

    if [[ $PARENT == $CLONE_TO ]]; then
        echo "The name of the child repo must have a different name than its parent"
        return 1
    fi

    if [[ -n $PARENT && -n $VERSION && -n $CLONE_TO ]]; then

        _venvman_activate --version $VERSION --name $PARENT
        local PARENT_SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')
        deactivate

        _venvman_make --version $VERSION --name $CLONE_TO
        _venvman_activate --version $VERSION --name $CLONE_TO
        local CLONE_SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')
        deactivate

        cp -r $PARENT_SITE_PACKAGES_DIR/* $CLONE_SITE_PACKAGES_DIR/

    else 
        echo "invalid usage"
    fi
}


function _venvman_list() {
    local VERSION VERSIONS NUM_VERSIONS VENV_PATH
    local VENV_PATH="$VENVMAN_SAVE_DIR/"
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
                echo "  venvman list [options]"
                echo
                echo "Options:"
                echo "  -v, --version <python_version>     : List virtual environments for a specific Python version."
                echo "  -h, --help                         : Display this help message."
                echo
                echo "Examples:"
                echo "  venvman list                            : List all available virtual environments grouped by Python version."
                echo "  venvman list -v 3.10                    : List virtual environments created with Python 3.10."
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
        local VERSIONS=($(ls "$VENVMAN_SAVE_DIR"))  # Store all versions in an array
        local NUM_VERSIONS=${#VERSIONS[@]}    # Get the total number of versions
    
        for ((i = 0; i < $NUM_VERSIONS; i++)); do
            local VERSION=${VERSIONS[i]}
            echo "Available virtual environments for Python $VERSION:"
            ls "$VENVMAN_SAVE_DIR/$VERSION"
            
            # Print echo unless it's the last item
            if [[ $i -lt $((NUM_VERSIONS - 1)) ]]; then
                echo
            fi
        done
    fi
}


function _venvman_delete() {
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
                echo "  venvman delete [options]"
                echo
                echo "Options:"
                echo "  -n, --name <venv_name>            : Specify the name of the virtual environment to delete."
                echo "  -v, --version <python_version>    : Specify the Python version associated with the virtual environment."
                echo "  -h, --help                        : Display this help message."
                echo
                echo "Examples:"
                echo "  venvman delete -n myenv -v 3.10      : Delete the virtual environment 'myenv' created with Python 3.10."
                return 0
                ;;
            *)
                echo "something is wrong"
                return 1
                ;;
        esac
    done
    
    local VENV_PATH="$VENVMAN_SAVE_DIR/$VERSION/$NAME"

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


function _venvman_site_packages() {
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


function _venvman_completion() {
    local cur prev words
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local words=("${COMP_WORDS[@]}")

    # Available commands
    local commands="make clone activate list delete site-packages"

    # List available Python versions dynamically
    local version_options=$(ls -1 "$VENVMAN_SAVE_DIR" 2>/dev/null)

    # Track entered flags in the correct order
    local has_version=false
    local has_name=false
    local has_path=false
    local has_parent=false
    local has_clone_to=false
    local version_provided=""
    local name_provided=""
    local parent_provided=""

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
            --parent)
                local has_parent=true
                if [[ -n "${COMP_WORDS[i+1]}" && ! "${COMP_WORDS[i+1]}" =~ ^-- ]]; then
                    local name_parent="${COMP_WORDS[i+1]}"
                fi
                ;;
            --clone-to)
                local has_clone_to=true 
                ;;
            --path) 
                local has_path=true 
                ;;
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

        clone)
            # Only allow `--version` first
            if [[ "$prev" == "clone" && "$has_version" == false ]]; then
                COMPREPLY=($(compgen -W "--version" -- "$cur"))
                return 0

            elif [[ "$prev" == "--version" ]]; then
                COMPREPLY=($(compgen -W "$version_options" -- "$cur"))
                return 0

            elif [[ "$has_version" == true && "$has_parent" == false && "$prev" != "--parent" ]]; then
                COMPREPLY=($(compgen -W "--parent" -- "$cur"))
                return 0

            elif [[ "$prev" == "--parent" ]]; then
                if [[ -n "$version_provided" ]]; then
                    local venv_dir="$VENVMAN_SAVE_DIR/$version_provided"
                    if [[ -d "$venv_dir" ]]; then
                        local name_options=$(ls -1 "$venv_dir" 2>/dev/null)
                        COMPREPLY=($(compgen -W "$name_options" -- "$cur"))
                        return 0
                    fi
                fi

            elif [[ "$has_version" == true && "$has_parent" == true && $has_clone_to == false && "$prev" != "--clone-to" ]]; then
                COMPREPLY=($(compgen -W "--clone-to" -- "$cur"))
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
                    local venv_dir="$VENVMAN_SAVE_DIR/$version_provided"
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
                    local venv_dir="$VENVMAN_SAVE_DIR/$version_provided"
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


function venvman() {
    local COMMAND

    if [[ $# -lt 1 ]]; then
        echo "Usage: venvman <command> <python_version> [argument]"
        echo "Use 'venvman --help' for a list of available commands."
        return 1
    fi
    
    local COMMAND=$1
    shift 1
    
    case $COMMAND in
        m | make)
            _venvman_make $@
            ;;

        a | activate)
            _venvman_activate $@
            ;;

        c | clone)
            _venvman_clone $@
            ;;

        list)
            _venvman_list $@
            ;;

        d | delete)
            _venvman_delete $@
            ;;

        sp | site-packages)
            _venvman_site_packages $@
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
            echo "  See \`venvman <command> --help\` for usage of each command."
            ;;

        *)
            echo "Invalid command. Use 'venvman h' or 'venvman help' for a list of available commands."
            return 1
            ;;
    esac
}


if [[ $SHELL == *"bash"* ]]; then
    complete -F _venvman_completion venvman
fi
