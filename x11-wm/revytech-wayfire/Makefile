PORTNAME=	revytech-wayfire
DISTVERSION=	${REVYTECH_DISTVERSION}
CATEGORIES=	x11-wm wayland

MAINTAINER=	${REVYTECH_MAINTAINER}
COMMENT=	REVYTECH Wayfire — 3D Wayland compositor (FreeBSD)
WWW=		https://github.com/revytechinc/wayfire

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

CONFLICTS_INSTALL=	wayfire

BUILD_DEPENDS=	${LOCALBASE}/include/xf86drmMode.h:graphics/libdrm \
		evdev-proto>0:devel/evdev-proto \
		glm>=0.9.8:math/glm \
		wayland-protocols>=1.37:graphics/wayland-protocols \
		msgfmt:devel/gettext-tools
LIB_DEPENDS=	libevdev.so:devel/libevdev \
		libinotify.so:devel/libinotify \
		libinput.so:x11/libinput \
		libpng.so:graphics/png \
		libudev.so:devel/libudev-devd \
		libwayland-server.so:graphics/wayland \
		libwf-config.so:devel/revytech-wf-config \
		libwlroots-0.20.so:x11-toolkits/wlroots020 \
		libxkbcommon.so:x11/libxkbcommon \
		libyyjson.so:devel/yyjson
RUN_DEPENDS=	seatd>0:sysutils/seatd

USES=		cmake:indirect compiler:c++17-lang gl gnome jpeg meson \
		pkgconfig xorg
USE_GITHUB=	yes
GH_ACCOUNT=	${REVYTECH_GH_ACCOUNT}
GH_PROJECT=	wayfire
GH_TAGNAME=	${REVYTECH_SHA_WAYFIRE}
USE_GL=		egl glesv2
USE_GNOME=	cairo pango
USE_XORG=	pixman

# Prefer system wf-config + system wlroots packages for packaging.
# Submodules still fetched for wf-touch / wf-utils / wf-json as needed.
MESON_ARGS=	-Dtests=disabled \
		-Duse_system_wfconfig=enabled \
		-Duse_system_wlroots=enabled \
		-Dwf-touch:tests=disabled \
		${NULL}

.if !exists(/usr/include/omp.h)
MESON_ARGS+=	-Denable_openmp=false
.endif

OPTIONS_DEFINE=	X11
OPTIONS_DEFAULT=	X11

X11_USE=	XORG=xcb
X11_MESON_ENABLED=	xwayland

.include "${.CURDIR}/../../revytech/wayfire/Makefile.inc"

post-patch:
	@if [ -x ${FILESDIR}/fix-include.sh ]; then \
		/bin/sh ${FILESDIR}/fix-include.sh ${WRKSRC}/src/api/wayfire/option-wrapper.hpp; \
	fi
	@if [ -x ${FILESDIR}/fetch-submodules.sh ]; then \
		/bin/sh ${FILESDIR}/fetch-submodules.sh ${WRKSRC}; \
	fi
	@${REINPLACE_CMD} -i .nogit -e 's/git.found()/false/' \
		-e '/project_version/s/@0@/${DISTVERSION}/' \
		${WRKSRC}/meson.build
# FreeBSD lacks linux/input-event-codes.h
	@${MKDIR} ${WRKSRC}/compat/linux
	${INSTALL_DATA} ${FILESDIR}/compat-linux-input-event-codes.h \
		${WRKSRC}/compat/linux/input-event-codes.h
	@if [ -x ${FILESDIR}/insert-compat.sh ]; then \
		/bin/sh ${FILESDIR}/insert-compat.sh ${WRKSRC}/meson.build; \
	fi

post-install:
	${MKDIR} ${STAGEDIR}${EXAMPLESDIR}
	${INSTALL_DATA} ${WRKSRC}/wayfire.ini \
		${STAGEDIR}${EXAMPLESDIR}/wayfire.ini

.include <bsd.port.mk>
