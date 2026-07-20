PORTNAME=	grok-build
DISTVERSION=	0.2.106
# Snapshot until an official FreeBSD-ready tag exists. Pin to the FreeBSD plan branch.
PORTREVISION=	0
CATEGORIES=	devel
# Prefer GH for now; ports offline build will need a release tarball / cargo crates list later.
MASTER_SITES=	# empty until first distfile; local GH clone workflow for WIP
DISTFILES=	# empty

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Grok Build: SpaceXAI terminal AI coding agent (FreeBSD WIP)
WWW=		https://x.ai/cli

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/LICENSE

# Runtime: system ripgrep (do not bundle/download BurntSushi FreeBSD assets).
# Build: rust + protoc.
BUILD_DEPENDS=	protoc:devel/protobuf \
		${RUST_DEFAULT}>=1.92:lang/rust
RUN_DEPENDS=	rg:textproc/ripgrep

USES=		cargo
# Source: until crates.io/GH release, developers build from a local checkout:
#   make GROK_SRC=/path/to/grok-build
# Default WRKSRC expects a fetched distfile — for WIP we document local build.
WRKSRC?=	${GROK_SRC}
.if empty(GROK_SRC)
IGNORE=		set GROK_SRC to a grok-build checkout (branch freebsd-port-plan) until distfiles land
.endif

CARGO_INSTALL_PATH=	crates/codegen/xai-grok-pager-bin
CARGO_BUILDDEP=	yes
# Offline ports builds must not fetch rg; FreeBSD skips auto-bundle in build.rs.
CARGO_ENV+=	PROTOC=${LOCALBASE}/bin/protoc

# Binary is named xai-grok-pager; install as grok to match product name.
PLIST_FILES=	bin/grok

do-install:
	${INSTALL_PROGRAM} ${CARGO_TARGET_DIR}/release/xai-grok-pager \
		${STAGEDIR}${PREFIX}/bin/grok

.include <bsd.port.mk>
