_venvman_shell_completion() {
    local -a words
    local cur prev

    words=(${(z)BUFFER})
    cur=${words[$CURRENT]:-}
    prev=${words[$CURRENT-1]:-}

    local -a commands=("make" "clone" "activate" "list" "delete" "site-packages")

    get_options_from_dir() {
        local DIR=$1
        [[ -d "$DIR" ]] || return
        echo $(ls -1 "$DIR" 2>/dev/null)
    }

    local -a version_options
    version_options=($(get_options_from_dir $VENVMAN_ENVS_DIR))
     
    local -a name_options

    get_site_packages_dir() {
        local py="import sys;"
        local py="${py} print(next(p for p in sys.path if 'site-packages' in p))"
        echo $(python -c $py 2>/dev/null)
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
                local -a version_options
                version_options=($("${VENVMAN_UTILS_DIR}/list_local_python_versions"))
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
                local dir="$VENVMAN_ENVS_DIR/$version_provided"
                name_options=($(get_options_from_dir $dir))
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
            if [[ "$prev" == "activate" && "$has_version" == false ]]; then
                compadd -- "--version" "--path"
                return 0
            elif [[ "$prev" == "--version" ]]; then
                compadd -a version_options 
                return 0
            elif [[ "$has_version" == true && "$has_name" == false && "$prev" != "--name" ]]; then
                compadd -- "--name"
                return 0
            elif [[ "$prev" == "--name" && -n $version_provided ]]; then
                local dir="$VENVMAN_ENVS_DIR/$version_provided"
                name_options=($(get_options_from_dir $dir))
                compadd -a name_options
                return 0
            fi

            if [[ "$prev" == "--path" ]]; then
                compadd -- "--path"
                _files -/
                return 0
            fi
            ;;

        list)
            if [[ "$prev" == "list" ]]; then
                compadd -- "--version"
                return 0
            elif [[ "$prev" == "--version" ]]; then
                compadd -a version_options 
            fi
            ;;

        delete)
            if [[ "$prev" == "delete" && "$has_version" == false ]]; then
                compadd -- "--version"
                return 0
            elif [[ "$prev" == "--version" ]]; then
                compadd -a version_options 
                return 0
            elif [[ "$has_version" == true && "$has_name" == false && "$prev" != "--name" ]]; then
                compadd -- "--name"
                return 0
            elif [[ "$prev" == "--name" && -n $version_provided ]]; then
                local dir="$VENVMAN_ENVS_DIR/$version_provided"
                name_options=($(get_options_from_dir $dir))
                compadd -a name_options
                return 0
            fi
            return 0
            ;;

        site-packages)
            if [[ "$prev" == "site-packages" ]]; then
                compadd -- "--package"
                return 0
            elif [[ "$prev" == "--package" ]]; then
                local site_packages_dir=$(get_site_packages_dir)
                if [[ -d "$site_packages_dir" ]]; then
                    local -a packages
                    packages=($(get_options_from_dir $site_packages_dir))
                    compadd -a packages 
                fi
                return 0
            fi
            ;;
    esac
}

compdef _venvman_shell_completion venvman
