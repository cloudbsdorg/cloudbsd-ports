PORTNAME=	revytech-wayfire-plugins-extra
DISTVERSION=	${REVYTECH_DISTVERSION}
CATEGORIES=	x11-wm wayland

MAINTAINER=	${REVYTECH_MAINTAINER}
COMMENT=	REVYTECH additional plugins for Wayfire
WWW=		https://github.com/revytechinc/wayfire-plugins-extra

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

CONFLICTS_INSTALL=	wayfire-plugins-extra

BUILD_DEPENDS=	boost-libs>0:devel/boost-libs \
		evdev-proto>0:devel/evdev-proto \
		wayland-scanner:graphics/wayland \
		wayland-protocols>=1.12:graphics/wayland-protocols \
		revytech-wayfire>=0.11.0:x11-wm/revytech-wayfire
LIB_DEPENDS=	libevdev.so:devel/libevdev \
		libwf-config.so:devel/revytech-wf-config \
		libwayland-server.so:graphics/wayland

USES=		compiler:c++17-lang gl gnome meson pkgconfig
USE_GITHUB=	yes
GH_ACCOUNT=	${REVYTECH_GH_ACCOUNT}
GH_PROJECT=	wayfire-plugins-extra
GH_TAGNAME=	${REVYTECH_SHA_PLUGINS}
USE_GL=		glesv2
USE_GNOME=	cairo glibmm gtkmm30

MESON_ARGS=	-Denable_focus_request=true \
		-Denable_pixdecor=false \
		-Denable_filters=true \
		-Denable_wayfire_shadows=true

.include "${.CURDIR}/../../revytech/wayfire/Makefile.inc"

post-patch:
	@if [ -x ${FILESDIR}/fetch-submodules.sh ]; then \
		/bin/sh ${FILESDIR}/fetch-submodules.sh ${WRKSRC}; \
	fi
	@${MKDIR} ${WRKSRC}/compat/linux
	${INSTALL_DATA} ${FILESDIR}/compat/linux-input-event-codes.h \
		${WRKSRC}/compat/linux/input-event-codes.h
	@if [ -x ${FILESDIR}/insert-compat.sh ]; then \
		/bin/sh ${FILESDIR}/insert-compat.sh ${WRKSRC}/meson.build; \
	fi

.include <bsd.port.mk>
