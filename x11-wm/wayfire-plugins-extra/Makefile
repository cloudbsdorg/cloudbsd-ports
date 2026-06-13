PORTNAME=	wayfire-plugins-extra
DISTVERSIONPREFIX=	v
DISTVERSION=	0.11.0
CATEGORIES=	x11-wm wayland

MAINTAINER=	ports@FreeBSD.org
COMMENT=	Additional plugins for Wayfire
WWW=		https://wayfire.org/

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

BUILD_DEPENDS=	boost-libs>0:devel/boost-libs \
		evdev-proto>0:devel/evdev-proto \
		wayland-scanner:graphics/wayland \
		wayland-protocols>=1.12:graphics/wayland-protocols \
		wayfire>=0.11.0:x11-wm/wayfire
LIB_DEPENDS=	libevdev.so:devel/libevdev \
		libwf-config.so:devel/wf-config \
		libwayland-server.so:graphics/wayland

USES=		compiler:c++17-lang gl gnome meson pkgconfig
USE_GITHUB=	yes
USE_GITLAB=	nodefault
USE_GL=		glesv2
USE_GNOME=	cairo glibmm gtkmm30
GH_ACCOUNT=	revYTEchInc
GH_PROJECT=	wayfire-plugins-extra
GH_TAGNAME=	a65af2577986fbbdf8100048ad9943aff8ab27ff

MESON_ARGS=	-Denable_focus_request=true \
		-Denable_wayfire_shadows=true \
		-Denable_pixdecor=true \
		-Denable_filters=true

OPTIONS_DEFINE=	PANGO
OPTIONS_DEFAULT=PANGO
OPTIONS_SUB=	yes

PANGO_USE=		GNOME=pango

.include <bsd.port.mk>
