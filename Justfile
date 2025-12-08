refresh: delete create-mac

image := env("IMAGE_FULL", "ghcr.io/tulilirockz/carinata:latest")

iso $image=image:
    #!/usr/bin/env bash
    mkdir -p output
    sudo podman pull "${image}"
    sudo podman run \
        --rm \
        -it \
        --privileged \
        --pull=newer \
        --security-opt label=type:unconfined_t \
        -v "./disk-image.config.toml:/config.toml:ro" \
        -v ./output:/output \
        -v /var/lib/containers/storage:/var/lib/containers/storage \
        quay.io/centos-bootc/bootc-image-builder:latest \
        --rootfs btrfs \
        --type qcow2 \
        --use-librepo=True \
        "${image}"

create:
    limactl create \
        --name=docker \
        --yes \
        ./docker-centos-rootful.yaml

create-mac:
    limactl create \
        --mount /var/folders:w \
        --mount /private/var/folders:w \
        --name=docker \
        --yes \
        ./docker-carinata-rootful.yaml

delete:
    limactl remove docker -f
