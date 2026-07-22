PORTNAME=	grok
DISTVERSION=	0.1.220.a4
CATEGORIES=	devel

MAINTAINER=	mark@cloudbsd.org
COMMENT=	SpaceXAI terminal AI coding agent (Grok Build)
WWW=		https://x.ai/cli

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/LICENSE

# System protoc for prost codegen; system rg (build.rs skips bundling on FreeBSD).
BUILD_DEPENDS=	protoc:devel/protobuf
RUN_DEPENDS=	rg:textproc/ripgrep

USES=		cargo ssl
USE_GITHUB=	yes
GH_ACCOUNT=	revytechinc
GH_PROJECT=	grok-build
# freebsd-port-plan tip with FreeBSD rg-skip + jail stubs
GH_TAGNAME=	981f8c65ca22419be474fb2f56f9d6bcde4cf8e0

# Workspace binary package
CARGO_INSTALL_PATH=	crates/codegen/xai-grok-pager-bin

# Prefer system protoc over bin/protoc (dotslash; no FreeBSD asset).
MAKE_ENV+=	PROTOC=${LOCALBASE}/bin/protoc
CARGO_ENV+=	PROTOC=${LOCALBASE}/bin/protoc

# Binary from [[bin]] is xai-grok-pager; ship as grok.
PLIST_FILES=	bin/grok

post-install:
	${MV} ${STAGEDIR}${PREFIX}/bin/xai-grok-pager \
		${STAGEDIR}${PREFIX}/bin/grok

.include <bsd.port.mk>
