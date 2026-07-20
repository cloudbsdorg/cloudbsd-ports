PORTNAME=	revytech-wcm
DISTVERSION=	${REVYTECH_DISTVERSION}
CATEGORIES=	x11 wayland

MAINTAINER=	${REVYTECH_MAINTAINER}
COMMENT=	REVYTECH Wayfire Config Manager (GTK3)
WWW=		https://github.com/revytechinc/wcm

LICENSE=	MIT
LICENSE_FILE=	${WRKSRC}/LICENSE

CONFLICTS_INSTALL=	wcm wcmcommander

BUILD_DEPENDS=	evdev-proto>0:devel/evdev-proto \
		wayland-protocols>0:graphics/wayland-protocols \
		revytech-wayfire>=0.11.0:x11-wm/revytech-wayfire
LIB_DEPENDS=	libevdev.so:devel/libevdev \
		libfmt.so:devel/libfmt \
		libwf-config.so:devel/revytech-wf-config \
		libwayland-client.so:graphics/wayland
RUN_DEPENDS=	revytech-wayfire>=0.11.0:x11-wm/revytech-wayfire

USES=		compiler:c++17-lang gnome meson pkgconfig
USE_GITHUB=	yes
GH_ACCOUNT=	${REVYTECH_GH_ACCOUNT}
GH_PROJECT=	wcm
GH_TAGNAME=	${REVYTECH_SHA_WCM}
USE_GNOME=	gdkpixbuf gtk30 libxml2

OPTIONS_DEFINE=		WDISPLAYS WFSHELL
OPTIONS_DEFAULT=	WDISPLAYS WFSHELL
OPTIONS_SUB=		yes

WDISPLAYS_DESC=		Configure outputs via wdisplays
WDISPLAYS_RUN_DEPENDS=	wdisplays>0:x11/wdisplays

WFSHELL_DESC=		Build with revytech-wf-shell support
WFSHELL_BUILD_DEPENDS=	revytech-wf-shell>0:x11/revytech-wf-shell
WFSHELL_MESON_ENABLED=	wf_shell

.include "${.CURDIR}/../../revytech/wayfire/Makefile.inc"

.include <bsd.port.mk>
