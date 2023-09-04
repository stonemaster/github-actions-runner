#!/bin/bash

set -eu -o pipefail

function cleanup {
	# Disconnect runner from GitHub
	./config.sh remove --token ${RUNNER_TOKEN}

	# If specfied, run shutdown script.
	if [ ! -z "${SHUTDOWN_RUNNER_SCRIPT}" ]; then
		shutdown_script="${WORKDIR}/shutdown.sh"
		echo ${SHUTDOWN_RUNNER_SCRIPT} | base64 -d > ${shutdown_script}
		chmod +x ${shutdown_script}
		exec ${shutdown_script}
	fi
}

# Setup pre- and post scripts in case they have been set.
if [ ! -z "${PRE_JOB_SCRIPT:-}" ]; then
	pre_script_path="${WORKDIR}/pre-script.sh"
	echo ${PRE_JOB_SCRIPT} | base64 -d > ${pre_script_path}
	chmod +x ${pre_script_path}
	export ACTIONS_RUNNER_HOOK_JOB_STARTED=${pre_script_path}
fi

if [ ! -z "${POST_JOB_SCRIPT:-}" ]; then
	post_script_path="${WORKDIR}/post-script.sh"
	echo ${PRE_JOB_SCRIPT} | base64 -d > ${post_script_path}
	chmod +x ${post_script_path}
	export ACTIONS_RUNNER_HOOK_JOB_STARTED=${post_script_path}
fi

# Configuration
./config.sh --url ${GITHUB_REPO_URL} --token ${RUNNER_TOKEN}

trap cleanup EXIT

./run.sh
