# Observability Lab: Kong

Click this to open the environment:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/dynatrace-perfclinics/obslab-kong)

## Debugging

* The environment is created based on the template in `.devcontainer/devcontainer.json`
* As you may have spotted in `devcontainer.json`, when the container starts, `.devcontainer/post-start.sh` is executed (put your install logic here)
* The OpenTelemetry demo is installed in the `default` namespace (pods usually take ~5mins to spin up)
* Kong control plane and data plane are installed in the `kong` namespace.

### Creation Log

If things go wrong, go to `View > Command Palette` and search for `creation log`. This will show you anythign that goes wrong with `.devcontainer/post-start.sh`

### Opening Ports

To open ports, you need to do all of the following:

* Open up the port into the codespace. Do this by specifying it in `.devcontainer/devcontainer.json`
* Open the port to the kind cluster. Modify `.devcontainer/kind-cluster.yaml`
* Rebuild the codespace: `View > Command Palette` and search for rebuild or just go to `https://github.com/codespaces` and delete the codespace. Then recreate.