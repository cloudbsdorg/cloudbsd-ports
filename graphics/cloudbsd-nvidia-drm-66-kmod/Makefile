PORTNAME=	cloudbsd-nvidia-drm-66-kmod
PORTREVISION=	0
CATEGORIES=	graphics

RUN_DEPENDS+=	cloudbsd-drm-66-core-kmod>0:graphics/cloudbsd-drm-66-core-kmod

CONFLICTS_INSTALL=	nvidia-drm-515-kmod* \
			nvidia-drm-61-kmod* \
			nvidia-drm-66-kmod* \
			nvidia-drm-612-kmod* \
			nvidia-drm-latest-kmod* \
			cloudbsd-nvidia-drm-515-kmod* \
			cloudbsd-nvidia-drm-61-kmod* \
			cloudbsd-nvidia-drm-612-kmod* \
			cloudbsd-nvidia-drm-latest-kmod*

.include "${.CURDIR}/../cloudbsd-drm-66-kmod/Makefile.version"
.include "${.CURDIR}/../cloudbsd-nvidia-drm-kmod/Makefile.common"

.include <bsd.port.mk>
