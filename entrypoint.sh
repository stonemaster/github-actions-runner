#!/bin/bash

set -eu -o pipefail

# Configuration
./config.sh --url ${GITHUB_REPO_URL} --token ${RUNNER_TOKEN}

./run.sh
