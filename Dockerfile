ARG TAG="v1.0.2"
ARG ORG=rancher
ARG BCI_IMAGE=registry.suse.com/bci/bci-base:15.3.17.20.12
ARG GO_IMAGE=${ORG}/hardened-build-base:v1.20.3b1

# Build the project
FROM ${GO_IMAGE} as builder
RUN set -x \
 && apk --no-cache add \
    git \
    make
ARG TAG
RUN git clone --depth=1 https://github.com/k8snetworkplumbingwg/ib-sriov-cni
WORKDIR ib-sriov-cni
RUN git fetch --all --tags --prune
RUN git checkout tags/${TAG} -b ${TAG}
RUN make clean && make build 

# Create the sriov-cni image
FROM ${BCI_IMAGE}
RUN zypper refresh && \
    zypper update -y && \
    zypper install -y gawk which && \
    zypper clean -a
WORKDIR /
COPY --from=builder /go/ib-sriov-cni/images/entrypoint.sh /
COPY --from=builder /go/ib-sriov-cni/build/ib-sriov /usr/bin/
ENTRYPOINT ["/entrypoint.sh"]
