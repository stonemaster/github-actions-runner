#!/bin/bash

set -e -o pipefail

# remap docker group permissions
if [ -e /var/run/docker.sock ]; then
  echo "Remapping /var/run/docker.sock permissions."
  chgrp docker /var/run/docker.sock
fi

echo "Changing to user '${USER}'."
gosu "${USER}" ./runner.sh
