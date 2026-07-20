.include "${.CURDIR}/../../revytech/wayfire/Makefile.inc"

PORTNAME=	revytech-wf-osk
DISTVERSION=	${REVYTECH_DISTVERSION}
CATEGORIES=	x11 wayland

MAINTAINER=	${REVYTECH_MAINTAINER}
COMMENT=	REVYTECH on-screen keyboard for Wayfire
WWW=		https://github.com/revytechinc/wf-osk

LICENSE=	MIT

CONFLICTS_INSTALL=	wf-osk

BUILD_DEPENDS=	wayland-protocols>0:graphics/wayland-protocols
LIB_DEPENDS=	libwayland-client.so:graphics/wayland \
		libgtk-layer-shell.so:x11-toolkits/gtk-layer-shell \
		libepoll-shim.so:devel/libepoll-shim

USES=		compiler:c++17-lang gnome meson pkgconfig
USE_GITHUB=	yes
GH_ACCOUNT=	${REVYTECH_GH_ACCOUNT}
GH_PROJECT=	wf-osk
GH_TAGNAME=	${REVYTECH_SHA_WF_OSK}
USE_GNOME=	gtk30
LDFLAGS+=	-L${LOCALBASE}/lib -lepoll-shim

.include <bsd.port.mk>
