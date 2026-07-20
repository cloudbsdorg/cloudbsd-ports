PORTNAME=	cloudbsd-drm-515-amdgpu-kmod
PORTREVISION=	0
COMMENT=	CloudBSD DRM 515 amdgpu kernel module

CLOUDBSD_DRM_KMODS=	amd

ONLY_FOR_ARCHS=	amd64 aarch64 powerpc64 powerpc64le
ONLY_FOR_ARCHS_REASON=	amdgpu is not built on all architectures in drm-kmod

RUN_DEPENDS=	cloudbsd-drm-515-core-kmod>0:graphics/cloudbsd-drm-515-core-kmod

CONFLICTS_INSTALL=	drm-515-kmod \
			drm-61-kmod \
			drm-66-kmod \
			drm-612-kmod \
			drm-latest-kmod \
			cloudbsd-drm-61-amdgpu-kmod \
			cloudbsd-drm-66-amdgpu-kmod \
			cloudbsd-drm-612-amdgpu-kmod \
			cloudbsd-drm-latest-amdgpu-kmod

PLIST_FILES=	${KMODDIR}/amdgpu.ko

.include "${.CURDIR}/../cloudbsd-drm-515-kmod/Makefile.open.common"
