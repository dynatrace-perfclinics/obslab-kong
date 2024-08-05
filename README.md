# Observability Lab: Kong

Click this to open the environment:

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/dynatrace-perfclinics/obslab-kong)

## Debugging

* The environment is created based on the template in `.devcontainer/devcontainer.json`
* As you may have spotted in `devcontainer.json`, when the container starts, `.devcontainer/post-start.sh` is executed (put your install logic here)
* The OpenTelemetry demo is installed in the `default` namespace (pods usually take ~5mins to spin up)
* Kong control plane and data plane are installed in the `kong` namespace.

### Creation Log

If things go wrong, go to `View > Command Palette` and search for `creation log`. This will show you anything that goes wrong with `.devcontainer/post-start.sh`

### Opening Ports

To open ports, you need to do all of the following:

* Open up the port into the codespace. Do this by specifying it in `.devcontainer/devcontainer.json`
* Open the port to the kind cluster. Modify `.devcontainer/kind-cluster.yaml`
* Rebuild the codespace: `View > Command Palette` and search for rebuild or just go to `https://github.com/codespaces` and delete the codespace. Then recreate.

## Committing Changes

You can alter anything from within the codespace. Git is already configured so the usual `git add someFile.txt && git commit -m "update" && git push` will work.

> BE CAREFUL NOT TO COMMIT SENSITIVE DATA OR SECRETS BACK TO THE REPOSITORY!

## Making ports public

Codespaces are private (to your user since you're logged in) by default. You can open up ports for collaboration:

* Go to the ports tab
* Right click the entry, choose `port visibility` and choose public
* Right click the entry again and `copy local address` that URL is now public (but be careful who you share that with!)

You can also do this programatically. For example, this command would set the visibility of port `8080` to `public`:

```
gh codespace ports visibility --repo=$GITHUB_REPOSITORY 8080:public
```

## Enable Problem Patterns

The OpenTelemetry Demo app comes with problem patterns built in.

To enable / disable:

* Modify the `defaultValue` in `.devcontainer/otel-demo/flags.yaml` (usually from `off` to `on` or use one of the `variant` keys).
* Apply the changes and restart flagd (for some reason the OTEL demo app chooses not to live reload) so a restart of the feature flag engine ([flagd](https://flagd.dev)) is necessary:

```
kubectl apply -f .devcontainer/otel-demo/flags.yaml
kubectl scale deploy/my-otel-demo-flagd --replicas=0
kubectl scale deploy/my-otel-demo-flagd --replicas=1
```

## Cleanup

Codespaces are charged when they're running (you have 2000 credits for free). Go to `https://github.com/codespaces` and delete the codespace to prevent charges.