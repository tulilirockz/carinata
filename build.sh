#!/usr/bin/env bash

set -xeuo pipefail

cp -avf "/ctx/files"/. /

systemctl enable sshd

# Please make an issue if any of this breaks your use case, this was specifically tailored towards running only on
# `lima` as a simple guest, so we are just removing everything possible here
dnf -y remove \
  adcli \
  adwaita* \
  samba* \
  bind-utils \
  bluez \
  chrony \
  criu* \
  efibootmgr \
  ethtool \
  exfatprogs \
  f2fs-tools \
  flashrom \
  flatpak-session-helper \
  fwupd* \
  groff-base \
  jq \
  kexec-tools \
  keyutils \
  kpartx \
  lvm2 \
  makedumpfile \
  man-db \
  nano \
  nfs-utils \
  nvidia-gpu-firmware \
  nvme-cli \
  python3-botocore \
  qemu-user-static* \
  quota* \
  sg3_utils* \
  socat \
  sos \
  sssd* \
  stalld \
  toolbox \
  tpm2-tools \
  udftools \
  wcurl \
  xkeyboard-config

dnf install -y cloud-init qemu-guest-agent rsync # These are all required for Lima in one way or another

systemctl enable NetworkManager
systemctl enable systemd-timesyncd

sed -i 's|^OnUnitInactiveSec=.*|OnUnitInactiveSec=7d\nPersistent=true|' /usr/lib/systemd/system/bootc-fetch-apply-updates.timer
sed -i 's|#AutomaticUpdatePolicy.*|AutomaticUpdatePolicy=stage|' /etc/rpm-ostreed.conf
sed -i 's|#LockLayering.*|LockLayering=true|' /etc/rpm-ostreed.conf

systemctl enable bootc-fetch-apply-updates.timer

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
dnf -y install --enablerepo='docker-ce-stable' -x docker-compose-plugin docker-ce docker-ce-cli

tee /usr/lib/systemd/system-preset/92-docker-default.preset <<'EOF'
enable docker.service
EOF
systemctl preset docker.service docker.socket
systemctl enable docker.service
systemctl enable docker.socket
mkdir -p /usr/lib/sysctl.d
echo "net.ipv4.ip_forward = 1" | tee /usr/lib/sysctl.d/docker-ce.conf
echo "g docker -" | tee /usr/lib/sysusers.d/docker.conf

# Metadata for `countme`
dnf swap -y fedora-release-identity-basic fedora-release-identity-cloud
HOME_URL="https://github.com/tulilirockz/carinata"
sed -i -f - /usr/lib/os-release <<EOF
s|^NAME=.*|NAME=\"Carinata\"|
s|^PRETTY_NAME=.*|PRETTY_NAME=\"Carinata for Lima\"|
s|^HOME_URL=.*|HOME_URL=\"${HOME_URL}\"|
s|^BUG_REPORT_URL=.*|BUG_REPORT_URL=\"${HOME_URL}/issues\"|
s|^SUPPORT_URL=.*|SUPPORT_URL=\"${HOME_URL}/issues\"|
s|^CPE_NAME=\".*\"|CPE_NAME=\"cpe:/o:tulilirockz:carinata\"|
s|^DOCUMENTATION_URL=.*|DOCUMENTATION_URL=\"${HOME_URL}\"|
/^REDHAT_BUGZILLA_PRODUCT=/d
/^REDHAT_BUGZILLA_PRODUCT_VERSION=/d
/^REDHAT_SUPPORT_PRODUCT=/d
/^REDHAT_SUPPORT_PRODUCT_VERSION=/d
EOF

rm -rf /usr/share/doc # These are usually HTML files that will never be read
rm -rf /usr/share/man # we are removing man-db anyways

rm -rf /opt
rm -rf /usr/local
ln -sf /var/usrlocal /usr/local
ln -sf /var/opt /opt
ln -sf /var/home /Users # macOS compat

KERNEL_VERSION="$(find "/usr/lib/modules" -maxdepth 1 -type d ! -path "/usr/lib/modules" -exec basename '{}' ';' | sort | tail -n 1)"
export DRACUT_NO_XATTR=1
dracut --no-hostonly --kver "${KERNEL_VERSION}" --reproducible --omit bluetooth  --omit tpm2-tss --omit lvm --zstd -v --add ostree -f "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"
chmod 0600 "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"

rm -rf /var/*

bootc container lint --fatal-warnings
