#!/bin/bash

set -e -o pipefail

# store local variables and clean environment variables to make sure to not
# expose more information than necessary.
workdir=${WORKDIR}
unset WORKDIR
shutdown_runner_script=${SHUTDOWN_RUNNER_SCRIPT}
unset SHUTDOWN_RUNNER_SCRIPT
pre_job_script=${PRE_JOB_SCRIPT}
unset PRE_JOB_SCRIPT
post_job_script=${POST_JOB_SCRIPT}
unset POST_JOB_SCRIPT
github_repo_url=${GITHUB_REPO_URL}
unset GITHUB_REPO_URL

function get_registration_token {
  repo=${github_repo_url#https://github.com/}

  # Determine if this is an organization or repository URL
  # Organization URLs typically have format: https://github.com/ORG
  # Repository URLs have format: https://github.com/OWNER/REPO
  if [[ "$repo" == *"/"* ]]; then
    # Contains a slash, so it's a repository
    api_url="https://api.github.com/repos/${repo}/actions/runners/registration-token"
  else
    # No slash, so it's an organization
    api_url="https://api.github.com/orgs/${repo}/actions/runners/registration-token"
  fi

  if [ -z "${RUNNER_TOKEN}" ]; then
    curl -X POST -H "Authorization: token ${GITHUB_REGISTRATION_TOKEN}" \
      -H "Accept: application/vnd.github+json" \
      "${api_url}" | jq .token --raw-output
  else
    echo "${RUNNER_TOKEN}"
  fi
}

registration_token=$(get_registration_token)
unset RUNNER_TOKEN
unset GITHUB_REGISTRATION_TOKEN

function cleanup {
  # Disconnect runner from GitHub
  ./config.sh remove --token "${registration_token}" || true

  # If specfied, run shutdown script.
  if [ ! -z "${shutdown_runner_script}" ]; then
    exec echo "${shutdown_runner_script}" | base64 -d | bash -
  fi
}

function prepare_script {
  local filename="${1}"
  local env="${2}"
  local base64_contents="${3}"

  local script_path="${workdir}/${filename}"
  if [ ! -z "${base64_contents:-}" ] && [ ! -f "${script_path}" ]; then
    echo "${base64_contents}" | base64 -d >"${script_path}"
    chmod 0500 "${script_path}"
    export ${env}=${script_path}
  fi
}

# Setup pre- and post scripts in case they have been set.
prepare_script "pre-script.sh" "ACTIONS_RUNNER_HOOK_JOB_STARTED" "${pre_job_script}"
prepare_script "post-script.sh" "ACTIONS_RUNNER_HOOK_JOB_COMPLETED" "${post_job_script}"

# Configuration; also replace existing runner with the same name.
if [ ! -f .runner ]; then
  ./config.sh --unattended --url "${github_repo_url}" --token "${registration_token}" --replace
else
  echo "Runner already configured - re-using existing configuration"
fi

trap cleanup EXIT

./run.sh
