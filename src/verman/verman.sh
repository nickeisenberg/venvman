verman() {
    while [ "${#@}" -gt 0 ]; do
        case "$1" in
            install)
                echo "not implemented"
                return 1
                ;;
            check)
                echo "not implemented"
                return 1
                ;;
            *)
                echo "invalid option"
                return 1
                ;;
        esac
    done
}
