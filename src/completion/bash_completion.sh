function _venvman_shell_completion() {
    local cur prev words
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"
    local words=("${COMP_WORDS[@]}")

    local commands="make clone activate list delete site-packages"

    local version_options=$(ls -1 "$VENVMAN_ENVS_DIR" 2>/dev/null)

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

    local subcommand="${COMP_WORDS[1]}"

    case "$subcommand" in
        make)
            if [[ "$prev" == "make" && "$has_version" == false ]]; then
                COMPREPLY=($(compgen -W "--version" -- "$cur"))
                return 0
            elif [[ "$prev" == "--version" ]]; then
                local version_options_make=($("${VENVMAN_UTILS_DIR}/list_local_python_versions"))
                local version_options_make="${version_options_make[@]}"
                COMPREPLY=($(compgen -W "$version_options_make" -- "$cur"))
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
                    local venv_dir="$VENVMAN_ENVS_DIR/$version_provided"
                    if [[ -d "$venv_dir" ]]; then
                        local name_options=$(ls -1 "$venv_dir" 2>/dev/null)
                        COMPREPLY=($(compgen -W "$name_options" -- "$cur"))
                        return 0
                    fi
                fi

            elif [[ "$has_version" == true && "$has_parent" == true && $has_clone_to == false && "$prev" != "--clone-to" ]]; then
                COMPREPLY=($(compgen -W "--clone-to" -- "$cur"))
                return 0
            elif [[ "$prev" == "--clone-to" ]]; then
                COMPREPLY=($(compgen -o filenames -o nospace -A directory -- "$cur"))
                return 0
            fi
            ;;


        activate)
            if [[ "$prev" == "activate" && "$has_version" == false && "$has_path" == false ]]; then
                COMPREPLY=($(compgen -W "--version --path" -- "$cur"))
                return 0
            fi

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
                    local venv_dir="$VENVMAN_ENVS_DIR/$version_provided"
                    if [[ -d "$venv_dir" ]]; then
                        local name_options=$(ls -1 "$venv_dir" 2>/dev/null)
                        COMPREPLY=($(compgen -W "$name_options" -- "$cur"))
                        return 0
                    fi
                fi
            fi

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
                    local venv_dir="$VENVMAN_ENVS_DIR/$version_provided"
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

complete -F _venvman_shell_completion venvman
