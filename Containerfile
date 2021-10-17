FROM docker.io/argoproj/argocd:v2.1.3
ARG SOPS_VERSION="v3.7.1"

# Need to do installs as root
USER root

# Install tools for SOPS and AWSCLI
RUN apt-get update && \
    apt-get install -y curl awscli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    curl -o /usr/local/bin/sops -L https://github.com/mozilla/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux && \
    chmod +x /usr/local/bin/sops

# Need to run Argo as the `argocd` user
USER argocd
