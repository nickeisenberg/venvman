venvman() {
    case $1 in
        m | make)
            shift
            ${VENVMAN_COMMANDS_DIR}/make "$@"
            ;;

        a | activate)
            shift
            . ${VENVMAN_COMMANDS_DIR}/activate.sh
            venvman_activate "$@"
            unset -f venvman_activate
            ;;

        c | clone)
            shift
            ${VENVMAN_COMMANDS_DIR}/clone "$@"
            ;;

        list)
            shift
            ${VENVMAN_COMMANDS_DIR}/list "$@"
            ;;

        d | delete)
            shift
            ${VENVMAN_COMMANDS_DIR}/delete "$@"
            ;;

        sp | site-packages)
            shift
            . ${VENVMAN_COMMANDS_DIR}/site-packages.sh "$@"
            venvman_site_packages "$@"
            unset -f venvman_site_packages
            ;;

        -h| --help)
            ${VENVMAN_UTILS_DIR}/messages/venvman_help_tag \
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
