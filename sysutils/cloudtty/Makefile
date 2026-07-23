PORTNAME=	cloudtty
DISTVERSION=	0.1.0
CATEGORIES=	sysutils

MAINTAINER=	ports@cloudbsd.org
COMMENT=	ESXi-style FreeBSD TTY login and console menu (CloudBSD)
WWW=		https://github.com/cloudbsd/cloudtty

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

# OpenPAM is base; ratatui needs a usable VT with Unicode-capable fonts.
# Supported locales (en-US, fr-FR) need Latin VT coverage; unifont/dejavu
# widen glyph coverage for additional scripts as locales grow.
RUN_DEPENDS=	${LOCALBASE}/share/fonts/spleen/spleen-8x16.fnt:x11-fonts/spleen \
		${LOCALBASE}/share/fonts/dejavu/DejaVuSansMono.ttf:x11-fonts/dejavu \
		${LOCALBASE}/share/fonts/gnu-unifont/unifont.pcf.gz:x11-fonts/gnu-unifont

USES=		cargo
CARGO_INSTALL_PATH=	crates/cloudtty

# --- Dist source -----------------------------------------------------------
# Lab / pre-release: set CLOUDTTY_DISTDIR to a directory containing
#   cloudtty-${DISTVERSION}.tar.gz  (top-level dir must be ${DISTNAME}/)
# Production: GitHub tag v${DISTVERSION}.
.if defined(CLOUDTTY_DISTDIR)
MASTER_SITES=	file://${CLOUDTTY_DISTDIR}/
DISTFILES=	${DISTNAME}${EXTRACT_SUFX}
NO_CHECKSUM=	yes
.else
USE_GITHUB=	yes
GH_ACCOUNT=	cloudbsd
GH_PROJECT=	cloudtty
GH_TAGNAME=	v${DISTVERSION}
.endif

PLIST_FILES=	bin/cloudtty \
		libexec/cloudtty-console \
		"@sample etc/cloudtty/config.json.sample" \
		etc/cloudtty/templates/admin-menu.json \
		etc/cloudtty/locales/en-US/cloudtty.ftl \
		etc/cloudtty/locales/fr-FR/cloudtty.ftl \
		etc/pam.d/cloudtty \
		share/examples/cloudtty/gettytab.cloudtty \
		share/examples/cloudtty/ttys.cloudtty \
		share/examples/cloudtty/loader.conf.cloudtty \
		share/doc/cloudtty/console-ux.md \
		share/doc/cloudtty/freebsd-lab.md \
		share/doc/cloudtty/README-install.md

SUB_FILES=	pkg-message
SUB_LIST=	PREFIX=${PREFIX}

post-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/libexec \
		${STAGEDIR}${PREFIX}/etc/cloudtty/templates \
		${STAGEDIR}${PREFIX}/etc/cloudtty/locales/en-US \
		${STAGEDIR}${PREFIX}/etc/cloudtty/locales/fr-FR \
		${STAGEDIR}${PREFIX}/etc/pam.d \
		${STAGEDIR}${EXAMPLESDIR} \
		${STAGEDIR}${DOCSDIR}
	${INSTALL_SCRIPT} ${WRKSRC}/res/cloudtty-wrapper \
		${STAGEDIR}${PREFIX}/libexec/cloudtty-console
	${INSTALL_DATA} ${WRKSRC}/res/config.example.json \
		${STAGEDIR}${PREFIX}/etc/cloudtty/config.json.sample
	${INSTALL_DATA} ${WRKSRC}/res/templates/admin-menu.json \
		${STAGEDIR}${PREFIX}/etc/cloudtty/templates/
	${INSTALL_DATA} ${WRKSRC}/res/locales/en-US/cloudtty.ftl \
		${STAGEDIR}${PREFIX}/etc/cloudtty/locales/en-US/
	${INSTALL_DATA} ${WRKSRC}/res/locales/fr-FR/cloudtty.ftl \
		${STAGEDIR}${PREFIX}/etc/cloudtty/locales/fr-FR/
	${INSTALL_DATA} ${WRKSRC}/res/pam.d/cloudtty \
		${STAGEDIR}${PREFIX}/etc/pam.d/cloudtty
	${INSTALL_DATA} ${WRKSRC}/res/gettytab.cloudtty \
		${WRKSRC}/res/ttys.cloudtty \
		${WRKSRC}/res/loader.conf.cloudtty \
		${STAGEDIR}${EXAMPLESDIR}/
	${INSTALL_DATA} ${WRKSRC}/docs/console-ux.md \
		${WRKSRC}/docs/freebsd-lab.md \
		${WRKSRC}/res/README-install.md \
		${STAGEDIR}${DOCSDIR}/

.include <bsd.port.mk>
