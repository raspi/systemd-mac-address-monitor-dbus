APPNAME?=systemd-mac-address-monitor-dbus

# version from last tag
VERSION := $(shell git describe --abbrev=0 --always --tags)
BUILD := $(shell git rev-parse $(VERSION))
BUILDDATE := $(shell git log -1 --format=%aI $(VERSION))
BUILDFILES?=$$(find . -mindepth 1 -maxdepth 1 -type f \( -iname "*${APPNAME}-v*" -a ! -iname "*.shasums" \))
RELEASETMPDIR := $(shell mktemp -d -t ${APPNAME}-rel-XXXXXX)
APPANDVER := ${APPNAME}-$(VERSION)
RELEASETMPAPPDIR := $(RELEASETMPDIR)/$(APPANDVER)

default: build

release: compress-everything shasums release-ldistros
	@echo "release done..."

# Linux distributions
release-ldistros: ldistro-arch
	@echo "Linux distros release done..."

shasums:
	@echo "Checksumming..."
	@pushd "release/${VERSION}" && shasum -a 256 $(BUILDFILES) > $(APPANDVER).shasums

# Copy common files to release directory
# Creates $(APPNAME)-$(VERSION) directory prefix where everything will be copied by compress-$OS targets
copycommon:
	@echo "Copying common files to temporary release directory '$(RELEASETMPAPPDIR)'.."
	@mkdir -p "$(RELEASETMPAPPDIR)/bin"
	@cp -v "./LICENSE" "$(RELEASETMPAPPDIR)"
	@cp -v "./README.md" "$(RELEASETMPAPPDIR)"
	@mkdir --parents "$(PWD)/release/${VERSION}"

# Compress files: GNU/Linux
compress-linux:
	echo "GNU/Linux tar..."; \
	cp -v "$(PWD)/mac-address-monitor-dbus" "$(RELEASETMPAPPDIR)/bin"; \
	cd "$(RELEASETMPDIR)"; \
	tar --numeric-owner --owner=0 --group=0 -zcvf "$(PWD)/release/${VERSION}/$(APPANDVER).tar.gz" . ; \
	rm "$(RELEASETMPAPPDIR)/bin/${APPNAME}"; 

# Move all to temporary directory and compress with common files
compress-everything: copycommon compress-linux
	@echo "$@ ..."
	rm -rf "$(RELEASETMPDIR)/*"

# Distro: Arch linux - https://www.archlinux.org/
# Generates multi-arch PKGBUILD
ldistro-arch:
	pushd release/linux/arch && make build

.PHONY: all clean test default
