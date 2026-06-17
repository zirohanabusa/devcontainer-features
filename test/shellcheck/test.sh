#!/bin/bash
set -eu

cd "$(dirname "$0")"
source dev-container-features-test-lib

# Template specific tests
check "copied" [ -f "/usr/local/bin/shellcheck" ]
check "executable" [ -x "/usr/local/bin/shellcheck" ]
check "version" /usr/local/bin/shellcheck --version

# Report result
reportResults
