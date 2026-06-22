PORTNAME=	honcho-inspector
PORTVERSION=	0.1.0
PORTREVISION=	0
CATEGORIES=	www
MASTER_SITES=	# empty: meta-package, no DISTFILES
DISTFILES=	# empty

MAINTAINER=	mlapointe@revyt.com
COMMENT=	Meta-package: Honcho Inspector backend + frontend (web UI)

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKDIR}/LICENSE

NO_BUILD=	yes
NO_INSTALL=	yes
NO_ARCH=	yes
NO_MTREE=	yes

RUN_DEPENDS=	${LOCALBASE}/etc/rc.d/honcho_inspector:net/honcho-inspector \
		${LOCALBASE}/etc/rc.d/honcho_inspector_frontend:www/honcho-inspector-frontend

USES=		metaport

.include <bsd.port.mk>
