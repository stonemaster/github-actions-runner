# Customized github-actions-runner Docker Image

Based on the [official Docker image of Github's action runner](https://github.com/actions/runner/pkgs/container/actions-runner),
this Docker image provides an easy way spin up a self-hosted GitHub Action
Runner.

Upon shutdown the runner will automatically be disconnected from the GitHub
repository, per default.

## Example `docker-compose.yml`

```yaml
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

The *https* URL of the GitHub repository **or** that of a
GitHub organization.

### `RUNNER_TOKEN` or `GITHUB_REGISTRATION_TOKEN` (required)

- If `RUNNER_TOKEN` is set, it will be used as the registration token.
Those tokens expire and are best suited for short-lived runners.
The runner token can be fetched in GitHub settings on the *new self-hosted
runner* configuration page.
- If `GITHUB_REGISTRATION_TOKEN` is set, it will to fetch a new registration
token for this runner. A fine-grained personal access token (PAT) with the
**Self-hosted runners** `write` permission is required to use this option.
See the [official documentation](https://docs.github.com/en/rest/authentication/permissions-required-for-fine-grained-personal-access-tokens?apiVersion=2022-11-28#organization-permissions-for-self-hosted-runners).

> ![NOTE]
> `RUNNER_TOKEN` has precedence over `GITHUB_REGISTRATION_TOKEN` if both are set.

### `PRE_JOB_SCRIPT` and `POST_JOB_SCRIPT` (both optional)

These environment variables contain Base64 encoded scripts. If set they will be
run before starts and after a job has completed. As per the [offical
documentation](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/running-scripts-before-or-after-a-job#about-pre--and-post-job-scripts)
these scripts should be written in `bash` or `sh`. The container makes sure the
scripts are executable after decoding them.

Scripts can easily be converted into Base64 on the command-line and then used as
an environment variable:

```sh
$ cat script.sh
#!/bin/bash
echo "Hello World!"
$ base64 script.sh
IyEvYmluL2Jhc2gKZWNobyAiSGVsbG8gV29ybGQhIgo=
```

Add the Base64 string as an environment variable:

```yaml
  [...]
    environment:
      - RUNNER_TOKEN=123
      - PRE_JOB_SCRIPT=IyEvYmluL2Jhc2gKZWNobyAiSGVsbG8gV29ybGQhIgo=
  [...]
```

### `SHUTDOWN_RUNNER_SCRIPT` (optional)

Similar to the `PRE_JOB_SCRIPT` and `POST_JOB_SCRIPT` environment variables
this allows to specify a Base64-encoded script to be run at shutdown of the
runner. The script is run after disconnecting the runner from GitHub.
