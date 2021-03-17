export APPNAME?=systemd-mac-address-monitor-dbus

# Version from last tag
export VERSION := $(shell git describe --abbrev=0 --always --tags)
BUILD := $(shell git rev-parse $(VERSION))
BUILDDATE := $(shell git log -1 --format=%aI $(VERSION))
BUILDFILES?=$$(find . -mindepth 1 -maxdepth 1 -type f \( -iname "*${APPNAME}-v*" -a ! -iname "*.shasums" \))
RELEASETMPDIR := $(shell mktemp -d -t ${APPNAME}-rel-${VERSION}-XXXXXX)
export APPANDVER := ${APPNAME}-$(VERSION)
RELEASETMPAPPDIR := $(RELEASETMPDIR)/$(APPANDVER)

default: build

build:
	@echo "nothing to build. Try release target?"

release: compress-everything release-ldistros shasums
	@echo "release done..."

# Linux distributions
release-ldistros: ldistro-arch
	@echo "Linux distros release done..."

shasums:
	@echo "Checksumming..."
	@pushd "release/${VERSION}" && shasum -a 256 $(BUILDFILES) > $(APPANDVER).shasums

# Copy common files to release directory
# Creates $(APPNAME)-$(VERSION) directory prefix where everything will be copied to compression targets
copycommon:
	@echo "Copying common files to temporary release directory '$(RELEASETMPAPPDIR)'.."
	@mkdir -p "$(RELEASETMPAPPDIR)/bin"
	@cp -v "./LICENSE" "$(RELEASETMPAPPDIR)"
	@cp -v "./README.md" "$(RELEASETMPAPPDIR)"
	@mkdir --parents "$(PWD)/release/${VERSION}"

# Compress files: GNU/Linux
compress-linux:
	echo "GNU/Linux tar..."; \
	cp -v "$(PWD)/${APPNAME}" "$(RELEASETMPAPPDIR)/bin"; \
	cp -v "$(PWD)/${APPNAME}@.service" "$(RELEASETMPAPPDIR)"; \
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
	$(MAKE) -C "$(PWD)/release/linux/arch/" release && \
	mv "$(PWD)/release/linux/arch/PKGBUILD" "$(PWD)/release/$(VERSION)/$(APPANDVER).PKGBUILD"

.PHONY: all clean test default
