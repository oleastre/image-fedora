NAME =			fedora
VERSION =		22
VERSION_ALIASES =	twenty-two latest
TITLE =			Fedora 22
DESCRIPTION =		Fedora 22
SOURCE_URL =		https://github.com/scaleway/image-fedora
VENDOR_URL =		https://arm.fedoraproject.org

IMAGE_VOLUME_SIZE =	50G
IMAGE_BOOTSCRIPT =	fedora
IMAGE_NAME =		Fedora 22

## Image tools  (https://github.com/scaleway/image-tools)
all:    docker-rules.mk
docker-rules.mk:
	wget -qO - https://j.mp/scw-builder | bash
-include docker-rules.mk
