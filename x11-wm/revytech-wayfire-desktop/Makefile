.include "${.CURDIR}/../../revytech/wayfire/Makefile.inc"

PORTNAME=	revytech-wayfire-desktop
DISTVERSION=	${REVYTECH_DISTVERSION}
CATEGORIES=	x11-wm wayland
MASTER_SITES=	# meta-port
DISTFILES=	#
EXTRACT_ONLY=	#

MAINTAINER=	${REVYTECH_MAINTAINER}
COMMENT=	REVYTECH Wayfire full desktop meta-port (compositor + shell)
WWW=		https://github.com/revytechinc/wayfire

LICENSE=	MIT

# Meta: pull the whole stack in dependency order
RUN_DEPENDS=	revytech-wf-config>0:devel/revytech-wf-config \
		revytech-wayfire>0:x11-wm/revytech-wayfire \
		revytech-wayfire-plugins-extra>0:x11-wm/revytech-wayfire-plugins-extra \
		revytech-wf-shell>0:x11/revytech-wf-shell \
		revytech-wcm>0:x11/revytech-wcm \
		seatd>0:sysutils/seatd \
		kanshi>0:x11/kanshi \
		mako>0:x11/mako \
		wlogout>0:x11/wlogout \
		alacritty>0:x11/alacritty

USES=		metaport


NO_ARCH=	yes

.include <bsd.port.mk>
