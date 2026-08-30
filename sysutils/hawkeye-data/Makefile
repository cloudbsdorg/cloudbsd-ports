PORTNAME=	hawkeye-data
DISTVERSION=	0.1.0
CATEGORIES=	sysutils

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Offline knowledge kit for Hawkeye (FTS playbooks)
WWW=		https://github.com/revytechinc/hawkeye-data

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

USE_GITHUB=	yes
GH_ACCOUNT=	revytechinc
GH_PROJECT=	hawkeye-data
GH_TAGNAME=	ff1688e1faef215b71042848c6e0d065660271d1

# Unreleased snapshot: GH_TAGNAME is commit ff1688e1faef215b71042848c6e0d065660271d1 (hawkeye-data main).

# Sibling of sysutils/hawkeye (binaries). This port is data only.
# hawkeye is the sibling binary; see pkg-message. Not a RUN_DEPENDS to
# avoid a hard cycle with the doctor that consumes this corpus.
NO_ARCH=	yes
NO_BUILD=	yes

# pkg copy. Rescue copy is /boot/hawkeye (see pkg-message); not installed by default.
DATADIR=	${PREFIX}/share/hawkeye

do-install:
	${MKDIR} ${STAGEDIR}${DATADIR}/playbooks \
		${STAGEDIR}${DATADIR}/schema \
		${STAGEDIR}${DATADIR}/docs
	${INSTALL_DATA} ${WRKSRC}/share/knowledge.sqlite ${STAGEDIR}${DATADIR}
	${INSTALL_DATA} ${WRKSRC}/schema/knowledge.sql ${STAGEDIR}${DATADIR}/schema
	${INSTALL_DATA} ${WRKSRC}/README.md ${STAGEDIR}${DATADIR}
	cd ${WRKSRC}/playbooks && ${COPYTREE_SHARE} . ${STAGEDIR}${DATADIR}/playbooks
	cd ${WRKSRC}/docs && ${COPYTREE_SHARE} . ${STAGEDIR}${DATADIR}/docs

.include <bsd.port.mk>
