PORTNAME=	MDWeb
DISTVERSION=	1.0.0
CATEGORIES=	www

MAINTAINER=	mark@cloudbsd.org
COMMENT=	MarkDownWeb (MDWeb) dynamic blogging platform
WWW=		https://github.com/marklapointe/freebsdguy

LICENSE=	MIT

BUILD_DEPENDS=	npm:www/npm-node24\
		node:www/node24
RUN_DEPENDS=	node:www/node24

USE_GITHUB=	release
GH_ACCOUNT=	marklapointe
GH_PROJECT=	freebsdguy
GH_TAGNAME=	${DISTVERSION}

USES=		nodejs:run

NO_ARCH=	yes

USE_RC_SUBR=	mdweb

do-build:
	(cd ${WRKSRC} && npm install && npm run build)

do-install:
	${MKDIR} ${STAGEDIR}${WWWDIR}
	(cd ${WRKSRC}/dist && ${COPYTREE_SHARE} . ${STAGEDIR}${WWWDIR})
	${MKDIR} ${STAGEDIR}${WWWDIR}/server
	(cd ${WRKSRC}/server && ${COPYTREE_SHARE} . ${STAGEDIR}${WWWDIR}/server)
	${INSTALL_DATA} ${WRKSRC}/package.json ${STAGEDIR}${WWWDIR}
	${INSTALL_DATA} ${WRKSRC}/package-lock.json ${STAGEDIR}${WWWDIR}
	${MKDIR} ${STAGEDIR}${WWWDIR}/node_modules
	(cd ${WRKSRC}/node_modules && ${COPYTREE_SHARE} . ${STAGEDIR}${WWWDIR}/node_modules)
	${INSTALL_MAN} ${WRKSRC}/mdweb.1 ${STAGEDIR}${PREFIX}/share/man/man1

.include <bsd.port.mk>
