PORTNAME=	cloudbsd-gpu-autoload
PORTVERSION=	0.1.0
CATEGORIES=	sysutils

MAINTAINER=	ports@cloudbsd.org
COMMENT=	Detect PCI GPUs and optionally load CloudBSD DRM modules
WWW=		https://github.com/cloudbsdorg/cloudbsd-ports

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${FILESDIR}/LICENSE

NO_ARCH=	yes
NO_BUILD=	yes

USE_RC_SUBR=	cloudbsd_gpu

PLIST_FILES=	bin/cloudbsd-gpu-detect \
		etc/rc.conf.d/cloudbsd_gpu.sample \
		share/examples/cloudbsd-gpu/loader.conf.sample \
		share/examples/cloudbsd-gpu/rc.conf.sample

do-install:
	${INSTALL_SCRIPT} ${FILESDIR}/cloudbsd-gpu-detect \
		${STAGEDIR}${PREFIX}/bin/cloudbsd-gpu-detect
	${MKDIR} ${STAGEDIR}${PREFIX}/share/examples/cloudbsd-gpu \
		${STAGEDIR}${PREFIX}/etc/rc.conf.d
	${INSTALL_DATA} ${FILESDIR}/examples/loader.conf.sample \
		${STAGEDIR}${PREFIX}/share/examples/cloudbsd-gpu/
	${INSTALL_DATA} ${FILESDIR}/examples/rc.conf.sample \
		${STAGEDIR}${PREFIX}/share/examples/cloudbsd-gpu/
	${INSTALL_DATA} ${FILESDIR}/examples/rc.conf.sample \
		${STAGEDIR}${PREFIX}/etc/rc.conf.d/cloudbsd_gpu.sample

.include <bsd.port.mk>
