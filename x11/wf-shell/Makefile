PORTNAME=	wf-shell
DISTVERSIONPREFIX=	v
DISTVERSION=	0.11.0
CATEGORIES=	x11 wayland

MAINTAINER=	mark@revytechinc.com
COMMENT=	GTK4-based panel for wayfire
WWW=		https://github.com/revytechinc/wf-shell

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	wayland-protocols>0:graphics/wayland-protocols \
		wayfire>0:x11-wm/wayfire
LIB_DEPENDS=	libdbusmenu-glib.so:devel/libdbusmenu \
		libinotify.so:devel/libinotify \
		libyyjson.so:textproc/yyjson \
		libwayland-client.so:graphics/wayland \
		libepoxy.so:graphics/libepoxy \
		libxkbregistry.so:x11/libxkbcommon \
		libgtk-4.so:devel/gtk4 \
		libgtk4-layer-shell.so:x11-toolkits/gtk4-layer-shell \
		libdrm.so:graphics/libdrm
RUN_DEPENDS=	wayland-logout:x11/wayland-logout

FLAVORS=	default nopulse
default_CONFLICTS_INSTALL=	${PORTNAME}-nopulse
nopulse_CONFLICTS_INSTALL=	${PORTNAME}
nopulse_PKGNAMESUFFIX=		-nopulse

USES=		compiler:c++17-lang gnome meson pkgconfig
CXXFLAGS+=	-I${LOCALBASE}/include/libdrm
USE_GITHUB=	yes
GH_ACCOUNT=	revytechinc
DISTFILES=	wf-shell-${DISTVERSION}.tar.gz
GH_TUPLE=	GNOME:libgnome-volume-control:468022b:gvc/subprojects/gvc
USE_GNOME=	gtkmm40
MESON_ARGS=	-Dgvc:alsa=false -Dwayland-logout=false
DATADIR=	${PREFIX}/share/wayfire
METADATADIR=	${DATADIR}/wf-shell

OPTIONS_DEFINE=	PULSEAUDIO WIREPLUMBER DDCUTIL LIVE_PREVIEWS
OPTIONS_DEFAULT=PULSEAUDIO
.if ${FLAVOR:U} == nopulse
OPTIONS_EXCLUDE=PULSEAUDIO
OPTIONS_EXCLUDE+=WIREPLUMBER
.endif

PULSEAUDIO_LIB_DEPENDS=	libpulse.so:audio/pulseaudio
PULSEAUDIO_MESON_ENABLED=	volume-widget

WIREPLUMBER_LIB_DEPENDS=	libwireplumber-0.5.so:audio/wireplumber
WIREPLUMBER_MESON_ENABLED=	wp-mixer-widget

DDCUTIL_LIB_DEPENDS=	libddcutil.so:devel/libddcutil
DDCUTIL_MESON_ENABLED=	ddcutil

LIVE_PREVIEWS_MESON_ENABLED=	live-previews-dmabuf

post-patch:
# Fix SysfsSurveillor destructor warning: make it virtual
	${REINPLACE_CMD} 's/^\t~SysfsSurveillor();/\tvirtual ~SysfsSurveillor();/' ${WRKSRC}/src/panel/widgets/brightness/brightness.hpp
# On FreeBSD, xf86drm.h and xf86drmMode.h are not in libdrm/ subdir; copy them
	${CP} ${LOCALBASE}/include/xf86drm.h ${LOCALBASE}/include/libdrm/xf86drm.h || true
	${CP} ${LOCALBASE}/include/xf86drmMode.h ${LOCALBASE}/include/libdrm/xf86drmMode.h || true
# stream-chooser needs gbm/libdrm even without live-previews-dmabuf; make optional
	${REINPLACE_CMD} "s/dependency('gbm', required: get_option('live-previews-dmabuf'))/dependency('gbm', required: false)/" ${WRKSRC}/meson.build
	${REINPLACE_CMD} "s/dependency('libdrm', required: get_option('live-previews-dmabuf'))/dependency('libdrm', required: false)/" ${WRKSRC}/meson.build
# Fix PAM and xdg install to use PREFIX/etc instead of hardcoded /etc/ paths
	${REINPLACE_CMD} "s|pam\.d')|pam.d'))|" ${WRKSRC}/data/meson.build
	${REINPLACE_CMD} "s|xdg-desktop-portal-wlr')|xdg-desktop-portal-wlr'))|" ${WRKSRC}/data/meson.build

post-extract:
# Install wf-json meson wrap to fetch the submodule from upstream
# Remove empty submodule directory so meson uses the wrap to fetch it
	${RM} -rf ${WRKSRC}/subprojects/wf-json
	${INSTALL_DATA} ${FILESDIR}/wf-json.wrap ${WRKSRC}/subprojects/
# Disable PAM requirement (not available on FreeBSD)
	${REINPLACE_CMD} "s/pam = dependency('pam')/pam = dependency('pam', required: false)/" ${WRKSRC}/meson.build

.include <bsd.port.mk>
