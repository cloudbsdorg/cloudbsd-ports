PORTNAME=	wf-shell
DISTVERSIONPREFIX=	v
DISTVERSION=	0.11.0
CATEGORIES=	x11 wayland

MAINTAINER=	ports@FreeBSD.org
COMMENT=	GTK4-based panel for wayfire
WWW=		https://wayfire.org/

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	wayland-protocols>0:graphics/wayland-protocols \
		wf-config>=0.7.0:devel/wf-config \
		wayfire>0:x11-wm/wayfire
LIB_DEPENDS=	libdbusmenu-glib.so:devel/libdbusmenu \
		libinotify.so:devel/libinotify \
		libwf-config.so:devel/wf-config \
		libyyjson.so:textproc/yyjson \
		libwayland-client.so:graphics/wayland \
		libepoxy.so:graphics/libepoxy \
		libxkbregistry.so:x11/libxkbregistry \
		libgtk-4.so:devel/gtk4 \
		gtk4-layer-shell>=1.3.0:x11/gtk4-layer-shell
RUN_DEPENDS=	wayland-logout:x11/wayland-logout

FLAVORS=	default nopulse
default_CONFLICTS_INSTALL=	${PORTNAME}-nopulse
nopulse_CONFLICTS_INSTALL=	${PORTNAME}
nopulse_PKGNAMESUFFIX=		-nopulse

USES=		compiler:c++17-lang gnome meson pkgconfig
USE_GITHUB=	yes
USE_GNOME=	gtkmm40
GH_ACCOUNT=	WayfireWM
GH_PROJECT=	wf-shell
GH_TAGNAME=	06269c5e0a51b1ced98c0925e997e911237eaf02
GH_TUPLE=	GNOME:libgnome-volume-control:468022b:gvc/subprojects/gvc
MESON_ARGS=	-Dgvc:alsa=false -Dwayland-logout=false
DATADIR=	${PREFIX}/share/wayfire
METADATADIR=	/wf-shell

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

.include <bsd.port.mk>
