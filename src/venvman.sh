. "${VENVMAN_ROOT_DIR}/venvman/src/helpers.sh"
. "${VENVMAN_ROOT_DIR}/venvman/src/commands/commands.sh"

venvman() {
    case $1 in
        m | make)
            shift
            _venvman_make "$@"
            ;;

        a | activate)
            shift
            _venvman_activate "$@"
            ;;

        c | clone)
            shift
            _venvman_clone "$@"
            ;;

        list)
            shift
            _venvman_list "$@"
            ;;

        d | delete)
            shift
            _venvman_delete "$@"
            ;;

        sp | site-packages)
            shift
            _venvman_site_packages "$@"
            ;;

        -h| --help)
            _venvman_help_tag \
                --commands \
                    "m, make" \
                    "c, clone" \
                    "a, activate" \
                    "list" \
                    "sp, site-packages" \
                    "-h, --help" \
                --commands-descriptions \
                    "Create a new virtual environment. Will create to PATH is specified." \
                    "Delete the specified virtual environment." \
                    "Activate the specified virtual environment." \
                    "List all available virtual environments." \
                    "Navigate to the site-packages directory." \
                    "Display this help message." 
            ;;
        *)
            printf "Invalid usage. See the help doc below.\n\n" >&2
            venvman --help >&2
            return 1
            ;;
    esac
}
