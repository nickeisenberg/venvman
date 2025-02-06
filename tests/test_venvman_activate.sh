#!/usr/bin/env bash

set -e

VENVMAN_ROOT_DIR=$HOME/.venvman
VENVMAN_ENVS_DIR=$HOME/.venvman/envs
source /home/nicholas/.venvman/venvman/src/venvman.sh
source /home/nicholas/.venvman/venvman/src/completion/completion.sh

echo "Running venvman activate test..."

echo "Creating virtual environment..."
venvman make -n test_env -v 3.11

if [[ ! -d $VENVMAN_ENVS_DIR/3.11/test_env ]]; then
    echo "venvman make: Fail"
    exit 1
fi

echo "🚀 Activating virtual environment..."
venvman activate -n test_env -v 3.11
if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "venvman make: SUCCESS"
    echo "venvman activate: SUCCESS"
else
    echo "venvman make: Fail"
    echo "venvman activate: FAILED"
    exit 1
fi

echo "🧹 Cleaning up test environment..."
echo "y" | venvman delete -n test_env -v 3.11
if [[ -d $VENVMAN_ENVS_DIR/3.11/test_env ]]; then
    echo "venvman delete: Fail"
    exit 1
fi
echo "venvman delete: SUCCESS"

echo "🎉 All tests passed!"
