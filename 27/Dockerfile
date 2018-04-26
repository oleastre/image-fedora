## -*- docker-image-name: "scaleway/fedora:27" -*-
FROM library/fedora:27

# Environment
ENV SCW_BASE_IMAGE scaleway/fedora:latest

# Adding and calling builder-enter
COPY ./overlay-image-tools/usr/local/sbin/scw-builder-enter /usr/local/sbin/
COPY ./overlay/etc/default/grub /etc/default/

RUN dnf group install -y "Minimal Install" \
	&& dnf install -y \
	curl \
	dhcp-client \
	kernel \
	openssh-clients \
	openssh-server \
	passwd \
	sudo \
	&& case $(arch) in \
	x86_64) GRUB_ARCH="x64" ;;\
	i686) GRUB_ARCH="ia32" ;;\
	aarch64) GRUB_ARCH="aa64" ;;\
	esac \
	&& dnf install -y grub2-efi-"${GRUB_ARCH}" \
	grub2-efi-"${GRUB_ARCH}"-modules \
	grub2 \
	grub2-pc


# Patch rootfs
COPY ./overlay-image-tools ./overlay-base ./overlay /

# Enable Scaleway services
RUN systemctl enable \
	scw-generate-ssh-keys \
	scw-fetch-ssh-keys \
	scw-gen-machine-id \
	scw-kernel-check \
	scw-sync-kernel-modules \
	scw-signal-booted \
	scw-generate-net-config \
	scw-net-ipv6 \
	scw-generate-root-passwd \
	scw-set-hostname

# Enable getty for serial console
RUN ln -sf /usr/lib/systemd/system/console-getty.service /etc/systemd/system/multi-user.target.wants/ && \
	rm /etc/systemd/system/console-getty.service

# Avoid duplicate the same action (with scw-generate-ssh-keys)
RUN systemctl mask sshd-keygen.service

# Uncomment to disable persistent journald logging
#RUN sed -i 's/Storage=auto/Storage=volatile/g' /etc/systemd/journald.conf \
#	&& systemctl enable rsyslog

# Remove persistent systemd journald files
#RUN rm -rf /var/log/journal

# Disable NOCOW
#RUN rm /usr/lib/tmpfiles.d/journal-nocow.conf \
#	&& ln -s /dev/null /usr/lib/tmpfiles.d/journal-nocow.conf

# Uncomment to disable SELinux on a local boot instance
#RUN sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# This Centos service is not compatible with Scaleway kernel
# kdumpctl[1213]: Kdump is not supported on this kernel
RUN systemctl mask kdump.service

# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave
