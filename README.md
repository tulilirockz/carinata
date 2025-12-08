# Carinata

[![Build container image](https://github.com/tulilirockz/carinata/actions/workflows/build.yml/badge.svg)](https://github.com/tulilirockz/carinata/actions/workflows/build.yml)
[![Build disk image](https://github.com/tulilirockz/carinata/actions/workflows/build-image.yml/badge.svg)](https://github.com/tulilirockz/carinata/actions/workflows/build-image.yml)

[Bootc-based](https://www.cncf.io/projects/bootc/) [appliance image](https://github.com/tulilirockz/carinata) with automatic updates and docker support for use with [Lima](https://lima-vm.io/).

## Usage

This is meant to be used the same-ish way you'd use [`colima`](https://github.com/abiosoft/colima). Apply the manifest using the [`just`](https://just.systems/) recipe like the following:

```bash
just create-mac # or "just" create on linux
```

This will create a virtual machine called `docker` that will have the `docker.sock` socket exposed to your system, which can be used as a context on your host system:

```bash
[tulip@bismuth katten]$ just create-mac
limactl create --mount /var/folders:w --mount /private/var/folders:w --name=docker --yes ./docker-carinata-rootful.yaml
INFO[0000] Attempting to download the image              arch=aarch64 digest= location="https://github.com/tulilirockz/carinata/releases/download/rolling/carinata-arm64.qcow2"
INFO[0000] Using cache "(myuser)/Library/Caches/lima/download/by-url-sha256/361cf2e9f37ef1e8f6de95bed4677597827273a01fd1d148ee4191d99666b578/data"
INFO[0003] Run `limactl start docker` to start the instance.
[tulip@bismuth katten 93%]$ limactl start docker
INFO[0000] Using the existing instance "docker"
INFO[0000] Starting the instance "docker" with internal VM driver "vz"
INFO[0000] [hostagent] hostagent socket created at (my user)/.lima/docker/ha.sock
INFO[0000] [hostagent] Starting VZ (hint: to watch the boot progress, see "(my user)/.lima/docker/serial*.log")
INFO[0000] [hostagent] [VZ] - vm state change: running
# ...
INFO[0044] READY. Run `limactl shell docker` to open the shell.
[tulip@bismuth katten]$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
