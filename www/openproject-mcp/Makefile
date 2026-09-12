# Copyright (c) 2026 REVYTECH, Inc.
# SPDX-License-Identifier: BSD-3-Clause
#
# Part of CloudBSD (REVYTECH, Inc., founded 2026).
# DEV-only OpenProject MCP gateway. Wrapper files are REVYTECH
# BSD-3-Clause. openproject-mcp and supergateway remain MIT.
# Production www/openproject stays MCP-free (do not enable here).

PORTNAME=	openproject-mcp
DISTVERSION=	1.0.1
CATEGORIES=	www
MASTER_SITES=	https://registry.npmjs.org/openproject-mcp/-/:mcp \
		https://registry.npmjs.org/supergateway/-/:sg
DISTFILES=	openproject-mcp-${MCP_VER}.tgz:mcp \
		supergateway-${SG_VER}.tgz:sg
DIST_SUBDIR=	${PORTNAME}

MAINTAINER=	mark@cloudbsd.org
COMMENT=	OpenProject MCP HTTP/stdio gateway (DEV, pinned npm)
WWW=		https://github.com/cyborgx0x/mcp-openproject

LICENSE=	BSD3CLAUSE MIT
LICENSE_COMB=	multi
LICENSE_FILE_BSD3CLAUSE=	${FILESDIR}/COPYRIGHT
LICENSE_FILE_MIT=	${FILESDIR}/LICENSE-openproject-mcp

# Pinned npm packages (no npx at runtime):
#   openproject-mcp@1.0.1
#   supergateway@3.4.3
# Top-level tarballs are DISTFILES (checksum + LICENSE). The locked
# dependency tree is files/package-lock.json. do-build runs npm ci
# (same pattern as www/mdweb and www/openproject frontend) and stages
# node_modules under lib/openproject-mcp. Bins land in ${PREFIX}/bin.
# Network is required at build time to fetch the locked tree.
MCP_VER=	1.0.1
SG_VER=		3.4.3

# EXTRACT_ONLY empty: both npm tarballs unpack to package/. Wrappers
# and the lockfile live in files/. LICENSEs are copied from FILESDIR.
EXTRACT_ONLY=	# empty

USES=		nodejs:24,build,run
USE_RC_SUBR=	openproject_mcp

BUILD_DEPENDS=	${LOCALBASE}/bin/npm:www/npm-node24
RUN_DEPENDS=	openproject>0:www/openproject

NO_ARCH=	yes

# User/group come from www/openproject. Do not redefine USERS.
SUB_FILES=	pkg-message openproject_mcp_exec openproject_mcp_stdio \
		nginx-mcp.conf.sample
SUB_LIST=	PREFIX=${PREFIX} \
		USERS=openproject \
		GROUPS=openproject \
		MCP_VER=${MCP_VER} \
		SG_VER=${SG_VER}
PLIST_SUB=	USERS=openproject GROUPS=openproject

WRKSRC=		${WRKDIR}/${PORTNAME}-${DISTVERSION}

# npm ci: omit scripts (pure JS; no node-gyp). Cache off $HOME.
MAKE_ENV+=	HOME=${WRKDIR} \
		NPM_CONFIG_CACHE=${WRKDIR}/.npm \
		NPM_CONFIG_UPDATE_NOTIFIER=false \
		NPM_CONFIG_FUND=false \
		NPM_CONFIG_AUDIT=false

post-extract:
	${MKDIR} ${WRKSRC}
	${CP} ${FILESDIR}/package.json ${WRKSRC}/package.json
	${CP} ${FILESDIR}/package-lock.json ${WRKSRC}/package-lock.json

