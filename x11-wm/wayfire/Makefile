PORTNAME=	wayfire
DISTVERSIONPREFIX=	v
DISTVERSION=	0.11.0
CATEGORIES=	x11-wm wayland

MAINTAINER=	mark@revytechinc.com
COMMENT=	3D Wayland compositor
WWW=		https://github.com/revytechinc/wayfire

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE
WRKSRC=		${WRKDIR}/wayfire-0.11.0

BUILD_DEPENDS=	${LOCALBASE}/include/xf86drmMode.h:graphics/libdrm \
		evdev-proto>0:devel/evdev-proto \
		glm>=0.9.8:math/glm \
		wayland-protocols>=1.37:graphics/wayland-protocols
LIB_DEPENDS=	libevdev.so:devel/libevdev \
		libinotify.so:devel/libinotify \
		libinput.so:x11/libinput \
		libpng.so:graphics/png \
		libudev.so:devel/libudev-devd \
		libwayland-server.so:graphics/wayland \
		libwf-config.so:devel/wf-config \
		libwlroots-0.20.so:x11-toolkits/wlroots020 \
		libxkbcommon.so:x11/libxkbcommon \
		libyyjson.so:devel/yyjson
TEST_DEPENDS=	doctest>0:devel/doctest

USES=		cmake:indirect compiler:c++17-lang gl gnome jpeg meson \
		pkgconfig xorg
USE_GITHUB=	nodefault
GH_ACCOUNT=	revytechinc
GH_TAGNAME=	v${DISTVERSION}
DISTFILES=	wayfire-${DISTVERSION}.tar.gz
MASTER_SITES=	https://github.com/revytechinc/wayfire/archive/refs/tags/v${DISTVERSION}.tar.gz

USE_GL=		egl glesv2
USE_GNOME=	cairo pango
USE_XORG=	pixman
MESON_ARGS=	-Dtests=disabled \
		-Dwf-touch:tests=disabled \
		-Duse_system_wfconfig=disabled \
		${NULL}

.if !exists(/usr/include/omp.h)
# LLVM openmp in base doesn't support powerpc, armv6, armv7 yet
MESON_ARGS+=	-Denable_openmp=false
.endif

OPTIONS_DEFINE=	X11
OPTIONS_DEFAULT=X11

X11_USE=		XORG=xcb
X11_MESON_ENABLED=	xwayland

post-patch:
# Fix missing include in option-wrapper.hpp (uses section_t but doesn't include section.hpp)
	/bin/sh ${FILESDIR}/fix-include.sh ${WRKSRC}/src/api/wayfire/option-wrapper.hpp
# Fetch git submodules not included in the GitHub tarball
	/bin/sh ${FILESDIR}/fetch-submodules.sh ${WRKSRC}
# Extract (snapshot) version from the port instead of meson.build
	@${REINPLACE_CMD} -i .nogit -e 's/git.found()/false/' \
		-e '/project_version/s/@0@/${DISTVERSIONFULL}/' \
		${WRKSRC}/meson.build
# Install FreeBSD compat shim for linux/input-event-codes.h
# FreeBSD does not provide this Linux kernel header.
	@${MKDIR} ${WRKSRC}/compat/linux
	${INSTALL_DATA} ${FILESDIR}/compat-linux-input-event-codes.h \
		${WRKSRC}/compat/linux/input-event-codes.h
# Insert FreeBSD compat code into meson.build after the cpp compiler line
	/bin/sh ${FILESDIR}/insert-compat.sh ${WRKSRC}/meson.build

post-install:
	${MKDIR} ${STAGEDIR}${EXAMPLESDIR}
	${INSTALL_DATA} ${WRKSRC}/${PORTNAME}.ini ${STAGEDIR}${EXAMPLESDIR}

pre-test:
	@if [ ! -e ${WRKDIR}/.meson_build_tests ]; then \
		${RM} ${CONFIGURE_COOKIE} ${BUILD_COOKIE}; \
		${MAKE} -C${.CURDIR} build MESON_ARGS="${MESON_ARGS} --reconfigure \
			${MESON_ARGS:M*tests*:S/=dis/=en/}"; \
		${TOUCH} ${WRKDIR}/.meson_build_tests; \
	fi

.include <bsd.port.mk>
