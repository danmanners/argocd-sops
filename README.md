# SOPS, KSOPS, and AWS KMS Enabled ArgoCD (oh my!)

This modified container should be used in conjunction with SOPS/KSOPS encrypted secrets.

## Build Process

```bash
# Create the ArgoCD SOPS Manifest
buildah manifest create argocd-sops

# Build the amd64 container
buildah bud --manifest argocd-sops \
    --tag ghcr.io/danmaners/argo-repo-server:e.2.2.3 \
    --arch amd64 .

# Ensure that we're logged into GitHub Container Registry
echo "$(cat ~/.github/token|head -1)" | \
    buildah login --password-stdin \
    --username danmanners ghcr.io

# Push the Buildah Manifest to GHCR
buildah manifest push \
    --all argocd-sops \
    docker://ghcr.io/danmanners/argo-repo-server:e.2.2.3
```

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
