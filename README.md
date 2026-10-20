# Demo

1. Intro
2. Overview
3. The Go Program And The Dev. Environment
   1. `./go_http_endpoint/main.go`
   2. `./.devcontainer/devcontainer.json`
4. The Dockerfile That Builds The Go Program And Creates The Image
   1. `./go_http_endpoint/http_endpoint.dockerfile`
5. The Workflow
   - `./.github/workflows/docker-image.yml`
   1. Building And Testing
      1. Building
      2. Testing
         1. Liatrio Github Action
            - Current Non-Working Commit:
               - https://github.com/liatrio/github-actions/blob/7208146c9ce4749b4ff44ff8030d953a578fa209/apprentice-action/tests/endpoint.test.js
            - Previous Working Commit: 
              - https://github.com/liatrio/github-actions/blob/0b41561cca6822cc8d880fe0e49e7807a41fdf91/apprentice-action/tests/endpoint.test.js
         2. My minification test
            - `./tests/minified.test.mjs`
   2. Deployment To Google Cloud
      1. `gcp-setup.sh`
      2. The `deploy` job in the workflow.