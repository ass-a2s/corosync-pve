include /usr/share/dpkg/pkg-info.mk
include /usr/share/dpkg/architecture.mk

PACKAGE=corosync

CSVERSION=${DEB_VERSION_UPSTREAM}
CSRELEASE=pve2

BUILDDIR=${PACKAGE}-${CSVERSION}
CSSRC=upstream

ARCH:=$(shell dpkg-architecture -qDEB_BUILD_ARCH)
GITVERSION:=$(shell git rev-parse HEAD)

MAIN_DEB=corosync_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \

OTHER_DEBS=\
corosync-notifyd_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
corosync-doc_${CSVERSION}-${CSRELEASE}_all.deb \
libcfg7_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcmap4_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcorosync-common4_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcpg4_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libquorum5_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libsam4_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libvotequorum8_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcfg-dev_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcmap-dev_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcorosync-common-dev_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcpg-dev_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libquorum-dev_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libsam-dev_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libvotequorum-dev_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \

DBG_DEBS=\
corosync-dbgsym_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
corosync-notifyd-dbgsym_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcfg7-dbgsym_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcmap4-dbgsym_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcorosync-common4-dbgsym_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libcpg4-dbgsym_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libquorum5-dbgsym_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libsam4-dbgsym_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \
libvotequorum8-dbgsym_${CSVERSION}-${CSRELEASE}_${DEB_BUILD_ARCH}.deb \

DEBS=${MAIN_DEB} ${OTHER_DEBS} ${DBG_DEBS}

DSC=corosync-pve_${CSVERSION}-${CSRELEASE}.dsc

all: ${DEBS}
	echo ${DEBS}

${BUILDDIR}: submodule debian/changelog
	rm -rf $@ $@.tmp
	cp -a ${CSSRC} $@.tmp
	cp -a debian $@.tmp
	mv $@.tmp $@

.PHONY: deb
deb: ${DEBS}
${OTHER_DEBS} ${DBG_DEBS}: ${MAIN_DEB}
${MAIN_DEB}: ${BUILDDIR}
	cd ${BUILDDIR}; dpkg-buildpackage -b -us -uc

.PHONY: dsc
dsc: ${DSC}
${DSC}: ${BUILDDIR}
	cd ${BUILDDIR}; dpkg-buildpackage -S -us -uc -d -nc

.PHONY: submodule
submodule:
	test -f "${CSSRC}/INSTALL" || git submodule update --init ${CSSRC}

.PHONY: upload
upload: ${DEBS}
	tar cf - ${DEBS} | ssh -X repoman@repo.proxmox.com -- upload --product pve --dist buster --arch ${DEB_BUILD_ARCH}

.PHONY: clean
distclean: clean
clean:
	rm -rf *.deb *.changes *.dsc *.buildinfo ${BUILDDIR}
	find . -name '*~' -exec rm {} ';'

.PHONY: dinstall
dinstall: ${DEBS}
	dpkg -i ${DEBS}
