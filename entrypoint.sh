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
	./config.sh remove --token ${runner_token}

	# If specfied, run shutdown script.
	if [ ! -z "${shutdown_runner_script}" ]; then
		shutdown_script="${workdir}/shutdown.sh"
		echo ${shutdown_runner_script} | base64 -d > ${shutdown_script}
		chmod +x ${shutdown_script}
		exec ${shutdown_script}
	fi
}

# Setup pre- and post scripts in case they have been set.
if [ ! -z "${pre_job_script:-}" ]; then
	pre_script_path="${workdir}/pre-script.sh"
	echo ${pre_job_script} | base64 -d > ${pre_script_path}
	chmod +x ${pre_script_path}
	export ACTIONS_RUNNER_HOOK_JOB_STARTED=${pre_script_path}
fi

if [ ! -z "${post_job_script:-}" ]; then
	post_script_path="${workdir}/post-script.sh"
	echo ${post_job_script} | base64 -d > ${post_script_path}
	chmod +x ${post_script_path}
	export ACTIONS_RUNNER_HOOK_JOB_STARTED=${post_script_path}
fi

# Configuration
./config.sh --url ${github_repo_url} --token ${runner_token}

trap cleanup EXIT

./run.sh
