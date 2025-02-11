_venvman_err_msg_missing_option_value() {(
    COMMAND=$1
    INPUT_OPTION_TYPE=$2
    GIVE_USAGE=$3

    if [ -z "$GIVE_USAGE" ]; then
        GIVE_USAGE="true"
    fi

    echo "ERROR: Enter a value for ${INPUT_OPTION_TYPE}." >&2
    echo "See 'venvman ${COMMAND} --help' for usage." >&2
)}


_venvman_err_msg_missing_options() {(
    MISSING_VALUE="$1"
    COMMAND="$2"
    shift 2
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --options)
                OPTIONS="$2"
                shift 2
                ;;
            --inputs)
                INPUTS="$2"
                shift 2
                ;;
            *)
                return 1
                ;;
        esac
    done

    NUM_OPTIONS=$(echo "$OPTIONS" | wc -w)
    NUM_INPUTS=$(echo "$INPUTS" | wc -w)

    if [ "$NUM_INPUTS" -gt "$NUM_OPTIONS" ]; then
        return 1
    fi

    MISSING=false
    i=1
    while [ "$i" -le "$NUM_OPTIONS" ]; do
        INPUT=$(echo "$INPUTS" | awk "{print \$$i}")
        OPTION=$(echo "$OPTIONS" | awk "{print \$$i}")
        
        if [ "$INPUT" = "$MISSING_VALUE" ]; then
            MISSING=true
            echo "ERROR: Enter a value for ${OPTION}."
        fi
        i=$((i + 1))  # Increment i
    done


    if [ "$MISSING" = true ]; then
        echo "See 'venvman $COMMAND --help' for usage." >&2
        return 1
    fi
)}


_venvman_err_msg_invalid_option() {(
    COMMAND=$1
    INPUTED_OPTION=$2
    echo "ERROR: Invalid option '${2}'" >&2
    echo "See 'venvman ${COMMAND} --help' for usage." >&2
)}


_venvman_help_tag() {
    COMMANDS=""
    COMMANDS_LENS=""
    COMMANDS_MAX_LEN=0
    COMMANDS_DESCRIPTIONS=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --commands)
                shift
                while [ "$#" -gt 0 ] && [ "${1}" != "--commands-descriptions" ]; do
                    COMMANDS="${COMMANDS}\n  $1"
                    len=$(echo "$1" | wc -c)
                    COMMANDS_LENS="${COMMANDS_LENS} $len"
                    if [ $len -ge $COMMANDS_MAX_LEN ]; then
                        COMMANDS_MAX_LEN="$len"
                    fi
                    shift
                done
                ;;
            --commands-descriptions)
                shift
                i=1
                while [ "$#" -gt 0 ] && [ "${1}" != "--examples" ]; do
                    len=$(echo "$COMMANDS_LENS" | awk -v i="$i" '{print $i}')
                    delta=$(( $COMMANDS_MAX_LEN - $len ))
                    spaces=$(printf '%*s' "$delta" '')
                    COMMANDS_DESCRIPTIONS="${COMMANDS_DESCRIPTIONS}\n$spaces : $1"
                    i=$((i + 1))
                    shift
                done
                ;;
            *)
                return 1
                ;;
        esac
    done

    # Print the help message
    echo "Commands:"
    paste -d ' ' <(echo -e "$COMMANDS") <(echo -e "$COMMANDS_DESCRIPTIONS")
    echo
    echo "Usage:"
    echo "  See \`venvman <command> --help\` for usage of each command."
}


_venvman_command_help_tag() {
    COMMAND=$1
    shift

    OPTIONS=""
    OPTIONS_LENS=""
    OPTIONS_MAX_LEN=0
    OPTIONS_DESCRIPTIONS=""

    EXAMPLES=""
    EXAMPLES_LENS=""
    EXAMPLES_MAX_LEN=0
    EXAMPLES_DESCRIPTIONS=""

    while [ "$#" -gt 0 ]; do
        case "$1" in
            --options)
                shift
                while [ "$#" -gt 0 ] && [ "${1}" != "--option-descriptions" ]; do
                    OPTIONS="${OPTIONS}\n  $1"
                    len=$(echo "$1" | wc -c)
                    OPTIONS_LENS="${OPTIONS_LENS} $len"
                    if [ $len -ge $OPTIONS_MAX_LEN ]; then
                        OPTIONS_MAX_LEN="$len"
                    fi
                    shift
                done
                ;;
            --option-descriptions)
                shift
                i=1
                while [ "$#" -gt 0 ] && [ "${1}" != "--examples" ]; do
                    len=$(echo "$OPTIONS_LENS" | awk -v i="$i" '{print $i}')
                    delta=$(( $OPTIONS_MAX_LEN - $len ))
                    spaces=$(printf '%*s' "$delta" '')
                    OPTIONS_DESCRIPTIONS="${OPTIONS_DESCRIPTIONS}\n$spaces : $1"
                    i=$((i + 1))
                    shift
                done
                ;;
            --examples)
                shift
                while [ "$#" -gt 0 ] && [ "${1}" != "--example-descriptions" ]; do
                    EXAMPLES="${EXAMPLES}\n  $1"
                    len=$(echo "$1" | wc -c)
                    EXAMPLES_LENS="${EXAMPLES_LENS} $len"
                    if [ "$len" -ge $EXAMPLES_MAX_LEN ]; then
                        EXAMPLES_MAX_LEN="$len"
                    fi
                    shift
                done
                ;;
            --example-descriptions)
                shift
                i=1
                while [ "$#" -gt 0 ] && [ "${1#--}" = "$1" ]; do
                    len=$(echo "$EXAMPLES_LENS" | awk -v i="$i" '{print $i}')
                    delta=$(( $EXAMPLES_MAX_LEN - $len ))
                    spaces=$(printf '%*s' "$delta" '')
                    EXAMPLES_DESCRIPTIONS="${EXAMPLES_DESCRIPTIONS}\n$spaces : $1"
                    i=$((i + 1))
                    shift
                done
                ;;
            *)
                return 1
                ;;
        esac
    done

    # Print the help message
    echo "Usage:"
    echo "  venvman $COMMAND [options]"
    echo
    echo "Options:"
    paste -d ' ' <(echo -e "$OPTIONS") <(echo -e "$OPTIONS_DESCRIPTIONS")
    echo
    echo "Examples:"
    paste -d ' ' <(echo -e "$EXAMPLES") <(echo -e "$EXAMPLES_DESCRIPTIONS")
}
