PORTNAME=	cloudbsd-drm-latest-kmod
DISTVERSION=	${DRM_KMOD_DISTVERSION}
PORTREVISION=	0
CATEGORIES=	graphics

MAINTAINER=	ports@cloudbsd.org
COMMENT=	CloudBSD DRM latest full stack (all vendors) metaport
WWW=		https://github.com/freebsd/drm-kmod/

.include "Makefile.version"

USES=		metaport

RUN_DEPENDS=	${KMODDIR}/drm.ko:graphics/cloudbsd-drm-latest-core-kmod \
		${KMODDIR}/amdgpu.ko:graphics/cloudbsd-drm-latest-amdgpu-kmod \
		${KMODDIR}/i915kms.ko:graphics/cloudbsd-drm-latest-i915-kmod \
		${KMODDIR}/radeonkms.ko:graphics/cloudbsd-drm-latest-radeon-kmod \
		${KMODDIR}/nvidia-drm.ko:graphics/cloudbsd-nvidia-drm-latest-kmod \
		gpu-firmware-kmod>=20220511:graphics/gpu-firmware-kmod \
		cloudbsd-gpu-detect:sysutils/cloudbsd-gpu-autoload

.include <bsd.port.mk>
