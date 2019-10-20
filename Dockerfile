FROM node:alpine as installer
COPY package*.json /bats/
WORKDIR /bats
RUN npm install

FROM alpine:latest
ENV KUBECTL_VERSION 1.16.0
ENV SHELLCHECK_VERSION 0.7.0
ENV YQ_VERSION 2.4.0

COPY --from=installer /bats/node_modules/bats /opt/bats/

RUN apk add --no-cache bash curl jq \
  && ln -s /opt/bats/bin/bats /usr/local/bin/bats \
  && cd /usr/local/bin \
  && curl -LO https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x kubectl \
  && curl -LO https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 \
  && mv yq_linux_amd64 yq \
  && chmod +x yq \
  && cd /opt \
  && curl -LO https://shellcheck.storage.googleapis.com/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
  && tar xf shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
  && rm shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
  && ln -s /opt/shellcheck-v${SHELLCHECK_VERSION}/shellcheck /usr/local/bin/shellcheck
