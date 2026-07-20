PORTNAME=	cloudbsd-drm-61-kmod
PORTVERSION=	${DRM_KMOD_DISTVERSION}
PORTREVISION=	0
CATEGORIES=	graphics

MAINTAINER=	ports@cloudbsd.org
COMMENT=	CloudBSD DRM 61 full stack (all vendors) metaport
WWW=		https://github.com/freebsd/drm-kmod/

.include "Makefile.version"

USES=		metaport

RUN_DEPENDS=	cloudbsd-drm-61-core-kmod>0:graphics/cloudbsd-drm-61-core-kmod \
		cloudbsd-drm-61-amdgpu-kmod>0:graphics/cloudbsd-drm-61-amdgpu-kmod \
		cloudbsd-drm-61-i915-kmod>0:graphics/cloudbsd-drm-61-i915-kmod \
		cloudbsd-drm-61-radeon-kmod>0:graphics/cloudbsd-drm-61-radeon-kmod \
		cloudbsd-nvidia-drm-61-kmod>0:graphics/cloudbsd-nvidia-drm-61-kmod \
		gpu-firmware-kmod>=20220511:graphics/gpu-firmware-kmod \
		cloudbsd-gpu-detect:sysutils/cloudbsd-gpu-autoload

.include <bsd.port.mk>
