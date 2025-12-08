FROM scratch AS ctx

COPY build.sh /build.sh

FROM quay.io/fedora/fedora-bootc:latest

RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/run \
    --mount=type=bind,from=ctx,source=/,dst=/tmp/build-scripts \
    /tmp/build-scripts/build.sh

RUN rm -rf /var/* && bootc container lint --fatal-warnings
