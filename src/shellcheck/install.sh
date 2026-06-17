#!/bin/bash
set -euo pipefail

USERNAME=${USERNAME:-${_REMOTE_USER:-"automatic"}}
SHELLCHECK_VERSION=${SHELLCHECK_VERSION:-"latest"}

# The install.sh script is the installation entrypoint for any dev container 'features' in this repository. 
#
# The tooling will parse the devcontainer-features.json + user devcontainer, and write 
# any build-time arguments into a feature-set scoped "devcontainer-features.env"
# The author is free to source that file and use it however they would like.
set -a
. ./devcontainer-features.env
set +a

REPO_OWNER="koalaman"
REPO_NAME="shellcheck"
CMD_NAME="shellcheck"
ARCH="$(uname -m)"
case ${ARCH} in
    x86_64) ARCH="x86_64";;
    aarch64 | armv8*) ARCH="aarch64";;
    riscv64) ARCH="riscv64";;
    *) echo "(!) Architecture ${ARCH} unsupported"; exit 1 ;;
esac

RELEASES_LATEST_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
(
  : \
  && apt-get update \
  && apt-get install -y --no-install-recommends coreutils ca-certificates curl jq tar xz-utils \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && TMP_WORK_DIR=$(mktemp -d) \
  && cd "$TMP_WORK_DIR" \
  && JSON_STRING=$(curl -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2026-03-10" -LSs "$RELEASES_LATEST_URL") \
  && LATEST_ITEM=$(echo "$JSON_STRING" | jq -r ".assets[] | select(.name | contains(\".linux.${ARCH}.tar.xz\"))") \
  && DOWNLOAD_URL=$(echo "$LATEST_ITEM" | jq -r ".browser_download_url") \
  && DIGEST=$(echo "$LATEST_ITEM" | jq -r '.digest |= sub("sha256:"; "") | .digest') \
  && curl -LSs -o archive.tar.xz "$DOWNLOAD_URL" \
  && echo "${DIGEST}  archive.tar.xz" > checksums.txt \
  && sha256sum -c checksums.txt \
  && tar xfv archive.tar.xz \
  && chmod +x shellcheck-v*/shellcheck \
  && mv shellcheck-v*/shellcheck /usr/local/bin/ \
  && cd - \
  && rm -rf "$TMP_WORK_DIR"
) || exit -1
