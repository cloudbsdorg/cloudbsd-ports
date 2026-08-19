# FreeGrok — CloudBSD / RevyTech fork of open-source Grok Build
PORTNAME=	freegrok
DISTVERSION=	1.0.6
PORTREVISION=	0
CATEGORIES=	devel
MASTER_SITES=	# empty until first distfile; local checkout workflow
DISTFILES=	# empty

MAINTAINER=	mark@cloudbsd.org
COMMENT=	FreeGrok CLI (CloudBSD/RevyTech fork of Grok Build)
WWW=		https://github.com/revytechinc/freegrok

LICENSE=	APACHE20
LICENSE_FILE=	${WRKSRC}/LICENSE

CONFLICTS_INSTALL=	grok-build

BUILD_DEPENDS=	protoc:devel/protobuf \
		rust>=1.92:lang/rust
RUN_DEPENDS=	rg:textproc/ripgrep

#   make FREEGROK_SRC=/path/to/freegrok package
#   GROK_SRC is accepted as an alias.
#   pkg install -U work/pkg/freegrok-*.pkg
FREEGROK_SRC?=	${GROK_SRC}
WRKSRC=		${FREEGROK_SRC}
.if empty(WRKSRC)
IGNORE=	set FREEGROK_SRC (or GROK_SRC) to a freegrok checkout until distfiles/CARGO_CRATES land
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

PLIST_FILES=	bin/freegrok \
		bin/freegrok-static \
		bin/fg \
		bin/grok \
		bin/grok-build \
		libexec/freegrok-jail-helper \
		libexec/grok-jail-helper \
		etc/bash_completion.d/freegrok \
		share/zsh/site-functions/_freegrok \
		share/fish/vendor_completions.d/freegrok.fish \
		share/doc/freegrok/README.md \
		share/doc/freegrok/doctor.md \
		share/doc/freegrok/sandbox.md

.if defined(FORCE_CARGO_BUILD)
_PREBUILT_BIN=
.else
_PREBUILT_BIN=	${WRKSRC}/target/release/freegrok
.endif

do-build:
.if exists(${_PREBUILT_BIN})
	@${ECHO_MSG} "===>  Using prebuilt ${_PREBUILT_BIN}"
	@${MKDIR} ${WRKDIR}/target/release
	${INSTALL_PROGRAM} ${_PREBUILT_BIN} ${WRKDIR}/target/release/freegrok
.if exists(${WRKSRC}/target/release/grok-jail-helper)
	${INSTALL_PROGRAM} ${WRKSRC}/target/release/grok-jail-helper ${WRKDIR}/target/release/grok-jail-helper
.endif
.else
	@${ECHO_MSG} "===>  Building freegrok (xai-grok-pager-bin) + grok-jail-helper from ${WRKSRC}"
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${CARGO_ENV} \
		${CARGO} build -p xai-grok-pager-bin --release --locked
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} ${CARGO_ENV} \
		${CARGO} build -p xai-grok-sandbox --bin grok-jail-helper --release --locked
.endif

do-install:
	${INSTALL_PROGRAM} ${WRKDIR}/target/release/freegrok \
		${STAGEDIR}${PREFIX}/bin/freegrok
	${INSTALL_PROGRAM} ${WRKDIR}/target/release/freegrok \
		${STAGEDIR}${PREFIX}/bin/freegrok-static
	${RLN} ${STAGEDIR}${PREFIX}/bin/freegrok ${STAGEDIR}${PREFIX}/bin/fg
	${RLN} ${STAGEDIR}${PREFIX}/bin/freegrok ${STAGEDIR}${PREFIX}/bin/grok
	${RLN} ${STAGEDIR}${PREFIX}/bin/freegrok ${STAGEDIR}${PREFIX}/bin/grok-build
.if exists(${WRKDIR}/target/release/grok-jail-helper)
	${INSTALL_PROGRAM} ${WRKDIR}/target/release/grok-jail-helper \
		${STAGEDIR}${PREFIX}/libexec/grok-jail-helper
.else
	${INSTALL_PROGRAM} ${WRKSRC}/target/release/grok-jail-helper \
		${STAGEDIR}${PREFIX}/libexec/grok-jail-helper
.endif
	${RLN} ${STAGEDIR}${PREFIX}/libexec/grok-jail-helper \
		${STAGEDIR}${PREFIX}/libexec/freegrok-jail-helper
	@${MKDIR} ${STAGEDIR}${PREFIX}/etc/bash_completion.d \
		${STAGEDIR}${PREFIX}/share/zsh/site-functions \
		${STAGEDIR}${PREFIX}/share/fish/vendor_completions.d \
		${STAGEDIR}${PREFIX}/share/doc/freegrok
	${STAGEDIR}${PREFIX}/bin/freegrok completions bash \
		> ${STAGEDIR}${PREFIX}/etc/bash_completion.d/freegrok
	${STAGEDIR}${PREFIX}/bin/freegrok completions zsh \
		> ${STAGEDIR}${PREFIX}/share/zsh/site-functions/_freegrok
	${STAGEDIR}${PREFIX}/bin/freegrok completions fish \
		> ${STAGEDIR}${PREFIX}/share/fish/vendor_completions.d/freegrok.fish
	${INSTALL_DATA} ${WRKSRC}/README.md ${STAGEDIR}${PREFIX}/share/doc/freegrok/
	${INSTALL_DATA} ${WRKSRC}/crates/codegen/xai-grok-pager/docs/user-guide/25-doctor.md \
		${STAGEDIR}${PREFIX}/share/doc/freegrok/doctor.md
	${INSTALL_DATA} ${WRKSRC}/crates/codegen/xai-grok-pager/docs/user-guide/18-sandbox.md \
		${STAGEDIR}${PREFIX}/share/doc/freegrok/sandbox.md

.include <bsd.port.mk>
