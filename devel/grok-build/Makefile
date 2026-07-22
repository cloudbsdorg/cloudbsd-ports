PORTNAME=	grok-build
DISTVERSION=	0.2.106
# Snapshot until an official FreeBSD-ready tag exists.
PORTREVISION=	2
CATEGORIES=	devel
MASTER_SITES=	# empty until first distfile; local checkout workflow for WIP
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

# Source: developers build from a local checkout until cargo-crates offline
# packaging lands (Phase 3):
#   make GROK_SRC=/path/to/grok-build package
#   pkg install -U work/pkg/grok-build-*.pkg
#
# Default WRKSRC expects GROK_SRC. Offline CARGO_CRATES path not ready yet.
WRKSRC=		${GROK_SRC}
.if empty(GROK_SRC)
IGNORE=		set GROK_SRC to a grok-build checkout until distfiles/CARGO_CRATES land
.endif

USES=		cargo
# Local checkout builds use network cargo against the tree's Cargo.lock.
# Full CARGO_CRATES vendor is Phase 3 (see README.FreeBSD).
CARGO_CRATES=
CARGO_BUILDDEP=	yes
CARGO_BUILD=	no
CARGO_INSTALL=	no
CARGO_TEST=	no
CARGO_CONFIGURE=	no

# Offline ports builds must not fetch rg; FreeBSD skips auto-bundle in build.rs.
CARGO_ENV+=	PROTOC=${LOCALBASE}/bin/protoc \
		CARGO_HOME=${WRKDIR}/.cargo \
		CARGO_TARGET_DIR=${WRKDIR}/target

# Product CLI names: grok-build (primary), grok alias, and grok-build-static
# (second full binary — same payload, separate inode — so regression
# pkill/killall of grok-build does not kill a long-lived agent session).
PLIST_FILES=	bin/grok-build \
		bin/grok-build-static \
		bin/grok

# Prefer a prebuilt binary under the checkout (make build) so package does not
# re-fetch the world into WRKDIR. Set FORCE_CARGO_BUILD=yes to always rebuild.
.if defined(FORCE_CARGO_BUILD)
_PREBUILT_BIN=
.else
_PREBUILT_BIN=	${WRKSRC}/target/release/xai-grok-pager
.endif

do-build:
.if exists(${_PREBUILT_BIN})
	@${ECHO_MSG} "===>  Using prebuilt ${_PREBUILT_BIN}"
	@${MKDIR} ${WRKDIR}/target/release
	${INSTALL_PROGRAM} ${_PREBUILT_BIN} ${WRKDIR}/target/release/xai-grok-pager
.else
	@${ECHO_MSG} "===>  Building xai-grok-pager-bin (release) from ${WRKSRC}"
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${CARGO_ENV} \
		${CARGO} build -p xai-grok-pager-bin --release --locked
.endif

do-install:
	${INSTALL_PROGRAM} ${WRKDIR}/target/release/xai-grok-pager \
		${STAGEDIR}${PREFIX}/bin/grok-build
	# Full second copy — NOT ${RLN}. Symlinks share process image/path tricks
	# and do not protect a live session from name-based kills of grok-build.
	${INSTALL_PROGRAM} ${WRKDIR}/target/release/xai-grok-pager \
		${STAGEDIR}${PREFIX}/bin/grok-build-static
	${RLN} ${STAGEDIR}${PREFIX}/bin/grok-build ${STAGEDIR}${PREFIX}/bin/grok

.include <bsd.port.mk>
