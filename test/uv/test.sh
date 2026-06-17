#!/bin/bash
set -eu

cd "$(dirname "$0")"
source dev-container-features-test-lib

# Template specific tests
check "copied" [ -f "/usr/local/bin/uv" -a -f "/usr/local/bin/uvx" ]
check "executable" [ -x "/usr/local/bin/uv" -a -x "/usr/local/bin/uvx" ]
check "version" /usr/local/bin/uv --version

# Report result
reportResults
