# Customized github-actions-runner Docker Image

Based on the [official Docker image of Github's action runner](https://github.com/actions/runner/pkgs/container/actions-runner),
this Docker image provides an easy way spin up a self-hosted Github Action
Runner.

## Example `docker-compose.yml`

```yaml
version: '3.6'

services:
  github-runner:
    image: ghcr.io/stonemaster/github-actions-runner:main
    container_name: githubrunner
    restart: always
    environment:
      - GITHUB_REPO_URL=https://github.com/stonemaster/github-actions-runner
      - RUNNER_TOKEN=
```

## Environment variables

### `GITHUB_REPO_URL` (required)

*Example*: `https://github.com/stonemaster/github-actions-runner`

The *https* URL of the GitHub repository.

### `RUNNER_TOKEN` (required)

The runner token as provided by the Github configuration on the *new self-hosted
runner* configuration page on Github.com.
