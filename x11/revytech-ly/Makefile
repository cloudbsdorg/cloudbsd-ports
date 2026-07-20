.include "${.CURDIR}/../../revytech/wayfire/Makefile.inc"

PORTNAME=	revytech-ly
# ly product line (Zig 0.16); not the Wayfire 0.11 product version
DISTVERSION=	1.5.0.20260720
CATEGORIES=	x11 wayland

MAINTAINER=	${REVYTECH_MAINTAINER}
COMMENT=	REVYTECH Ly TUI display manager (FreeBSD + Wayfire stack)
WWW=		https://github.com/revytechinc/ly

LICENSE=	WTFPL
LICENSE_FILE=	${WRKSRC}/license.md

CONFLICTS_INSTALL=	ly

# Ly hardcodes $config_directory/ly (not PORTNAME)
ETCDIR=		${PREFIX}/etc/ly

# Full session stack: Wayfire desktop + seatd + X auth for X11 sessions
RUN_DEPENDS=	revytech-wayfire>0:x11-wm/revytech-wayfire \
		revytech-wf-shell>0:x11/revytech-wf-shell \
		seatd>0:sysutils/seatd \
		xauth:x11/xauth

USES=		zig pkgconfig xorg
USE_XORG=	xcb
USE_GITHUB=	yes
GH_ACCOUNT=	${REVYTECH_GH_ACCOUNT}
GH_PROJECT=	ly
GH_TAGNAME=	${REVYTECH_SHA_LY}

# pkg-install / pkg-deinstall in ${.CURDIR} auto-configure (and restore) /etc
# FreeBSD installexe equivalent via zig flags + post-install asset copy
ZIG_ARGS=	-Dprefix_directory="${PREFIX}" \
		-Dconfig_directory="${PREFIX}/etc" \
		-Dinit_system=freebsd

# Zig default install only stages the binary; post-install does the rest
post-install:
# FreeBSD getty wrapper (ignores login -fp args)
	${REINPLACE_CMD} 's,$$PREFIX_DIRECTORY,${PREFIX},g ; s,$$EXECUTABLE_NAME,ly,g' \
		${WRKSRC}/res/ly-freebsd-wrapper
	${INSTALL_SCRIPT} ${WRKSRC}/res/ly-freebsd-wrapper ${STAGEDIR}${PREFIX}/bin/ly_wrapper
# OpenPAM configs
	${MKDIR} ${STAGEDIR}${PREFIX}/etc/pam.d
	${INSTALL_DATA} ${WRKSRC}/res/pam.d/ly-freebsd \
		${STAGEDIR}${PREFIX}/etc/pam.d/ly
	${INSTALL_DATA} ${WRKSRC}/res/pam.d/ly-freebsd-autologin \
		${STAGEDIR}${PREFIX}/etc/pam.d/ly-autologin
# Config directory: samples + live setup helpers
	${MKDIR} ${STAGEDIR}${ETCDIR}/lang ${STAGEDIR}${ETCDIR}/custom-sessions
	${REINPLACE_CMD} 's,$$PREFIX_DIRECTORY,${PREFIX},g; \
		s,$$CONFIG_DIRECTORY,${PREFIX}/etc,g ; \
		s,^brightness_down_cmd = .*,brightness_down_cmd = null, ; \
		s,^brightness_up_cmd = .*,brightness_up_cmd = null, ; \
		s,$$PLATFORM_SHUTDOWN_ARG,-p,g' \
		${WRKSRC}/res/config.ini
	${INSTALL_DATA} ${WRKSRC}/res/config.ini ${STAGEDIR}${ETCDIR}/config.ini.sample
	${INSTALL_DATA} ${WRKSRC}/res/config.ini ${STAGEDIR}${ETCDIR}/config.ini.example
	${REINPLACE_CMD} 's,"$$CONFIG_DIRECTORY"/profile,/etc/profile,g ; \
		s,$$CONFIG_DIRECTORY/csh.login,/etc/csh.login,g ; \
		s,"$$CONFIG_DIRECTORY",${PREFIX}/etc,g ;' \
		${WRKSRC}/res/setup.sh
	${INSTALL_SCRIPT} ${WRKSRC}/res/setup.sh ${STAGEDIR}${ETCDIR}/setup.sh
	${INSTALL_SCRIPT} ${WRKSRC}/res/setup.sh ${STAGEDIR}${ETCDIR}/setup.sh.sample
	${INSTALL_SCRIPT} ${WRKSRC}/res/startup.sh ${STAGEDIR}${ETCDIR}/startup.sh
	${INSTALL_DATA} ${WRKSRC}/res/example.dur ${STAGEDIR}${ETCDIR}/example.dur
	${INSTALL_DATA} ${WRKSRC}/res/example.lua ${STAGEDIR}${ETCDIR}/example.lua
	${INSTALL_DATA} ${WRKSRC}/res/custom-sessions/README ${STAGEDIR}${ETCDIR}/custom-sessions/
	${INSTALL_DATA} ${FILESDIR}/wayfire.desktop ${STAGEDIR}${ETCDIR}/custom-sessions/
	${INSTALL_DATA} ${WRKSRC}/res/lang/*.ini ${STAGEDIR}${ETCDIR}/lang/
# System integration helpers
	${MKDIR} ${STAGEDIR}${EXAMPLESDIR}
	${INSTALL_DATA} ${FILESDIR}/gettytab.ly ${STAGEDIR}${EXAMPLESDIR}/
	${INSTALL_DATA} ${FILESDIR}/ttys.snippet ${STAGEDIR}${EXAMPLESDIR}/
	${INSTALL_SCRIPT} ${FILESDIR}/revytech-ly-enable ${STAGEDIR}${PREFIX}/sbin/revytech-ly-enable

.include <bsd.port.mk>
