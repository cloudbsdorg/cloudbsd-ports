PORTNAME=	hawkeye
DISTVERSION=	0.1.0
CATEGORIES=	sysutils

MAINTAINER=	mark@cloudbsd.org
COMMENT=	FreeBSD diagnostic and operations doctor (MASH)
WWW=		https://github.com/revytechinc/hawkeye

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go:1.25+,modules
USE_GITHUB=	yes
GH_ACCOUNT=	revytechinc
GH_PROJECT=	hawkeye
GH_TAGNAME=	54e790fa4248b5498ee988c6d41378e563ae5684

GO_MODULE=	github.com/revytechinc/hawkeye@54e790fa4248b5498ee988c6d41378e563ae5684
GO_MOD_DIST=	github
GO_TARGET=	./cmd/hawkeye
CGO_ENABLED=	0

# Unreleased snapshot: GH_TAGNAME is commit 54e790fa4248b5498ee988c6d41378e563ae5684 (hawkeye main).
# Switch MASTER_SITES/GH_TAGNAME to a release tag when 0.1.0 is published.

# This port ships the hawkeye binary, man pages, sample JSON config, and
# rc.d script only. The diagnostic knowledge corpus is the sibling
# repository/port hawkeye-data (https://github.com/revytechinc/hawkeye-data).
# Do not vendor that corpus here.

USE_RC_SUBR=	hawkeye

PLIST_FILES=	bin/hawkeye \
		etc/cloudbsd/hawkeye/config.json.sample \
		share/man/man8/hawkeye.8.gz \
		share/man/man5/hawkeye.conf.5.gz

post-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/etc/cloudbsd/hawkeye
	${INSTALL_DATA} ${WRKSRC}/configs/config.example.json \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/hawkeye/config.json.sample
	${MKDIR} ${STAGEDIR}${PREFIX}/share/man/man8
	${MKDIR} ${STAGEDIR}${PREFIX}/share/man/man5
	${INSTALL_MAN} ${WRKSRC}/man/hawkeye.8 ${STAGEDIR}${PREFIX}/share/man/man8
	${INSTALL_MAN} ${WRKSRC}/man/hawkeye.conf.5 ${STAGEDIR}${PREFIX}/share/man/man5

.include <bsd.port.mk>
