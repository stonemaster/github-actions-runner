FROM ghcr.io/actions/actions-runner:latest

# Tools that are useful during Github action runs
ENV TOOLS="bzip2 unzip git"
ENV TOOLS="bzip2 unzip git coreutils"
ENV WORKDIR="/home/runner"
ENV USER="runner"

USER root

RUN apt-get update && \
	apt-get install -y ${TOOLS} && \
	rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

ADD entrypoint.sh /home/runner/
RUN chmod +x /home/runner/entrypoint.sh

USER ${USER}
WORKDIR ${WORKDIR}

ENTRYPOINT [ "/home/runner/entrypoint.sh" ]
