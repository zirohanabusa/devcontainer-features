#!/bin/bash
set -eu

cd "$(dirname "$0")"
source dev-container-features-test-lib

# Template specific tests
check "copied" [ -f "/usr/local/bin/gog" ]
check "executable" [ -x "/usr/local/bin/gog" ]
check "version" /usr/local/bin/gog --version

# Report result
reportResults
