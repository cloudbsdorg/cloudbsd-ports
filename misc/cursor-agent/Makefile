PORTNAME=	cursor-agent
DISTVERSION=	2026.08.25
# Upstream lab tag is date-hash; kept separate so PORTVERSION stays clean.
CURSOR_LAB_VER=	2026.08.25-3e8eec8
CATEGORIES=	misc # machine-learning
MASTER_SITES=	https://downloads.cursor.com/lab/${CURSOR_LAB_VER}/:amd64 \
		https://downloads.cursor.com/lab/${CURSOR_LAB_VER}/:aarch64
DISTFILES=	linux/x64/agent-cli-package.tar.gz:amd64 \
		linux/arm64/agent-cli-package.tar.gz:aarch64
DIST_SUBDIR=	${PORTNAME}/${CURSOR_LAB_VER}

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Cursor Agent CLI for terminal coding agents
WWW=		https://cursor.com/cli

LICENSE=	CURSOR
LICENSE_NAME=	Cursor Terms of Service
LICENSE_FILE=	${FILESDIR}/CURSOR-EULA
LICENSE_PERMS=	dist-mirror pkg-mirror auto-accept

ONLY_FOR_ARCHS=		aarch64 amd64
ONLY_FOR_ARCHS_REASON=	is a Linux binary with limited platform support

USES=		linux:rl9
USE_LINUX=	base

# Upstream launcher is #!/usr/bin/env bash.
RUN_DEPENDS=	bash:shells/bash

NO_BUILD=	yes
NO_WRKSUBDIR=	yes

# Wrappers; package payload listed into TMPPLIST in do-install.
PLIST_FILES=	bin/agent \
		bin/cursor-agent

SUB_FILES=	pkg-message

find-new-version:
	@TAB=$$(printf '\t'); \
	page=$$(fetch -q -o - https://cursor.com/install); \
	new_ver=$$(echo "$$page" | ${SED} -nE 's|.*downloads\.cursor\.com/lab/([0-9]{4}\.[0-9]{2}\.[0-9]{2}-[0-9a-f]+)/.*|\1|p' | ${HEAD} -1); \
	current_ver=$$(make -V CURSOR_LAB_VER); \
	if [ -z "$$new_ver" ]; then \
		echo "=> Could not parse version from https://cursor.com/install"; \
		exit 1; \
	elif [ "$$new_ver" != "$$current_ver" ]; then \
		new_dist=$$(echo "$$new_ver" | ${SED} -E 's/-.*//'); \
		${SED} -i '' "s/^DISTVERSION=.*/DISTVERSION=$${TAB}$$new_dist/" ${.CURDIR}/Makefile; \
		${SED} -i '' "s/^CURSOR_LAB_VER=.*/CURSOR_LAB_VER=$${TAB}$$new_ver/" ${.CURDIR}/Makefile; \
		echo "=> New version available: $$current_ver -> $$new_ver"; \
	else \
		echo "=> No new version available (current: $$current_ver)"; \
	fi

.include <bsd.port.pre.mk>

.if ${ARCH} == aarch64
EXTRACT_ONLY=	linux/arm64/agent-cli-package.tar.gz
.else
EXTRACT_ONLY=	linux/x64/agent-cli-package.tar.gz
.endif

do-install:
	${MKDIR} ${STAGEDIR}${PREFIX}/libexec/${PORTNAME}
	# Preserve upstream mode bits (node, rg, helpers are executable).
	${TAR} -C ${WRKSRC}/dist-package -cf - . | \
		${TAR} -C ${STAGEDIR}${PREFIX}/libexec/${PORTNAME} -xf -
	${FIND} ${STAGEDIR}${PREFIX}/libexec/${PORTNAME} \( -type f -o -type l \) | \
		${SED} -e 's|${STAGEDIR}${PREFIX}/||' | ${SORT} >> ${TMPPLIST}
	${FIND} ${STAGEDIR}${PREFIX}/libexec/${PORTNAME} -type d -empty | \
		${SED} -e 's|${STAGEDIR}${PREFIX}/||' -e 's|^|@dir |' | ${SORT} >> ${TMPPLIST}
	# Wrappers: require linprocfs, put package dir on PATH, run bundled launcher.
	( \
		${ECHO} '#!/bin/sh'; \
		${ECHO} 'if [ ! -d /compat/linux/proc ]; then'; \
		${ECHO} '  echo "Error: /compat/linux/proc is not mounted. Enable linux(4) and mount linprocfs (service linux start)." >&2'; \
		${ECHO} '  exit 1'; \
		${ECHO} 'fi'; \
		${ECHO} 'LIBEXEC="${PREFIX}/libexec/${PORTNAME}"'; \
		${ECHO} 'export PATH="$${LIBEXEC}:$${PATH}"'; \
		${ECHO} 'export CURSOR_INVOKED_AS="$$(basename "$$0")"'; \
		${ECHO} 'if [ -z "$${NODE_COMPILE_CACHE:-}" ] && [ -n "$${HOME:-}" ]; then'; \
		${ECHO} '  export NODE_COMPILE_CACHE="$${XDG_CACHE_HOME:-$$HOME/.cache}/cursor-compile-cache"'; \
		${ECHO} 'fi'; \
		${ECHO} 'exec "$${LIBEXEC}/cursor-agent" "$$@"' \
	) > ${STAGEDIR}${PREFIX}/bin/cursor-agent
	${CP} ${STAGEDIR}${PREFIX}/bin/cursor-agent \
		${STAGEDIR}${PREFIX}/bin/agent
	${CHMOD} 755 ${STAGEDIR}${PREFIX}/bin/cursor-agent \
		${STAGEDIR}${PREFIX}/bin/agent

.include <bsd.port.post.mk>
