PORTNAME=	wayfire-plugins-extra
DISTVERSIONPREFIX=	v
DISTVERSION=	0.11.0
CATEGORIES=	x11-wm wayland

MAINTAINER=	mark@revytechinc.com
COMMENT=	Additional plugins for Wayfire
WWW=		https://github.com/revytechinc/wayfire-plugins-extra

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE
WRKSRC=		${WRKDIR}/wayfire-plugins-extra

BUILD_DEPENDS=	boost-libs>0:devel/boost-libs \
		evdev-proto>0:devel/evdev-proto \
		wayland-scanner:graphics/wayland \
		wayland-protocols>=1.12:graphics/wayland-protocols \
		wayfire>=0.11.0:x11-wm/wayfire
LIB_DEPENDS=	libevdev.so:devel/libevdev \
		libwf-config.so:devel/wf-config \
		libwayland-server.so:graphics/wayland

USES=		compiler:c++17-lang gl gnome meson pkgconfig
USE_GL=		glesv2
USE_GNOME=	cairo glibmm gtkmm30

USE_GITHUB=	nodefault
GH_ACCOUNT=	revytechinc
GH_TAGNAME=	v${DISTVERSION}
MASTER_SITES=	https://github.com/revytechinc/wayfire-plugins-extra/archive/refs/tags/v${DISTVERSION}.tar.gz
DISTFILES=	wayfire-plugins-extra-${DISTVERSION}.tar.gz

post-patch:
# Fetch git submodules not included in the GitHub tarball.
	/bin/sh ${FILESDIR}/fetch-submodules.sh ${WRKSRC}
# Insert FreeBSD compat shim for linux/input-event-codes.h
	/bin/sh ${FILESDIR}/insert-compat.sh ${WRKSRC}/meson.build

MESON_ARGS=	-Denable_focus_request=true \
		-Denable_pixdecor=false \
		-Denable_filters=true

OPTIONS_DEFINE=	PANGO
OPTIONS_DEFAULT=PANGO
OPTIONS_SUB=	yes

PANGO_USE=		GNOME=pango

.include <bsd.port.mk>