do-build:
	@${ECHO_MSG} "===>  npm ci (openproject-mcp@${MCP_VER} + supergateway@${SG_VER}, no npx)"
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/npm ci --omit=dev --ignore-scripts --no-audit --no-fund
	@${TEST} -f ${WRKSRC}/node_modules/openproject-mcp/package.json
	@${TEST} -f ${WRKSRC}/node_modules/supergateway/package.json
	@${GREP} -q '"version": "${MCP_VER}"' \
		${WRKSRC}/node_modules/openproject-mcp/package.json
	@${GREP} -q '"version": "${SG_VER}"' \
		${WRKSRC}/node_modules/supergateway/package.json

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/bin \
		${STAGEDIR}${PREFIX}/libexec \
		${STAGEDIR}${PREFIX}/lib/openproject-mcp \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/openproject \
		${STAGEDIR}${PREFIX}/etc/nginx \
		${STAGEDIR}${DOCSDIR}
	${INSTALL_DATA} ${WRKSRC}/package.json \
		${STAGEDIR}${PREFIX}/lib/openproject-mcp/package.json
	${INSTALL_DATA} ${WRKSRC}/package-lock.json \
		${STAGEDIR}${PREFIX}/lib/openproject-mcp/package-lock.json
	cd ${WRKSRC} && ${COPYTREE_SHARE} node_modules \
		${STAGEDIR}${PREFIX}/lib/openproject-mcp
	# COPYTREE_SHARE uses cpio hardlinks so chmod staged paths (INSTALL would fail).
	${CHMOD} 755 \
		${STAGEDIR}${PREFIX}/lib/openproject-mcp/node_modules/openproject-mcp/index.js
	${CHMOD} 755 \
		${STAGEDIR}${PREFIX}/lib/openproject-mcp/node_modules/supergateway/dist/index.js
	${PRINTF} '#!/bin/sh\nexec %s/bin/node %s/lib/openproject-mcp/node_modules/openproject-mcp/index.js "$$@"\n' \
		${PREFIX} ${PREFIX} > ${STAGEDIR}${PREFIX}/bin/openproject-mcp
	${PRINTF} '#!/bin/sh\nexec %s/bin/node %s/lib/openproject-mcp/node_modules/supergateway/dist/index.js "$$@"\n' \
		${PREFIX} ${PREFIX} > ${STAGEDIR}${PREFIX}/bin/supergateway
	${CHMOD} 755 ${STAGEDIR}${PREFIX}/bin/openproject-mcp \
		${STAGEDIR}${PREFIX}/bin/supergateway
	${INSTALL_SCRIPT} ${WRKDIR}/openproject_mcp_exec \
		${STAGEDIR}${PREFIX}/libexec/openproject_mcp
	${INSTALL_SCRIPT} ${WRKDIR}/openproject_mcp_stdio \
		${STAGEDIR}${PREFIX}/libexec/openproject_mcp_stdio
	${INSTALL} -m 0600 ${FILESDIR}/mcp.api_key.sample \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/openproject/mcp.api_key.sample
	${INSTALL} -m 0600 ${FILESDIR}/mcp.bearer.sample \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/openproject/mcp.bearer.sample
	${INSTALL_DATA} ${WRKDIR}/nginx-mcp.conf.sample \
		${STAGEDIR}${PREFIX}/etc/nginx/openproject-mcp.conf.sample
	${INSTALL_DATA} ${FILESDIR}/COPYRIGHT ${STAGEDIR}${DOCSDIR}/COPYRIGHT
	${INSTALL_DATA} ${FILESDIR}/LICENSE-openproject-mcp \
		${STAGEDIR}${DOCSDIR}/LICENSE-openproject-mcp
	${INSTALL_DATA} ${FILESDIR}/LICENSE-supergateway \
		${STAGEDIR}${DOCSDIR}/LICENSE-supergateway

# node_modules is too large to maintain by hand (same as www/openproject).
post-install:
	${FIND} -s ${STAGEDIR}${PREFIX}/lib/openproject-mcp -not -type d | ${SORT} | \
		${SED} -e 's#^${STAGEDIR}${PREFIX}/##' >> ${TMPPLIST}

