# CloudBSD port for REVYTECHCommander.
# Snapshot distinfo is make makesum of GitHub archive GH_TAGNAME=d546e07.
# The snapshot has Angular src under web/ and no web/dist; post-build compiles
# the SPA with Node 22 so %%DATADIR%%/web/index.html is staged.

PORTNAME=	revytechcommander
DISTVERSION=	0.1.0
CATEGORIES=	sysutils

MAINTAINER=	mark@cloudbsd.org
COMMENT=	FreeBSD-native multi-bot LLM gateway, worker, and conductor
WWW=		https://github.com/revytechinc/REVYTECHCommander

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go:1.23+,modules nodejs:22,build
USE_GITHUB=	yes
GH_ACCOUNT=	revytechinc
GH_PROJECT=	REVYTECHCommander
GH_TAGNAME=	d546e079614e70e1a6d588eac225f6f22130bdae

# Unreleased snapshot: GH_TAGNAME is commit d546e079614e70e1a6d588eac225f6f22130bdae (main).
# Switch GH_TAGNAME to a release tag when 0.1.0 is published.
# distinfo comes from make makesum against that commit's GitHub archive
# (or git archive of the same tree). Do not invent SHA256.

USE_RC_SUBR=	revytechcommander revytechcommander_gateway revytechcommander_worker revytechcommander_conductor

BUILD_DEPENDS=	npm-node22>0:www/npm-node22

# Runtime companions. These ports exist on FreeBSD; this port does not vendor
# them. databases/valkey is Redis-protocol compatible; databases/redis works
# as a drop-in if valkey is unavailable. postgresql16-server is a typical
# local writer; the client package is enough when Postgres is remote.
RUN_DEPENDS=	caddy:www/caddy \
		nats-server:net/nats-server \
		psql:databases/postgresql16-client \
		valkey-server:databases/valkey \
		nomad:sysutils/nomad \
		consul:sysutils/consul

GO_MODULE=	revytechcommander@d546e079614e70e1a6d588eac225f6f22130bdae
GO_MOD_DIST=	github
GO_TARGET=	./cmd/revytechcommander
CGO_ENABLED=	0

ETCDIR=		${PREFIX}/etc/cloudbsd/revytechcommander

# GH archive gitignores web/dist. ci-install web/ then node --run build.
post-build:
	cd ${WRKSRC}/web && ${SETENV} ${MAKE_ENV} HOME=${WRKDIR} \
		npm ci
	cd ${WRKSRC}/web && ${SETENV} ${MAKE_ENV} HOME=${WRKDIR} \
		node --run build

post-install:
	${MKDIR} ${STAGEDIR}${ETCDIR} ${STAGEDIR}${DATADIR}/web ${STAGEDIR}${DATADIR}/deploy
	${MKDIR} ${STAGEDIR}${PREFIX}/share/man/man8 ${STAGEDIR}${PREFIX}/share/man/man5
	${INSTALL_DATA} ${WRKSRC}/config.example.json ${STAGEDIR}${ETCDIR}/config.json.sample
	${INSTALL_MAN} ${WRKSRC}/share/man/man8/revytechcommander.8 ${STAGEDIR}${PREFIX}/share/man/man8
	${INSTALL_MAN} ${WRKSRC}/share/man/man5/revytechcommander.5 ${STAGEDIR}${PREFIX}/share/man/man5
	cd ${WRKSRC}/web/dist/browser && ${COPYTREE_SHARE} . ${STAGEDIR}${DATADIR}/web

	${FIND} ${STAGEDIR}${DATADIR}/web -type f ! -name index.html | \
		${SED} -e 's|^${STAGEDIR}${PREFIX}/||' >> ${TMPPLIST}
	cd ${WRKSRC}/deploy/freebsd && ${COPYTREE_SHARE} . ${STAGEDIR}${DATADIR}/deploy

.include <bsd.port.mk>
