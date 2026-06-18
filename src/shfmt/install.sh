#!/bin/bash
set -euo pipefail

USERNAME=${USERNAME:-${_REMOTE_USER:-"automatic"}}
SHFMT_VERSION=${SHFMT_VERSION:-"latest"}

# The install.sh script is the installation entrypoint for any dev container 'features' in this repository. 
#
# The tooling will parse the devcontainer-features.json + user devcontainer, and write 
# any build-time arguments into a feature-set scoped "devcontainer-features.env"
# The author is free to source that file and use it however they would like.
set -a
. ./devcontainer-features.env
set +a

REPO_OWNER="mvdan"
REPO_NAME="sh"
CMD_NAME="shfmt"
ARCH="$(uname -m)"
case ${ARCH} in
    i386 | i486 | i586 | i686) ARCH="386";;
    armv7l | armv8l) ARCH="arm";;
    x86_64) ARCH="amd64";;
    aarch64 | armv8*) ARCH="arm64";;
    *) echo "(!) Architecture ${ARCH} unsupported"; exit 1 ;;
esac

RELEASES_LATEST_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"
(
  : \
  && apt-get update \
  && apt-get install -y --no-install-recommends coreutils ca-certificates curl jq \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && TMP_WORK_DIR=$(mktemp -d) \
  && cd "$TMP_WORK_DIR" \
  && JSON_STRING=$(curl -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2026-03-10" -LSs "$RELEASES_LATEST_URL") \
  && LATEST_ITEM=$(echo "$JSON_STRING" | jq -r ".assets[] | select(.name | contains(\"_linux_${ARCH}\"))") \
  && DOWNLOAD_URL=$(echo "$LATEST_ITEM" | jq -r ".browser_download_url") \
  && DIGEST=$(echo "$LATEST_ITEM" | jq -r '.digest |= sub("sha256:"; "") | .digest') \
  && curl -LSs -o "$CMD_NAME" "$DOWNLOAD_URL" \
  && echo "${DIGEST}  ${CMD_NAME}" > checksums.txt \
  && sha256sum -c checksums.txt \
  && chmod +x $CMD_NAME \
  && mv $CMD_NAME /usr/local/bin/ \
  && cd - \
  && rm -rf "$TMP_WORK_DIR"
) || exit -1
