_venvman_shell_completion() {
    [[ -n $VENVMAN_ROOT_DIR ]] || local VENVMAN_ROOT_DIR="$HOME/.venvman" 
    [[ -n $VENVMAN_ENVS_DIR ]] || local VENVMAN_ENVS_DIR="$VENVMAN_ROOT_DIR/envs" 

    local -a words
    local cur prev

    words=(${(z)BUFFER})
    cur=${words[$CURRENT]:-}
    prev=${words[$CURRENT-1]:-}

    local commands=("make" "clone" "activate" "list" "delete" "site-packages")

    local -a version_options
    version_options=($(ls -1 "$VENVMAN_ENVS_DIR" 2>/dev/null))
     
    local -a name_options
    get_name_options() {
        local VENV_VERSION_DIR=$1
        [[ -d "$VENV_VERSION_DIR" ]] || return
        print -l -- "$VENV_VERSION_DIR"/*(N:t)
    }

    local has_version=false
    local has_name=false
    local has_path=false
    local has_parent=false
    local has_clone_to=false
    local version_provided=""
    local name_provided=""
    local parent_provided=""

    for ((i = 1; i < CURRENT; i++)); do
        case "${words[i]}" in
            --version)
                has_version=true
                if [[ -n "${words[i+1]}" && "${words[i+1]}" != --* ]]; then
                    version_provided="${words[i+1]}"
                fi
                ;;
            --name)
                has_name=true
                if [[ -n "${words[i+1]}" && "${words[i+1]}" != --* ]]; then
                    name_provided="${words[i+1]}"
                fi
                ;;
            --parent)
                has_parent=true
                if [[ -n "${words[i+1]}" && "${words[i+1]}" != --* ]]; then
                    parent_provided="${words[i+1]}"
                fi
                ;;
            --clone-to)
                has_clone_to=true
                ;;
            --path)
                has_path=true
                ;;
        esac
    done

    # Top-level command completion
    if [[ $prev == "venvman" ]]; then
        compadd -a commands
        return 0
    fi

    local subcommand="${words[2]}"

    case "$subcommand" in
        make)
            if [[ "$prev" == "make" && "$has_version" == false ]]; then
                compadd -- "--version"
                return 0
            elif [[ "$prev" == "--version" ]]; then
                compadd -a version_options 
                return 0
            elif [[ "$has_version" == true && "$has_name" == false && "$prev" != "--name" ]]; then
                compadd -- "--name"
                return 0
            elif [[ "$prev" == "--name" ]]; then
                return 0
            elif [[ "$has_version" == true && "$has_name" == true && "$has_path" == false ]]; then
                compadd -- "--path"
                return 0
            elif [[ "$prev" == "--path" ]]; then
                _files -/
                return 0
            fi
            ;;

        clone)
            if [[ "$prev" == "clone" && "$has_version" == false ]]; then
                compadd -- "--version"
                return 0
            elif [[ "$prev" == "--version" ]]; then
                compadd -a version_options 
                return 0
            elif [[ "$has_version" == true && "$has_parent" == false && "$prev" != "--parent" ]]; then
                compadd -- "--parent"
                return 0
            elif [[ "$prev" == "--parent" && -n $version_provided ]]; then
                name_options=($(get_name_options "$VENVMAN_ENVS_DIR/$version_provided"))
                compadd -a name_options
                return 0
            elif [[ "$has_version" == true && "$has_parent" == true && $has_clone_to == false && "$prev" != "--clone-to" ]]; then
                compadd -- "--clone-to"
            elif [[ "$prev" == "--clone-to" ]]; then
                _files -/
                return 0
            fi
            ;;

        activate)
            compadd -a version_options
            return 0
            ;;
        list)
            return 0
            ;;
        delete)
            compadd -a version_options
            return 0
            ;;
    esac
}

compdef _venvman_shell_completion venvman
