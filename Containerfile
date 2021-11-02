ARG ARGOCD_VERSION="v2.1.1"
ARG KSOPS_VERSION="3.0.1"

### Fetch the SOPS and KSOPS binaries
FROM alpine:3.14 as fetch
# Loading in our Args
ARG KSOPS_VERSION

# Installing requirements
RUN apk add --no-cache curl tar && \
    curl -o /tmp/ksops.tar.gz   -L https://github.com/viaduct-ai/kustomize-sops/releases/download/v${KSOPS_VERSION}/ksops_${KSOPS_VERSION}_Linux_$(uname -m).tar.gz && \
    tar -xvf /tmp/ksops.tar.gz  -C /tmp

### Provision the new ArgoCD Container
FROM quay.io/argoproj/argocd:${ARGOCD_VERSION} as argocd

# Need to do installs as root
USER root

# Set the environment variable for our KSOPS path in ArgoCD
ARG KSOPS_PATH="/.config/kustomize/plugin/viaduct.ai/v1/ksops"

# Create the appropriate directory
RUN mkdir -p $KSOPS_PATH

# Copy the binaries over from the 'fetch' container, and ensure they're executable
COPY --from=fetch /tmp/ksops $KSOPS_PATH/ksops
RUN chmod a+x "$KSOPS_PATH/ksops"

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
