#!/usr/bin/env bash

set -xeuo pipefail

tee /usr/lib/systemd/journald.conf.d/99-audit.conf <<'EOF'
[Journal]
Audit=yes
ReadKMsg=yes
EOF

systemctl enable sshd
systemctl enable podman-auto-update.timer
systemctl enable --global podman-auto-update.timer

# Unsure why removing nfs-utils is annoying here
mkdir -p /var/lib/rpm-state/
touch /var/lib/rpm-state/nfs-server.cleanup

dnf -y remove \
  adcli \
  bind-utils \
  chrony \
  criu* \
  efibootmgr \
  ethtool \
  flatpak-session-helper \
  jq \
  libdnf-plugin-subscription-manager \
  nano \
  nfs-server \
  nfs-utils \
  pkg-config* \
  python3-cloud-what \
  python3-subscription-manager-rhsm \
  socat \
  sos \
  sssd* \
  stalld \
  subscription-manager \
  subscription-manager-rhsm-certificates \
  toolbox \
  yggdrasil*

dnf install -y cloud-init

dnf -y install --setopt=install_weak_deps=False \
  console-login-helper-messages \
  console-login-helper-messages-issuegen \
  console-login-helper-messages-motdgen \
  console-login-helper-messages-profile \
  distrobox \
  git-core \
  rsync \
  strip \
  fedora-release-identity-cloud \
  fedora-release-cloud \
  systemd-container \
  systemd-journal-remote \
  systemd-networkd \
  systemd-networkd-defaults \
  systemd-pam \
  systemd-resolved \
  systemd-resolved \
  systemd-rpm-macros \
  systemd-udev \
  tcpdump \
  traceroute \
  qemu-guest-agent \
  udisks2-lvm2 \
  xdg-user-dirs

systemctl enable NetworkManager
systemctl enable systemd-timesyncd

sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/bootc update --quiet|' /usr/lib/systemd/system/bootc-fetch-apply-updates.service
sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

systemctl enable bootc-fetch-apply-updates

tee /usr/lib/systemd/zram-generator.conf <<'EOF'
[zram0]
zram-size = min(ram, 8192)
EOF

tee /usr/lib/systemd/system-preset/91-resolved-default.preset <<'EOF'
enable systemd-resolved.service
EOF
tee /usr/lib/tmpfiles.d/resolved-default.conf <<'EOF'
L /etc/resolv.conf - - - - ../run/systemd/resolve/stub-resolv.conf
EOF

systemctl preset systemd-resolved.service

dnf -y install 'dnf5-command(config-manager)'
dnf config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
dnf config-manager setopt docker-ce-stable.enabled=0
dnf -y install --enablerepo='docker-ce-stable' docker-ce docker-ce-cli docker-compose-plugin
systemctl enable docker.service
systemctl enable docker.socket
systemctl enable podman.service
systemctl enable podman.socket
systemctl preset docker.service docker.socket
mkdir -p /usr/lib/sysctl.d
echo "net.ipv4.ip_forward = 1" | tee /usr/lib/sysctl.d/docker-ce.conf
echo "g docker -" | tee /usr/lib/sysusers.d/docker.conf

rm -rf /opt
mkdir -p /opt
mkdir -p /Users # for MacOS compatibility :)

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "$KERNEL_VERSION" --reproducible --zstd -v --add ostree -f "/usr/lib/modules/$KERNEL_VERSION/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
