#!/usr/bin/env bash

set -e

echo "Running venvman activate test..."

echo "Creating virtual environment..."
venvman make -n test_env -v 3.11

echo "🚀 Activating virtual environment..."
venvman activate -n test_env -v 3.11

if [[ -n "$VIRTUAL_ENV" ]]; then
    echo "venvman activate: SUCCESS"
else
    echo "venvman activate: FAILED"
    exit 1
fi

echo "🧹 Cleaning up test environment..."
venvman delete -n test_env -v 3.11

echo "🎉 All tests passed!"
