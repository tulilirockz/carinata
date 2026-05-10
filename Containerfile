FROM scratch AS ctx

COPY build.sh /build.sh
COPY files /files
COPY cosign.pub /files/usr/lib/pki/containers/carinata.pub

FROM quay.io/fedora/fedora-bootc:latest@sha256:226100ec19a5d94defd4737a26a29bee3c24a9f9ddeca56092049c847d911f3b

RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/run \
    --mount=type=bind,from=ctx,source=/,dst=/ctx \
    /ctx/build.sh
