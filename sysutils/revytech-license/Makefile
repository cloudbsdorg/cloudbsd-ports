# Copyright (c) 2026 REVYTECH, Inc.
# SPDX-License-Identifier: BSD-3-Clause

PORTNAME=	revytech-license
DISTVERSION=	0.1.0
CATEGORIES=	sysutils

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Activate a CloudBSD or REVYTECH series pkg license on a client
WWW=		https://github.com/revytechinc/pkg-repo

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go
GO_TARGET=	./cmd/revytech-license
MAKE_ENV+=	CGO_ENABLED=0
CGO_ENABLED=	0

.if defined(REVYTECH_PKG_DISTDIR)
MASTER_SITES=	file://${REVYTECH_PKG_DISTDIR}/
DISTNAME=	pkg-repo-${DISTVERSION}
DISTFILES=	${DISTNAME}${EXTRACT_SUFX}
NO_CHECKSUM=	yes
.else
USE_GITHUB=	yes
GH_ACCOUNT=	revytechinc
GH_PROJECT=	pkg-repo
GH_TAGNAME=	v${DISTVERSION}
.endif

PLIST_FILES=	sbin/revytech-license \
		"@sample etc/pkg/CloudBSD.conf.sample" \
		"@sample etc/pkg/REVYTECH.conf.sample"

post-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/etc/pkg
	${INSTALL_DATA} ${WRKSRC}/etc/pkg/CloudBSD.conf \
		${STAGEDIR}${PREFIX}/etc/pkg/CloudBSD.conf.sample
	${INSTALL_DATA} ${WRKSRC}/etc/pkg/REVYTECH.conf \
		${STAGEDIR}${PREFIX}/etc/pkg/REVYTECH.conf.sample

.include <bsd.port.mk>
