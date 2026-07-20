PORTNAME=	cloudbsd-drm-66-core-kmod
PORTREVISION=	0
COMMENT=	CloudBSD DRM 6.6 core modules (drm/ttm/dmabuf)

# Core modules shared by all vendor drivers in this version line.
CLOUDBSD_DRM_KMODS=	dmabuf ttm drm

# Also conflict with future CloudBSD cores of other version lines (same basenames).
CONFLICTS_INSTALL=	drm-515-kmod \
			drm-61-kmod \
			drm-66-kmod \
			drm-612-kmod \
			drm-latest-kmod \
			cloudbsd-drm-515-core-kmod \
			cloudbsd-drm-61-core-kmod \
			cloudbsd-drm-612-core-kmod \
			cloudbsd-drm-latest-core-kmod

PLIST_FILES=	${KMODDIR}/dmabuf.ko \
		${KMODDIR}/drm.ko \
		${KMODDIR}/ttm.ko

SUB_FILES=	pkg-message
SUB_LIST=	PORTNAME=${PORTNAME} OPSYS=${OPSYS} OSREL=${OSREL}

.include "${.CURDIR}/../cloudbsd-drm-66-kmod/Makefile.open.common"
