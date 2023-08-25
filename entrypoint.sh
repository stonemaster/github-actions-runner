#!/bin/bash

set -eu -o pipefail

function disconnect {
	./config.sh remove --token ${RUNNER_TOKEN}
}

# Configuration
./config.sh --url ${GITHUB_REPO_URL} --token ${RUNNER_TOKEN}

trap disconnect EXIT

./run.sh
