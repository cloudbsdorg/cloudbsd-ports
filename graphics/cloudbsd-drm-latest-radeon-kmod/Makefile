PORTNAME=	cloudbsd-drm-latest-radeon-kmod
PORTREVISION=	0
COMMENT=	CloudBSD DRM latest radeonkms kernel module (legacy AMD)

CLOUDBSD_DRM_KMODS=	radeon

RUN_DEPENDS=	${KMODDIR}/drm.ko:graphics/cloudbsd-drm-latest-core-kmod

CONFLICTS_INSTALL=	drm-515-kmod \
			drm-61-kmod \
			drm-66-kmod \
			drm-612-kmod \
			drm-latest-kmod \
			cloudbsd-drm-515-radeon-kmod \
			cloudbsd-drm-61-radeon-kmod \
			cloudbsd-drm-66-radeon-kmod \
			cloudbsd-drm-612-radeon-kmod

PLIST_FILES=	${KMODDIR}/radeonkms.ko

.include "${.CURDIR}/../cloudbsd-drm-latest-kmod/Makefile.open.common"
