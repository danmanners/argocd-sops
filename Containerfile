ARG ARGOCD_VERSION="v2.1.1"
ARG  KSOPS_VERSION="3.0.1"
ARG   SOPS_VERSION="v3.7.1"

### Fetch the SOPS and KSOPS binaries
FROM alpine:3.14 as fetch
# Loading in our Args
ARG SOPS_VERSION
ARG KSOPS_VERSION
# Installing requirements
RUN apk add --no-cache curl tar && \
    curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    curl -o /tmp/ksops.tar.gz   -L https://github.com/viaduct-ai/kustomize-sops/releases/download/v${KSOPS_VERSION}/ksops_${KSOPS_VERSION}_Linux_$(uname -m).tar.gz && \
    tar -xvf /tmp/ksops.tar.gz  -C /usr/local/bin


### Provision the new ArgoCD Container
FROM quay.io/argoproj/argocd:${ARGOCD_VERSION} as argocd
ARG SOPS_VERSION
# Need to do installs as root
USER root

# Copy the binaries over from the 'fetch' container, and ensure they're executable
COPY --from=fetch /usr/local/bin/sops /usr/local/bin/sops
COPY --from=fetch /usr/local/bin/ksops /usr/local/bin/ksops
RUN chmod a+x /usr/local/bin/ksops && chmod a+x /usr/local/bin/sops

# Install tools for SOPS and AWSCLI
RUN apt-get update && \
    apt-get install -y awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Need to run Argo as the `argocd` user
USER 999
