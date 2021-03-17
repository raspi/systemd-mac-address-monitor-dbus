MAINTAINER?=Pekka Järvinen
VERSION?=dev
TMPFILE := $(shell mktemp -t PKGBUILD-${VERSION}-XXXXXX)
# Get checksum line and remove file name
SHASUM := $(shell grep '$(APPANDVER)\.tar\.gz' "../../$(VERSION)/$(APPANDVER).shasums" | cut -d' ' -f1 )

PKGBUILD:
	cat "template.txt" > "$(TMPFILE)" && \
	sed -i "s@%VERSION%@$(VERSION)@" "$(TMPFILE)" && \
	sed -i "s@%APPNAME%@$(APPNAME)@" "$(TMPFILE)" && \
	sed -i "s@%SHA256SUM%@$(SHASUM)@" "$(TMPFILE)" && \
	mv "$(TMPFILE)" "$@"

release: PKGBUILD
	echo "Arch Linux PKGBUILD $@ done"

.PHONY: all clean test default
