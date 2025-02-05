_venvman_zsh_completion() {
    local -a commands
    commands=(make clone activate list delete site-packages)

    local -a versions
    local VENVMAN_ROOT_DIR=${VENVMAN_ROOT_DIR:-$HOME/.venvman}
    local VENVMAN_ENVS_DIR=${VENVMAN_ENVS_DIR:-$VENVMAN_ROOT_DIR/envs}

    versions=(${(f)"$(ls -1 $VENVMAN_ENVS_DIR 2>/dev/null)"})

    local curcontext="$curcontext" state state_descr line
    typeset -A opt_args
    _arguments -C \
        '1: :->commands' \
        '*::args:->args'

    case "$state" in
        commands)
            _values "venvman commands" $commands
            ;;
        args)
            case $words[1] in
                make)
                    _arguments \
                        '--version[Select version]:version:(${versions})' \
                        '--name[Specify environment name]' \
                        '--path[Specify custom path]:path:_files -/'
                    ;;
                clone)
                    _arguments \
                        '--version[Select version]:version:(${versions})' \
                        '--parent[Specify parent environment]:env:_files -/' \
                        '--clone-to[Specify target clone path]:path:_files -/'
                    ;;
                activate)
                    _arguments \
                        '--version[Select version]:version:(${versions})' \
                        '--name[Specify environment name]:env:_files -/' \
                        '--path[Specify custom path]:path:_files -/'
                    ;;
                list)
                    _arguments '--version[Select version]:version:(${versions})'
                    ;;
                delete)
                    _arguments \
                        '--version[Select version]:version:(${versions})' \
                        '--name[Specify environment name]:env:_files -/'
                    ;;
                site-packages)
                    _arguments '--package[Specify package name]:package:_files -/'
                    ;;
            esac
            ;;
    esac
}

