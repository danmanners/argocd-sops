# SOPS and AWS KMS Enabled ArgoCD

You can validate the Containerfiles efficiency (with [`podman`](https://podman.io/) and [dive](https://github.com/wagoodman/dive) by running the following command.

```bash
# Set the version
ARGO_VERSION="v2.1.3"

# Use Podman to build the container
podman build -t argocd-sops:$ARGO_VERSION `pwd`

# Use Dive with the Podman Source to evaluate the efficiency
dive podman://localhost/argocd-sops:$ARGO_VERSION
```
