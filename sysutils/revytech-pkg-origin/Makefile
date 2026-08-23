# Copyright (c) 2026 REVYTECH, Inc.
# SPDX-License-Identifier: BSD-3-Clause

PORTNAME=	revytech-pkg-origin
DISTVERSION=	0.1.0
CATEGORIES=	sysutils
MASTER_SITES=	# metaport
DISTFILES=	# none

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Metaport for a CloudBSD/REVYTECH pkg origin node
WWW=		https://github.com/revytechinc/pkg-repo

LICENSE=	BSD3CLAUSE

# One origin node: daemon + web server. Cluster by adding nodes that share
# Postgres and a blob replica (docs/210-cluster.md). Product lines are data.
RUN_DEPENDS=	revytech-pkgd:sysutils/revytech-pkgd \
		nginx:www/nginx \
		curl:ftp/curl \
		openssl:security/openssl

OPTIONS_DEFINE=	CERTBOT
OPTIONS_DEFAULT=	CERTBOT
CERTBOT_DESC=	Let's Encrypt client (optional; self-signed and provided certs still work)
CERTBOT_RUN_DEPENDS=	certbot:security/py-certbot

NO_ARCH=	yes
NO_BUILD=	yes
NO_INSTALL=	yes

.include <bsd.port.mk>
