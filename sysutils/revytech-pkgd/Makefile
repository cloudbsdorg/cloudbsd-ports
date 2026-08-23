# Copyright (c) 2026 REVYTECH, Inc.
# SPDX-License-Identifier: BSD-3-Clause

PORTNAME=	revytech-pkgd
DISTVERSION=	0.1.0
CATEGORIES=	sysutils

MAINTAINER=	mark@cloudbsd.org
COMMENT=	License-gated pkg origin daemon (all CloudBSD and REVYTECH series)
WWW=		https://github.com/revytechinc/pkg-repo

LICENSE=	BSD3CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

USES=		go
GO_PKGNAME=	github.com/revytechinc/pkg-repo
GO_TARGET=	./cmd/revytech-pkgd:${PREFIX}/sbin/revytech-pkgd
GO_BUILDFLAGS=	-ldflags="-s"
MAKE_ENV+=	CGO_ENABLED=0
CGO_ENABLED=	0
USE_RC_SUBR=	revytech_pkgd

# Lab: REVYTECH_PKG_DISTDIR=/path containing revytech-pkgd-${DISTVERSION}.tar.gz
# Production: GitHub tag v${DISTVERSION}.
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

PLIST_FILES=	sbin/revytech-pkgd \
		"@sample etc/pkg-repo/series.json.sample" \
		"@sample etc/pkg-repo/pkgd.json.sample" \
		"@dir etc/pkg-repo"

post-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/etc/pkg-repo
	${INSTALL_DATA} ${WRKSRC}/etc/series.json \
		${STAGEDIR}${PREFIX}/etc/pkg-repo/series.json.sample
	${INSTALL_DATA} ${WRKSRC}/etc/pkgd.json \
		${STAGEDIR}${PREFIX}/etc/pkg-repo/pkgd.json.sample

.include <bsd.port.mk>
