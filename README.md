# SOPS, KSOPS, and AWS KMS Enabled ArgoCD (oh my!)

This modified container should be used in conjunction with SOPS/KSOPS encrypted secrets.

## Build Process

Using [`kim`](https://github.com/rancher/kim), we can build the container.

```bash
# Build Container
kim build -n kim --tag docker.io/danielmanners/argocd-sops:v2.1.1 --no-cache --file Containerfile .

# Log into Docker Hub
read -s dockeriopass
echo "$dockeriopass" | kim builder login docker.io -u username --password-stdin

# Push the docker container
kim image push docker.io/danielmanners/argocd-sops:v2.1.1
```

If you have installed `kim` in a non-default namespace, ensure you add `-n $namespace` after kim to each command above.

## Verifying Container Efficiency

You can validate the Containerfile efficiency (with [`podman`](https://podman.io/) and [dive](https://github.com/wagoodman/dive) by running the following command.

```bash
# Set the version
ARGO_VERSION="v2.1.3"

# Use Podman to build the container
podman build -t argocd-sops:$ARGO_VERSION `pwd`

# Use Dive with the Podman Source to evaluate the efficiency
dive podman://localhost/argocd-sops:$ARGO_VERSION
```
