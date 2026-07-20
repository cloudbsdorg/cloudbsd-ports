PORTNAME=	cloudbsd-drm-kmod
PORTVERSION=	20260719
CATEGORIES=	graphics

MAINTAINER=	ports@cloudbsd.org
COMMENT=	CloudBSD DRM GPU drivers metaport (install all vendors)
WWW=		https://github.com/cloudbsdorg/cloudbsd-ports

USES=		metaport

RUN_DEPENDS=	gpu-firmware-kmod>=20220511:graphics/gpu-firmware-kmod \
		cloudbsd-gpu-detect:sysutils/cloudbsd-gpu-autoload

.include <bsd.port.options.mk>

.if ${OPSYS} != FreeBSD
IGNORE=		not supported on anything but FreeBSD (missing linuxkpi functionality)
.else
.  if ${OSVERSION} >= 1500509 && ${ARCH} == amd64
RUN_DEPENDS+=	cloudbsd-drm-612-kmod>=0:graphics/cloudbsd-drm-612-kmod
_DRM_ARCHS=	amd64
.  elif ${OSVERSION} >= 1500031 && ${ARCH} == amd64
RUN_DEPENDS+=	cloudbsd-drm-66-kmod>=0:graphics/cloudbsd-drm-66-kmod
_DRM_ARCHS=	amd64
.  else
RUN_DEPENDS+=	cloudbsd-drm-61-kmod>=0:graphics/cloudbsd-drm-61-kmod
_DRM_ARCHS=	amd64 powerpc64 powerpc64le
.  endif
.  if ! ${_DRM_ARCHS:M${ARCH}}
IGNORE=		not supported for this configuration
.  endif
.endif

.include <bsd.port.mk>
