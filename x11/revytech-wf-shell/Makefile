.include "${.CURDIR}/../../revytech/wayfire/Makefile.inc"

PORTNAME=	revytech-wf-shell
DISTVERSION=	${REVYTECH_DISTVERSION}
CATEGORIES=	x11 wayland

MAINTAINER=	${REVYTECH_MAINTAINER}
COMMENT=	REVYTECH GTK4 panel/dock/settings for Wayfire (FreeBSD)
WWW=		https://github.com/revytechinc/wf-shell

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

CONFLICTS_INSTALL=	wf-shell wf-shell-nopulse

BUILD_DEPENDS=	wayland-protocols>0:graphics/wayland-protocols \
		revytech-wayfire>0:x11-wm/revytech-wayfire
LIB_DEPENDS=	libdbusmenu-glib.so:devel/libdbusmenu \
		libinotify.so:devel/libinotify \
		libyyjson.so:devel/yyjson \
		libwayland-client.so:graphics/wayland \
		libepoxy.so:graphics/libepoxy \
		libxkbregistry.so:x11/libxkbcommon \
		libgtk-4.so:x11-toolkits/gtk4 \
		libgtk4-layer-shell.so:x11-toolkits/gtk4-layer-shell \
		libdrm.so:graphics/libdrm \
		libwf-config.so:devel/revytech-wf-config
RUN_DEPENDS=	wayland-logout:x11/wayland-logout \
	curl:ftp/curl \
	revytech-wayfire>0:x11-wm/revytech-wayfire

USES=		compiler:c++17-lang gnome meson pkgconfig
CXXFLAGS+=	-I${LOCALBASE}/include/libdrm
USE_GITHUB=	yes
GH_ACCOUNT=	${REVYTECH_GH_ACCOUNT}
GH_PROJECT=	wf-shell
GH_TAGNAME=	${REVYTECH_SHA_WF_SHELL}
GH_TUPLE=	GNOME:libgnome-volume-control:468022b:gvc/subprojects/gvc
USE_GNOME=	gtkmm40
# wp-mixer needs pipewire; ddcutil optional — disable both for a reliable base package
MESON_ARGS=	-Dgvc:alsa=false -Dwayland-logout=false \
		-Dwp-mixer-widget=disabled -Dddcutil=disabled

# Data lands in share/wf-shell (not share/wayfire)
DATADIR=	${PREFIX}/share/wf-shell
# System defaults: /usr/local/etc/wf-shell/ (user: ~/.config/wf-shell.ini)
ETCDIR=		${PREFIX}/etc/wf-shell

OPTIONS_DEFINE=		PULSEAUDIO
OPTIONS_DEFAULT=	PULSEAUDIO

PULSEAUDIO_LIB_DEPENDS=		libpulse.so:audio/pulseaudio
PULSEAUDIO_MESON_ENABLED=	volume-widget

post-install:
	${MKDIR} ${STAGEDIR}${ETCDIR}
	${INSTALL_DATA} ${FILESDIR}/wf-shell.ini ${STAGEDIR}${ETCDIR}/wf-shell.ini
	${INSTALL_DATA} ${FILESDIR}/wf-shell.ini ${STAGEDIR}${ETCDIR}/wf-shell.ini.sample
	${MKDIR} ${STAGEDIR}${PREFIX}/libexec
	${INSTALL_SCRIPT} ${FILESDIR}/wf-shell-launch ${STAGEDIR}${PREFIX}/libexec/wf-shell-launch
	@${ECHO_MSG} "revytech-wf-shell: wallpapers in ${DATADIR}/backgrounds; online feeds use curl/fetch"

post-extract:
	@${RM} -rf ${WRKSRC}/subprojects/wf-json
	@if [ -f ${FILESDIR}/wf-json.wrap ]; then \
		${INSTALL_DATA} ${FILESDIR}/wf-json.wrap ${WRKSRC}/subprojects/; \
	fi
	@${REINPLACE_CMD} "s/pam = dependency('pam')/pam = dependency('pam', required: false)/" \
		${WRKSRC}/meson.build

post-patch:
	@${REINPLACE_CMD} 's/^\t~SysfsSurveillor();/\tvirtual ~SysfsSurveillor();/' \
		${WRKSRC}/src/panel/widgets/brightness/brightness.hpp 2>/dev/null || true
	@${REINPLACE_CMD} "s/dependency('gbm', required: false)/dependency('gbm', required: false)/" \
		${WRKSRC}/meson.build
	@${REINPLACE_CMD} "s/dependency('libdrm', required: false)/dependency('libdrm', required: false)/" \
		${WRKSRC}/meson.build
	@if [ -f ${FILESDIR}/fix-pam-xdg-paths.py ]; then \
		${LOCALBASE}/bin/python3 ${FILESDIR}/fix-pam-xdg-paths.py ${WRKSRC}/data/meson.build || \
		python3 ${FILESDIR}/fix-pam-xdg-paths.py ${WRKSRC}/data/meson.build; \
	fi

.include <bsd.port.mk>