do-test:
	@${SH} -n ${FILESDIR}/openproject_mcp.in
	@${SH} -n ${FILESDIR}/openproject_mcp_exec.in
	@${SH} -n ${FILESDIR}/openproject_mcp_stdio.in
	@${GREP} -q 'PROVIDE: openproject_mcp' ${FILESDIR}/openproject_mcp.in
	@${GREP} -q 'REQUIRE: LOGIN openproject' ${FILESDIR}/openproject_mcp.in
	@${GREP} -q 'openproject_mcp_enable:="NO"' ${FILESDIR}/openproject_mcp.in
	@${GREP} -q 'sockstat' ${FILESDIR}/openproject_mcp.in
	@${GREP} -q 'mcp.api_key' ${FILESDIR}/openproject_mcp.in
	@${GREP} -q 'initgroups' ${FILESDIR}/openproject_mcp.in
	@${GREP} -q 'su -m' ${FILESDIR}/openproject_mcp.in
	@${GREP} -q 'OPENPROJECT_URL' ${FILESDIR}/openproject_mcp_exec.in
	@${GREP} -q 'OPENPROJECT_API_KEY' ${FILESDIR}/openproject_mcp_exec.in
	@${GREP} -q 'streamableHttp' ${FILESDIR}/openproject_mcp_exec.in
	@${GREP} -q -- '--streamableHttpPath /mcp' ${FILESDIR}/openproject_mcp_exec.in
	@${GREP} -q 'OPENPROJECT_URL' ${FILESDIR}/openproject_mcp_stdio.in
	@${GREP} -q 'npx -y' ${FILESDIR}/openproject_mcp_exec.in; \
		if [ $$? -eq 0 ]; then ${ECHO_MSG} "FAIL: npx -y in libexec"; exit 1; fi
	@${GREP} -q 'npx -y' ${FILESDIR}/openproject_mcp_stdio.in; \
		if [ $$? -eq 0 ]; then ${ECHO_MSG} "FAIL: npx -y in stdio"; exit 1; fi
	@${GREP} -q '"openproject-mcp": "1.0.1"' ${FILESDIR}/package.json
	@${GREP} -q '"supergateway": "3.4.3"' ${FILESDIR}/package.json
	@${GREP} -q 'openproject-mcp-1.0.1.tgz' ${.CURDIR}/Makefile
	@${GREP} -q 'supergateway-3.4.3.tgz' ${.CURDIR}/Makefile
	@${GREP} -q 'nodejs:24,build,run' ${.CURDIR}/Makefile
	@${GREP} -q 'www/openproject' ${.CURDIR}/Makefile
	@${GREP} -q 'REPLACE_ME' ${FILESDIR}/mcp.api_key.sample
	@${GREP} -q 'REPLACE_ME' ${FILESDIR}/mcp.bearer.sample
	@${GREP} -q 'proxy_pass' ${FILESDIR}/nginx-mcp.conf.sample.in
	@${GREP} -q '127.0.0.1:8000' ${FILESDIR}/nginx-mcp.conf.sample.in
	@${GREP} -q 'location /mcp' ${FILESDIR}/nginx-mcp.conf.sample.in
	@if ${GREP} -q 'track.cloudbsd.org' ${FILESDIR}/nginx-mcp.conf.sample.in \
		${FILESDIR}/pkg-message.in ${FILESDIR}/openproject_mcp.in \
		${FILESDIR}/openproject_mcp_exec.in ${FILESDIR}/openproject_mcp_stdio.in; then \
		${ECHO_MSG} "FAIL: fleet hostname in MCP port files"; exit 1; \
	fi
	@if ${GREP} -E -q 'npx[[:space:]]+-y' \
		${FILESDIR}/openproject_mcp.in \
		${FILESDIR}/openproject_mcp_exec.in \
		${FILESDIR}/openproject_mcp_stdio.in; then \
		${ECHO_MSG} "FAIL: npx at runtime in MCP wrappers"; exit 1; \
	fi

.include <bsd.port.mk>
