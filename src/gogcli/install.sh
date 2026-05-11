#!/bin/bash
set -eu

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
GOGVERSION="${GOGVERSION:-latest}"

# The install.sh script is the installation entrypoint for any dev container 'features' in this repository. 
#
# The tooling will parse the devcontainer-features.json + user devcontainer, and write 
# any build-time arguments into a feature-set scoped "devcontainer-features.env"
# The author is free to source that file and use it however they would like.
set -a
. ./devcontainer-features.env
set +a

ARCH="$(uname -m)"
case ${ARCH} in
    x86_64) ARCH="amd64";;
    aarch64 | armv8*) ARCH="arm64";;
    *) echo "(!) Architecture ${ARCH} unsupported"; exit 1 ;;
esac

case ${GOGVERSION} in
    latest) GOGVERSION="0.16.0" ;;
    0.16.0 | 0.15.0 | 0.14.0 | 0.13.0 | 0.12.0 | 0.11.0 | 0.10.0 | 0.9.0 | 0.8.0 | 0.7.0) : ;;
    *) echo "(!) Unknown gog version ${GOGVERSION}"; exit 1;;
esac

WORK_DIR="gogcli_${GOGVERSION}_linux_${ARCH}"
ARCHIVE_FILENAME="${WORK_DIR}.tar.gz"
DOWNLOAD_URL="https://github.com/openclaw/gogcli/releases/download/v${GOGVERSION}/${ARCHIVE_FILENAME}"
TMP_WORK_DIR=$(mktemp -d)
(
  : \
  && apt-get update \
  && apt-get install -y ca-certificates curl tar gzip \
  && rm -rf /var/lib/apt/lists/* \
  && cd "$TMP_WORK_DIR" \
  && curl -LO "$DOWNLOAD_URL" \
  && tar xvfz "$ARCHIVE_FILENAME" \
  && chmod +x gog \
  && mv gog /usr/local/bin/ \
  && cd - \
  && rm -rf "$TMP_WORK_DIR";
) || exit -1
