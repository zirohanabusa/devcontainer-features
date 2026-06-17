#!/bin/bash
set -eu

cd "$(dirname "$0")"
source dev-container-features-test-lib

# Template specific tests
check "copied" [ -f "/usr/local/bin/shfmt" ]
check "executable" [ -x "/usr/local/bin/shfmt" ]
check "version" /usr/local/bin/shfmt --version

# Report result
reportResults
