if [ -z "$VENVMAN_ROOT_DIR" ] || [ -z "$VENVMAN_ENVS_DIR" ]; then 
    echo "ERROR: VENVMAN_ROOT_DIR and VENVMAN_ENVS_DIR must be set."
    echo "The following is suggested to solve this problem."
    echo

    echo "1) Run the following in you shell:"
    echo
    MSG_LINES=(
        "VENVMAN_ROOT_DIR=\$HOME/.venvman"
        "mkdir -p \$VENVMAN_ROOT_DIR"
        "git clone https://github.com/nickeisenberg/venvman.git "\${VENVMAN_ROOT_DIR}/venvman""
    )
    printf "%s\n" "${MSG_LINES[@]}"

    echo
    echo "2) Add the following in your shell's config:"
    echo
    MSG_LINES=(
        "VENVMAN_ROOT_DIR=\$HOME/.venvman"
        "VENVMAN_ENVS_DIR=\$HOME/.venvman/envs"
        "source \$VENVMAN_ROOT_DIR/venvman/src/venvman.sh"
        "source \$VENVMAN_ROOT_DIR/venvman/src/completion/completion.sh"
    )
    printf "%s\n" "${MSG_LINES[@]}"

    echo
    echo "3) source your shell's config."

    unset MSG_LINES COMMAND
    return 1
fi


venvman_help_tag() {
    ${VENVMAN_UTILS_DIR}/messages/venvman_help_tag $@
}


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
            venvman_help_tag \
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
