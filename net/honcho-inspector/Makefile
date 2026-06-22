PORTNAME=	honcho-inspector
DISTVERSION=	0.1.0
DISTVERSIONSUFFIX=	-SNAPSHOT
CATEGORIES=	net java
MASTER_SITES=	https://github.com/cloudbsdorg/honcho-inspector-backend/releases/download/v${PORTVERSION}/
EXTRACT_SUFX=	.jar

MAINTAINER=	revytechinc@gmail.com
COMMENT=	Multi-tenant Honcho workspace inspector with admin RBAC
WWW=		https://github.com/cloudbsdorg/honcho-inspector-backend

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		java
JAVA_VERSION=	25+
USE_RC_SUBR=	honcho_inspector

NO_ARCH=	yes
NO_BUILD=	yes
SUB_FILES=	honcho_inspector
SUB_LIST=	WWWOWN=${WWWOWN} \
		WWWGRP=${WWWGRP} \
		ETCDIR=${ETCDIR} \
		JAVASHAREDIR=${JAVASHAREDIR}

NO_WRKSUBDIR=	yes

PLIST_FILES=	"@sample ${ETCDIR}/application.yml.sample" \
		"@sample ${ETCDIR}/honcho-inspector.env.sample" \
		bin/honcho-inspector \
		${JAVASHAREDIR}/${PORTNAME}/${PORTNAME}.jar \
		share/man/man1/honcho-inspector.1.gz
PLIST_SUB+=	${SUB_LIST}

do-install:
	${MKDIR} ${STAGEDIR}${ETCDIR}
	${MKDIR} ${STAGEDIR}${JAVASHAREDIR}/${PORTNAME}
	${MKDIR} ${STAGEDIR}${PREFIX}/bin
	${MKDIR} ${STAGEDIR}${PREFIX}/share/man/man1
	${INSTALL_DATA} ${DISTDIR}/${DISTFILES} \
		${STAGEDIR}${JAVASHAREDIR}/${PORTNAME}/${PORTNAME}.jar
	${INSTALL_DATA} ${FILESDIR}/application.yml \
		${STAGEDIR}${ETCDIR}/application.yml.sample
	${INSTALL_DATA} ${FILESDIR}/honcho-inspector.env \
		${STAGEDIR}${ETCDIR}/honcho-inspector.env.sample
	${INSTALL_SCRIPT} ${FILESDIR}/../bin/honcho-inspector \
		${STAGEDIR}${PREFIX}/bin/honcho-inspector
	${INSTALL_MAN} ${FILESDIR}/../docs/honcho-inspector.1 \
		${STAGEDIR}${PREFIX}/share/man/man1/honcho-inspector.1

post-install:
	@${MKDIR} ${STAGEDIR}/var/db/${PORTNAME}
	@${MKDIR} ${STAGEDIR}/var/log/${PORTNAME}
	@${CHOWN} -R ${WWWOWN}:${WWWGRP} ${STAGEDIR}/var/db/${PORTNAME}
	@${CHOWN} -R ${WWWOWN}:${WWWGRP} ${STAGEDIR}/var/log/${PORTNAME}
	@${ECHO_MSG} ""
	@${ECHO_MSG} "================================================================"
	@${ECHO_MSG} "Honcho Inspector installed."
	@${ECHO_MSG} "  - enable:    sysrc honcho_inspector_enable=YES"
	@${ECHO_MSG} "  - configure: edit ${ETCDIR}/application.yml"
	@${ECHO_MSG} "  - secret:    edit ${ETCDIR}/honcho-inspector.env"
	@${ECHO_MSG} "                  (set HONCHO_CRYPTO_KEY to a stable value)"
	@${ECHO_MSG} "  - start:     service honcho_inspector start"
	@${ECHO_MSG} "  - logs:      tail -F /var/log/honcho-inspector/honcho-inspector-backend.log"
	@${ECHO_MSG} "================================================================"
	@${ECHO_MSG} ""

.include <bsd.port.mk>
