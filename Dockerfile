ARG TAG="v1.0.0"
ARG UBI_IMAGE
ARG GO_IMAGE

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
FROM ${UBI_IMAGE}
WORKDIR /
COPY --from=builder /go/ib-sriov-cni/images/entrypoint.sh /
COPY --from=builder /go/ib-sriov-cni/build/ib-sriov-cni /usr/bin/
ENTRYPOINT ["/entrypoint.sh"]
