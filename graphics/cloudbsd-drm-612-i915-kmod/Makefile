PORTNAME=	cloudbsd-drm-612-i915-kmod
PORTREVISION=	0
COMMENT=	CloudBSD DRM 612 i915kms kernel module

CLOUDBSD_DRM_KMODS=	i915

ONLY_FOR_ARCHS=	amd64
ONLY_FOR_ARCHS_REASON=	i915kms is only built on supported arches in drm-kmod

RUN_DEPENDS=	cloudbsd-drm-612-core-kmod>0:graphics/cloudbsd-drm-612-core-kmod

CONFLICTS_INSTALL=	drm-515-kmod \
			drm-61-kmod \
			drm-66-kmod \
			drm-612-kmod \
			drm-latest-kmod \
			cloudbsd-drm-515-i915-kmod \
			cloudbsd-drm-61-i915-kmod \
			cloudbsd-drm-66-i915-kmod \
			cloudbsd-drm-latest-i915-kmod

PLIST_FILES=	${KMODDIR}/i915kms.ko

.include "${.CURDIR}/../cloudbsd-drm-612-kmod/Makefile.open.common"
