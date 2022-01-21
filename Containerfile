ARG ARGOCD_VERSION="v2.2.3"
ARG  KSOPS_VERSION="3.0.1"

### Fetch the SOPS and KSOPS binaries
FROM docker.io/alpine:3.15 as fetch

# Environment Setup
ENV XDG_CONFIG_HOME="${HOME}/.config"

RUN apk add --no-cache curl \
    && sh -c 'export XDG_CONFIG_HOME="${HOME}"/.config; curl -s https://raw.githubusercontent.com/viaduct-ai/kustomize-sops/master/scripts/install-ksops-archive.sh | sh'

### Provision the new ArgoCD Container
FROM quay.io/argoproj/argocd:${ARGOCD_VERSION} as argocd
# Need to do installs as root
USER root

# Set the environment variable for our KSOPS path in ArgoCD
ARG KSOPS_PATH="/.config/kustomize/plugin/viaduct.ai/v1/ksops"

# Create the appropriate directory
RUN mkdir -p $KSOPS_PATH

# Copy the binaries over from the 'fetch' container, and ensure they're executable
COPY --from=fetch /root/.config/kustomize/plugin/viaduct.ai/v1/ksops/ksops /usr/local/bin/ksops
RUN chmod a+x /usr/local/bin/ksops

# Install tools for KSOPS and AWSCLI
RUN apt-get update && \
    apt-get install -y awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    chown -R 999 /.config

# Need to run Argo as the `argocd` user, UID 999
USER 999

# Sets the XDG_Config_Home Environment variable
ENV XDG_CONFIG_HOME="/.config"
