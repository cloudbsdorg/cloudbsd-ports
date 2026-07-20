PORTNAME=	cloudbsd-drm-latest-core-kmod
PORTREVISION=	0
COMMENT=	CloudBSD DRM latest core modules (drm/ttm/dmabuf)

CLOUDBSD_DRM_KMODS=	dmabuf ttm drm

CONFLICTS_INSTALL=	drm-515-kmod \
			drm-61-kmod \
			drm-66-kmod \
			drm-612-kmod \
			drm-latest-kmod \
			cloudbsd-drm-515-core-kmod \
			cloudbsd-drm-61-core-kmod \
			cloudbsd-drm-66-core-kmod \
			cloudbsd-drm-612-core-kmod

PLIST_FILES=	${KMODDIR}/dmabuf.ko \
		${KMODDIR}/drm.ko \
		${KMODDIR}/ttm.ko

SUB_FILES=	pkg-message
SUB_LIST=	PORTNAME=${PORTNAME} OPSYS=${OPSYS} OSREL=${OSREL} CLOUDBSD_DRM_VER=latest

.include "${.CURDIR}/../cloudbsd-drm-latest-kmod/Makefile.open.common"
