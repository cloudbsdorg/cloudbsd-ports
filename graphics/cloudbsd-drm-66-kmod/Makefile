PORTNAME=	cloudbsd-drm-66-kmod
PORTVERSION=	${DRM_KMOD_DISTVERSION}
PORTREVISION=	0
CATEGORIES=	graphics

MAINTAINER=	ports@cloudbsd.org
COMMENT=	CloudBSD DRM 6.6 full stack (all vendors) metaport
WWW=		https://github.com/freebsd/drm-kmod/

.include "Makefile.version"

USES=		metaport

# Install them all: core + open vendors + NVIDIA DRM + firmware.
RUN_DEPENDS=	${KMODDIR}/drm.ko:graphics/cloudbsd-drm-66-core-kmod \
		${KMODDIR}/amdgpu.ko:graphics/cloudbsd-drm-66-amdgpu-kmod \
		${KMODDIR}/i915kms.ko:graphics/cloudbsd-drm-66-i915-kmod \
		${KMODDIR}/radeonkms.ko:graphics/cloudbsd-drm-66-radeon-kmod \
		${KMODDIR}/nvidia-drm.ko:graphics/cloudbsd-nvidia-drm-66-kmod \
		gpu-firmware-kmod>=20220511:graphics/gpu-firmware-kmod \
		cloudbsd-gpu-detect:sysutils/cloudbsd-gpu-autoload

.include <bsd.port.mk>
