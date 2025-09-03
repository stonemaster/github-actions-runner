#!/bin/bash

set -e -o pipefail

# store local variables and clean environment variables to make sure to not
# expose more information than necessary.
workdir=${WORKDIR}
unset WORKDIR
runner_token=${RUNNER_TOKEN}
unset RUNNER_TOKEN
shutdown_runner_script=${SHUTDOWN_RUNNER_SCRIPT}
unset SHUTDOWN_RUNNER_SCRIPT
pre_job_script=${PRE_JOB_SCRIPT}
unset PRE_JOB_SCRIPT
post_job_script=${POST_JOB_SCRIPT}
unset POST_JOB_SCRIPT
github_repo_url=${GITHUB_REPO_URL}
unset GITHUB_REPO_URL

function cleanup {
	# Disconnect runner from GitHub
	./config.sh remove --token "${runner_token}"

	# If specfied, run shutdown script.
	if [ ! -z "${shutdown_runner_script}" ]; then
		exec echo "${shutdown_runner_script}" | base64 -d | bash -
	fi
}

function prepare_script {
	local filename="${1}"
	local env="${2}"
	local base64_contents="${3}"

	if [ ! -z "${base64_contents:-}" ]; then
		script_path="${workdir}/${filename}"
		echo "${base64_contents}" | base64 -d > "${script_path}"
		chmod 0500 "${script_path}"
		export ${env}=${script_path}
	fi
}

# Setup pre- and post scripts in case they have been set.
prepare_script "pre-script.sh" "ACTIONS_RUNNER_HOOK_JOB_STARTED" "${pre_job_script}"
prepare_script "post-script.sh" "ACTIONS_RUNNER_HOOK_JOB_COMPLETED" "${post_job_script}"

# Configuration; also replace existing runner with the same name.
./config.sh remove || true
./config.sh --url "${github_repo_url}" --token "${runner_token}"

trap cleanup EXIT

./run.sh
