# A simple venv maneger. There is one bit of user configuration which is setting
# the VENV_DIR variable in the first line of the function
# This tool will ...
# 1) make venv's with -m and store then in the VENV_DIR location.
# 2) activate venvs with -a
# 3) deactivate with -da 
# 4) go to the site packages within the venv with -sp
# 5) go to a specific foler in the site packages with -sp <packagename>
# 6) list all available venv's with ls 

function venv() {
    VENV_DIR="$HOME/.venv"
    DEFAULT_REQ_FILE="requirements.txt"
    REQ_FILE="$DEFAULT_REQ_FILE"

    # Check the number of arguments passed
    if [[ $# -lt 1 ]]; then
        echo "Usage: venv <option> [argument]"
        echo "Use 'venv -h' or 'venv --help' for a list of available options."
        return 1
    fi

    # Check the first argument to determine the action
    case $1 in

        -m|--make)
            if [[ $# -ne 2 ]]; then
                echo "Usage: venv -m/--make <venv_name>"
                return 1
            fi
            python3 -m venv "$VENV_DIR/$2"
            # Check the return status of the last command
            if [[ $? -ne 0 ]]; then
                echo "Error: Failed to create virtual environment. Ensure the venv module is installed for Python3."
                return 1
            fi
            echo "Virtual environment '$2' successfully created in $VENV_DIR/$2"
            ;;

        -a|--activate)
            if [[ $# -ne 2 ]]; then
                echo "Usage: venv -a/--activate <venv_name>"
                return 1
            fi
            if [[ -d "$VENV_DIR/$2" ]]; then
                source "$VENV_DIR/$2/bin/activate"
            else
                echo "Error: Virtual environment '$2' does not exist in $VENV_DIR"
            fi
            ;;

        -sp|--site-packages)
            SITE_PACKAGES_DIR=$(pip show pip | grep Location | awk '{print $2}')

            if [[ ! $SITE_PACKAGES_DIR ]]; then
                echo "Error: pip is not installed or the location cannot be determined"
                return 1
            fi

            if [[ $# -eq 1 ]]; then
                cd "$SITE_PACKAGES_DIR"
            elif [[ $# -eq 2 ]]; then
                if [[ -d "$SITE_PACKAGES_DIR/$2" ]]; then
                    cd "$SITE_PACKAGES_DIR/$2"
                else
                    echo "Error: Package '$2' does not exist in $SITE_PACKAGES_DIR"
                    return 1
                fi
            else
                echo "Usage: venv -sp/--site-package-location [package_name]"
                return 1
            fi
            ;;

        -da|--deactivate)
            if [[ -z "$VIRTUAL_ENV" ]]; then
                echo "No virtual environment is currently activated."
                return 1
            fi
            deactivate
            ;;

        -ls|--list-all-environments)
            echo "Available virtual environments:"
            if [[ -d "$VENV_DIR" ]]; then
                ls "$VENV_DIR"
            else
                echo "No virtual environments found in $VENV_DIR"
            fi
            ;;

        -del|--delete-venv)
            if [[ $# -ne 2 ]]; then
                echo "Usage: venv -del/--delete-venv <venv_name>"
                return 1
            fi
            if [[ ! -d "$VENV_DIR/$2" ]]; then
                echo "Error: Virtual environment '$2' does not exist in $VENV_DIR"
                return 1
            fi
            read -p "Are you sure you want to delete virtual environment '$2'? [y/N]: " response
            if [[ "$response" =~ ^[Yy]$ ]]; then
                rm -rf "$VENV_DIR/$2"
                echo "Virtual environment '$2' has been deleted."
            else
                echo "Deletion cancelled."
            fi
            ;;

        -req|--make-req)
            if [[ $# -gt 2 ]]; then
                echo "Usage: venv -req/--make-req [output_file]"
                return 1
            fi
            if [[ $# -eq 2 ]]; then
                REQ_FILE="$2"
            fi
            echo "Creating $REQ_FILE with pip freeze..."
            pip freeze > "$REQ_FILE"
            echo "$REQ_FILE created with the current Python environment's packages."
            ;;


        -h|--help)
            echo "Usage: venv <option> [argument]"
            echo "Options:"
            echo "  -m, --make <venv_name>                : Create a new virtual environment."
            echo "  -a, --activate <venv_name>            : Activate the specified virtual environment."
            echo "  -sp, --site-packages [package]: Navigate to the site-packages directory or specified package directory."
            echo "  -da, --deactivate                     : Deactivate the currently active virtual environment."
            echo "  -ls, --list-all-environments          : List all available virtual environments in $VENV_DIR."
            echo "  -del, --delete-venv                   : Delete the specified venv."
            echo "  -req, --make-req                      : Make a requirements.txt file to CWD"
            echo "  -h, --help                            : Display this help message."
            ;;

        *)
            echo "Invalid option. Use 'venv -h' or 'venv --help' for a list of available options."
            return 1
            ;;
    esac
}
