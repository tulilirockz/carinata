FROM scratch AS ctx

COPY build.sh /build.sh
COPY files /files
COPY cosign.pub /files/usr/lib/pki/containers/carinata.pub

FROM quay.io/fedora/fedora-bootc:latest@sha256:bc0bd1d8b31daf870a32d3f9da45027ffac87d59d6d6115eaa082b7969d4c213

RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/run \
    --mount=type=bind,from=ctx,source=/,dst=/ctx \
    /ctx/build.sh
