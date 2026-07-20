.include "${.CURDIR}/../../revytech/wayfire/Makefile.inc"

PORTNAME=	revytech-wf-config
DISTVERSION=	${REVYTECH_DISTVERSION}
CATEGORIES=	devel wayland

MAINTAINER=	${REVYTECH_MAINTAINER}
COMMENT=	REVYTECH wf-config — Wayfire configuration library (FreeBSD)
WWW=		https://github.com/revytechinc/wf-config

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

CONFLICTS_INSTALL=	wf-config

BUILD_DEPENDS=	evdev-proto>0:devel/evdev-proto \
		wayland-protocols>0:graphics/wayland-protocols \
		glm>0:math/glm
LIB_DEPENDS=	libevdev.so:devel/libevdev
RUN_DEPENDS=	glm>0:math/glm
TEST_DEPENDS=	doctest>0:devel/doctest

USES=		cmake:indirect compiler:c++17-lang gnome meson pkgconfig
USE_GITHUB=	yes
GH_ACCOUNT=	${REVYTECH_GH_ACCOUNT}
GH_PROJECT=	wf-config
GH_TAGNAME=	${REVYTECH_SHA_WF_CONFIG}
USE_GNOME=	libxml2
USE_LDCONFIG=	yes

MESON_ARGS=	-Dtests=disabled
# Provide PLIST_SUB VERSION for @${VERSION} style plists if needed
PLIST_SUB=	VERSION=0.11.0


post-patch:
# FreeBSD ports require project() first in meson.build.
	@if [ -x ${FILESDIR}/move-git-remote.sh ]; then \
		/bin/sh ${FILESDIR}/move-git-remote.sh ${WRKSRC}/meson.build; \
	fi

pre-test:
	@if [ ! -e ${WRKDIR}/.meson_build_tests ]; then \
		${RM} ${CONFIGURE_COOKIE} ${BUILD_COOKIE}; \
		${MAKE} -C${.CURDIR} build MESON_ARGS="${MESON_ARGS} --reconfigure -Dtests=enabled"; \
		${TOUCH} ${WRKDIR}/.meson_build_tests; \
	fi

.include <bsd.port.mk>
