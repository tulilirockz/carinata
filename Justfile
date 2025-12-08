image := env("IMAGE_FULL", "ghcr.io/tulilirockz/carinata:latest")

iso $image=image:
    #!/usr/bin/env bash
    mkdir -p output
    IMAGE_CONFIG="$(mktemp)"
    export IMAGE_FULL="${image}"
    envsubst < ./config.toml > "${IMAGE_CONFIG}"
    sudo podman pull "${image}"
    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v "${IMAGE_CONFIG}:/config.toml:ro" \
        -v ./output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --type iso \
        --use-librepo=True \
        "${image}"
