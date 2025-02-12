VENVMAN_PYTHON_DIR=${VENVMAN_ROOT_DIR}/python/cpython
VENVMAN_PYTHON_VERSIONS_DIR=${VENVMAN_ROOT_DIR}/python/versions


install_python_subversion() {
    MY_PWD="$(pwd)"
    VERSION="$1"

    if ! command -v python${VERSION} &>/dev/null; then
        echo "python${VERSION} is not available on your system."
        printf "Would you like to search https://github.com/python/cpython for availability? [Y/n]: "
        read -r response
    fi

    case "$response" in
        Y|y)
            ;;
        *)
            echo "Exiting the install."
            cd $MY_PWD && return 1
            ;;
    esac

    if [ ! -d "$VENVMAN_PYTHON_DIR" ]; then
        echo "The repo https://github.com/python/cpython was not found at ${VENVMAN_PYTHON_DIR}."
        echo "To continue, it must be cloned to that location."
        printf "Would you like to clone the repo and continue now? [Y/n]: "
        read -r response
        case "$response" in
            Y|y)
                mkdir -p ${VENVMAN_PYTHON_DIR}
                git clone https://github.com/python/cpython.git ${VENVMAN_PYTHON_DIR}
                mkdir -p ${VENVMAN_PYTHON_VERSIONS_DIR}
                ;;
            *)
                echo "Exiting the install."
                cd $MY_PWD && return 1
                ;;
        esac

    fi

    cd $VENVMAN_PYTHON_DIR || return 1
    git checkout main
    git reset --hard origin/main > /dev/null
    git fetch --all > /dev/null

    FOUND=$(git tag | grep $VERSION)
    if [ -z $FOUND ]; then
        echo "$VESION not found." >&2
        echo "Please see https://github.com/python/cpython for available versions." >&2
        cd $MY_PWD
        return 1
    fi

    echo "$VERSION is available."
    printf "Do you want to continue and configure the install? [Y/n]: "
    read -r response
    case "$response" in
        Y|y)
            ;;
        *)
            echo "Exiting the install."
            cd $MY_PWD && return 1
            ;;
    esac

    git checkout "v$VERSION" || return 1
    ./configure --prefix="${VENVMAN_PYTHON_VERSIONS_DIR}/${VERSION}" || return 1
    
    if [ $(command -v nproc &> /dev/null) ]; then
        make -j$(nproc) || cd $MY_PWD && return 1
    else
        make || cd $MY_PWD return 1
    fi

    echo "The Makefile has been created."
    printf "Would you like to continue the install? [Y/n]: "
    read -r response
    case "$response" in
        Y|y)
            ;;
        *)
            echo "Exiting the install."
            cd $MY_PWD && return 1
            ;;
    esac
    
    make install
    if [ "$?" -gt 0 ]; then
        echo "make install fail" >&2
        return 1
    fi
}


get_python_subversion_bin_path() {
    VERSION=$1
    VERSION_PARTS=$(echo "${VERSION}" | tr '.' ' ')
    if [ $(echo "$VERSION_PARTS" | wc -w) != 3 ]; then
        return 1
    fi
    VERSION_MAJOR=$(echo "$VERSION_PARTS" | awk "{print \$1}")
    VERSION_MINOR=$(echo "$VERSION_PARTS" | awk "{print \$2}")
     
    BINARY_PATHS=$(\
        find ${VENVMAN_PYTHON_VERSIONS_DIR}/${VERSION} \
            -type f \
            -executable \
            -name "python${VERSION_MAJOR}.${VERSION_MINOR}" \
    )
    BINARY_PATH_FOUND=""
    for BINARY_PATH in $BINARY_PATHS; do
        BINARY_PATH_FOUND=$BINARY_PATH
        break
    done
    if [ -n "$BINARY_PATH_FOUND" ]; then
        echo $BINARY_PATH_FOUND
    else
        echo "binary for python${VERSION} was not found" >&2
        return 1
    fi
}
