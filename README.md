# Carinata

[![Build container image](https://github.com/tulilirockz/carinata/actions/workflows/build.yml/badge.svg)](https://github.com/tulilirockz/carinata/actions/workflows/build.yml)
[![Build disk image](https://github.com/tulilirockz/carinata/actions/workflows/build-image.yml/badge.svg)](https://github.com/tulilirockz/carinata/actions/workflows/build-image.yml)

[Bootc-based](https://www.cncf.io/projects/bootc/) appliance image with automatic updates and docker support for use with [Lima](https://lima-vm.io/).

## Usage

Apply the manifest like the following:

```bash
limactl create --name=docker --yes https://raw.githubusercontent.com/tulilirockz/carinata/refs/heads/main/docker-carinata-rootful.yaml
```

This will create a virtual machine called `docker` that will have the `docker.sock` socket exposed to your system, which can be used as a context on your host system:

```bash
[tulip@bismuth carinata]$ limactl create --name=docker --mount /var/folders:w --mount /private/var/folders:w --yes https://raw.githubusercontent.com/tulilirockz/carinata/refs/heads/main/docker-carinata-rootful.yaml
```
```
INFO[0000] Attempting to download the image              arch=aarch64 digest= location="https://github.com/tulilirockz/carinata/releases/download/rolling/carinata-arm64.qcow2"
INFO[0000] Using cache "/Users/tulip/Library/Caches/lima/download/by-url-sha256/361cf2e9f37ef1e8f6de95bed4677597827273a01fd1d148ee4191d99666b578/data"
INFO[0003] Run `limactl start docker` to start the instance.
```

```bash
[tulip@bismuth carinata]$ limactl start docker
INFO[0000] Using the existing instance "docker"
INFO[0000] Starting the instance "docker" with internal VM driver "vz"
INFO[0000] [hostagent] hostagent socket created at /Users/tulip/.lima/docker/ha.sock
INFO[0000] [hostagent] Starting VZ (hint: to watch the boot progress, see "(my user)/.lima/docker/serial*.log")
INFO[0000] [hostagent] [VZ] - vm state change: running
# ...
INFO[0044] READY. Run `limactl shell docker` to open the shell.
```

```bash
[tulip@bismuth carinata]$ docker ps
```
```
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```
