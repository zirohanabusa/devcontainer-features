ARG NODE_VERSION=24
ARG CODENAME=bookworm
ARG TAG=${NODE_VERSION}-${CODENAME}
ARG USERNAME=node
ARG USERHOME=/home/${USERNAME}
ARG COMPLETIONS=${USERHOME}/.local/share/bash-completion/completions
FROM mcr.microsoft.com/devcontainers/javascript-node:${TAG}
ARG USERNAME COMPLETIONS USERHOME
SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]
# hadolint ignore=SC2086
RUN : \
  && mkdir -p ${COMPLETIONS} \
  && node --completion-bash >> "${COMPLETIONS}/node" \
  && npm completion >> "${COMPLETIONS}/npm" \
  && ( \
    echo 'alias ..="cd .."'; \
    echo 'alias ll="ls -ahlF --color=auto"'; \
  ) >> ${USERHOME}/.bash_aliases \
  && chown -R ${USERNAME} ${USERHOME}
