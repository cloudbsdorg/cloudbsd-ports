PORTNAME=	cloudbsd-drm-515-radeon-kmod
PORTREVISION=	0
COMMENT=	CloudBSD DRM 515 radeonkms kernel module (legacy AMD)

CLOUDBSD_DRM_KMODS=	radeon

RUN_DEPENDS=	cloudbsd-drm-515-core-kmod>0:graphics/cloudbsd-drm-515-core-kmod

CONFLICTS_INSTALL=	drm-515-kmod \
			drm-61-kmod \
			drm-66-kmod \
			drm-612-kmod \
			drm-latest-kmod \
			cloudbsd-drm-61-radeon-kmod \
			cloudbsd-drm-66-radeon-kmod \
			cloudbsd-drm-612-radeon-kmod \
			cloudbsd-drm-latest-radeon-kmod

PLIST_FILES=	${KMODDIR}/radeonkms.ko

.include "${.CURDIR}/../cloudbsd-drm-515-kmod/Makefile.open.common"
