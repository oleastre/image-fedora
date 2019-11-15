## -*- docker-image-name: "scaleway/fedora:31" -*-
ARG DOCKER_ARCH
FROM ${DOCKER_ARCH}/fedora:31

ARG SCW_ARCH

# Environment
ENV SCW_BASE_IMAGE scaleway/fedora:31

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
	cracklib-dicts \
	&& case $(arch) in \
	x86_64) GRUB_ARCH="x64"; dnf install -y grub2-pc ;;\
	aarch64) GRUB_ARCH="aa64" ;;\
	esac \
	&& dnf install -y grub2-efi-"${GRUB_ARCH}" \
	grub2-efi-"${GRUB_ARCH}"-modules \
	grub2 \
	&& dnf config-manager --set-disabled updates-testing

# Enable cloud-init
RUN dnf install -y https://copr-be.cloud.fedoraproject.org/results/oleastre/misc/fedora-31-x86_64/01093140-cloud-init/cloud-init-19.3-1.fc31.noarch.rpm
RUN dnf install -y \
	cloud-utils \
	cloud-utils-growpart

# Patch rootfs
COPY ./overlay-base ./overlay /

# Configure Systemd
RUN systemctl set-default multi-user
RUN systemctl preset --preset-mode=full $(cat /etc/systemd/system-preset/*scw*.preset | cut -d' ' -f2 | tr '\n' ' ')

# Enable getty for serial console
RUN ln -sf /usr/lib/systemd/system/console-getty.service /etc/systemd/system/multi-user.target.wants/ && \
	rm /etc/systemd/system/console-getty.service

# Avoid duplicate the same action (with scw-generate-ssh-keys)
RUN systemctl mask sshd-keygen.service

# Unfortunately F28 does not boot within 120 seconds with the SELinux relabel
# set SELinux to permissive so users can run the relabel manually after first boot
RUN sed -i 's/SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config

# Enable SCW motd
RUN echo "session optional pam_motd.so" >> /etc/pam.d/login && echo "/etc/update-motd.d/50-scw" >> /etc/profile

# This Centos service is not compatible with Scaleway kernel
# kdumpctl[1213]: Kdump is not supported on this kernel
RUN systemctl mask kdump.service

# Clean rootfs from image-builder
RUN /usr/local/sbin/scw-builder-leave
