# Open-source Grok Build (CloudBSD / RevyTech FreeBSD WIP)
PORTNAME=	grok-build
DISTVERSION=	1.0.1
PORTREVISION=	0
CATEGORIES=	devel
MASTER_SITES=	# empty until first distfile; local checkout workflow
DISTFILES=	# empty

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Open-source Grok Build CLI (CloudBSD/RevyTech FreeBSD WIP)
WWW=		https://github.com/revytechinc/grok-build

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	protoc:devel/protobuf \
	${RUST_DEFAULT}>=1.92:lang/rust
RUN_DEPENDS=	rg:textproc/ripgrep

#   make GROK_SRC=/path/to/grok-build package
#   pkg install -U work/pkg/grok-build-*.pkg
WRKSRC=		${GROK_SRC}
.if empty(GROK_SRC)
IGNORE=		set GROK_SRC to a grok-build checkout until distfiles/CARGO_CRATES land
.endif

USES=		cargo
CARGO_CRATES=
CARGO_BUILDDEP=	yes
CARGO_BUILD=	no
CARGO_INSTALL=	no
CARGO_TEST=	no
CARGO_CONFIGURE=	no

CARGO_ENV+=	PROTOC=${LOCALBASE}/bin/protoc \
	CARGO_HOME=${WRKDIR}/.cargo \
	CARGO_TARGET_DIR=${WRKDIR}/target

PLIST_FILES=	bin/grok-build \
	bin/grok-build-static \
	bin/grok \
	libexec/grok-jail-helper \
	etc/bash_completion.d/grok-build \
	share/zsh/site-functions/_grok-build \
	share/fish/vendor_completions.d/grok-build.fish \
	share/doc/grok-build/README.md \
	share/doc/grok-build/doctor.md \
	share/doc/grok-build/sandbox.md

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
.if exists(${WRKSRC}/target/release/grok-jail-helper)
	${INSTALL_PROGRAM} ${WRKSRC}/target/release/grok-jail-helper ${WRKDIR}/target/release/grok-jail-helper
.endif
.else
	@${ECHO_MSG} "===>  Building xai-grok-pager-bin + grok-jail-helper (release) from ${WRKSRC}"
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${CARGO_ENV} \
	${CARGO} build -p xai-grok-pager-bin --release --locked
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${CARGO_ENV} \
		${CARGO} build -p xai-grok-sandbox --bin grok-jail-helper --release --locked
.endif

do-install:
	${INSTALL_PROGRAM} ${WRKDIR}/target/release/xai-grok-pager \
	${STAGEDIR}${PREFIX}/bin/grok-build
	${INSTALL_PROGRAM} ${WRKDIR}/target/release/xai-grok-pager \
	${STAGEDIR}${PREFIX}/bin/grok-build-static
	${RLN} ${STAGEDIR}${PREFIX}/bin/grok-build ${STAGEDIR}${PREFIX}/bin/grok
.if exists(${WRKDIR}/target/release/grok-jail-helper)
	${INSTALL_PROGRAM} ${WRKDIR}/target/release/grok-jail-helper \
	${STAGEDIR}${PREFIX}/libexec/grok-jail-helper
.else
	${INSTALL_PROGRAM} ${WRKSRC}/target/release/grok-jail-helper \
	${STAGEDIR}${PREFIX}/libexec/grok-jail-helper
.endif
	@${MKDIR} ${STAGEDIR}${PREFIX}/etc/bash_completion.d \
	${STAGEDIR}${PREFIX}/share/zsh/site-functions \
	${STAGEDIR}${PREFIX}/share/fish/vendor_completions.d \
	${STAGEDIR}${PREFIX}/share/doc/grok-build
	${STAGEDIR}${PREFIX}/bin/grok-build completions bash | ${SED} 's/grok/grok-build/g' \
	> ${STAGEDIR}${PREFIX}/etc/bash_completion.d/grok-build
	${STAGEDIR}${PREFIX}/bin/grok-build completions zsh | ${SED} 's/grok/grok-build/g' \
	> ${STAGEDIR}${PREFIX}/share/zsh/site-functions/_grok-build
	${STAGEDIR}${PREFIX}/bin/grok-build completions fish | ${SED} 's/grok/grok-build/g' \
	> ${STAGEDIR}${PREFIX}/share/fish/vendor_completions.d/grok-build.fish
	${INSTALL_DATA} ${WRKSRC}/README.md ${STAGEDIR}${PREFIX}/share/doc/grok-build/
	${INSTALL_DATA} ${WRKSRC}/crates/codegen/xai-grok-pager/docs/user-guide/25-doctor.md \
	${STAGEDIR}${PREFIX}/share/doc/grok-build/doctor.md
	${INSTALL_DATA} ${WRKSRC}/crates/codegen/xai-grok-pager/docs/user-guide/18-sandbox.md \
	${STAGEDIR}${PREFIX}/share/doc/grok-build/sandbox.md

.include <bsd.port.mk>
