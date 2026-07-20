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
# Mirror stock drm-kmod version selection with CloudBSD split stacks.
# 612 line is not yet split in CloudBSD; use 66 until cloudbsd-drm-612-* exists.
.  if ${OSVERSION} >= 1500031 && ${ARCH} == amd64
RUN_DEPENDS+=	cloudbsd-drm-66-kmod>=0:graphics/cloudbsd-drm-66-kmod
_DRM_ARCHS=	amd64
.  else
IGNORE=		CloudBSD DRM split stack currently requires FreeBSD >= 1500031 amd64 (drm 6.6 line)
.  endif
.  if !empty(_DRM_ARCHS) && ! ${_DRM_ARCHS:M${ARCH}}
IGNORE=		not supported for this configuration
.  endif
.endif

.include <bsd.port.mk>
