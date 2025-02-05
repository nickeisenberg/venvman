try_profile() {
  if [ -z "${1-}" ] || [ ! -f "${1}" ]; then
    return 1
  fi
  echo "${1}"
}

detect_profile() {
  if [ "${PROFILE-}" = '/dev/null' ]; then
    # the user has specifically requested NOT to have nvm touch their profile
    return
  fi

  if [ -n "${PROFILE}" ] && [ -f "${PROFILE}" ]; then
    echo "${PROFILE}"
    return
  fi

  local DETECTED_PROFILE
  DETECTED_PROFILE=''

  if [ -n "${BASH_VERSION-}" ]; then
    if [ -f "$HOME/.bashrc" ]; then
      DETECTED_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.bash_profile" ]; then
      DETECTED_PROFILE="$HOME/.bash_profile"
    fi
  elif [ -n "${ZSH_VERSION-}" ]; then
    DETECTED_PROFILE="$HOME/.zshrc"
  fi

  if [ -z "$DETECTED_PROFILE" ]; then
    for EACH_PROFILE in ".profile" ".bashrc" ".bash_profile" ".zshrc"
    do
      if DETECTED_PROFILE="$(try_profile "${HOME}/${EACH_PROFILE}")"; then
        break
      fi
    done
  fi

  if [ -n "$DETECTED_PROFILE" ]; then
    echo "$DETECTED_PROFILE"
  fi
}

DETECTED_PROFILE=$(detect_profile)

VENVMAN_ROOT_DIR=$HOME/.venvman
VENVMAN_ENVS_DIR=$HOME/.venvman/envs

[[ ! -d $VENVMAN_ROOT_DIR ]] && mkdir -p $VENVMAN_ROOT_DIR || \
    echo "$VENVMAN_ROOT_DIR already exists. This may be a mistake." return 1

git clone https://github.com/nickeisenberg/venvman.git $VENVMAN_ROOT_DIR
source $VENVMAN_ROOT_DIR/venvman/src/venvman.sh
source $VENVMAN_ROOT_DIR/venvman/src/completion/completion.sh  # adds completion is available for your shell

echo | tee -a $DETECTED_PROFILE
echo "VENVMAN_ROOT_DIR=$HOME/.venvman # there the repo will be cloned to" | tee -a $DETECTED_PROFILE
echo "VENVMAN_ENVS_DIR=$HOME/.venvman/envs  # where the virtual enviornments will be saved to" | tee -a $DETECTED_PROFILE 
echo "source $VENVMAN_ROOT_DIR/venvman/src/venvman.sh" | tee -a $DETECTED_PROFILE 
echo "source $VENVMAN_ROOT_DIR/venvman/src/completion/completion.sh  # adds completion is available for your shell" | tee -a $DETECTED_PROFILE 
