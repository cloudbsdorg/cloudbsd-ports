PORTNAME=	cloudbsd-drm-latest-kmod
DISTVERSION=	${DRM_KMOD_DISTVERSION}
PORTREVISION=	0
CATEGORIES=	graphics

MAINTAINER=	ports@cloudbsd.org
COMMENT=	CloudBSD DRM latest full stack (all vendors) metaport
WWW=		https://github.com/freebsd/drm-kmod/

.include "Makefile.version"

USES=		metaport

RUN_DEPENDS=	cloudbsd-drm-latest-core-kmod>0:graphics/cloudbsd-drm-latest-core-kmod \
		cloudbsd-drm-latest-amdgpu-kmod>0:graphics/cloudbsd-drm-latest-amdgpu-kmod \
		cloudbsd-drm-latest-i915-kmod>0:graphics/cloudbsd-drm-latest-i915-kmod \
		cloudbsd-drm-latest-radeon-kmod>0:graphics/cloudbsd-drm-latest-radeon-kmod \
		cloudbsd-nvidia-drm-latest-kmod>0:graphics/cloudbsd-nvidia-drm-latest-kmod \
		gpu-firmware-kmod>=20220511:graphics/gpu-firmware-kmod \
		cloudbsd-gpu-detect:sysutils/cloudbsd-gpu-autoload

.include <bsd.port.mk>
