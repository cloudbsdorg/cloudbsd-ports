# Copyright (c) 2026 REVYTECH, Inc.
# SPDX-License-Identifier: BSD-3-Clause
#
# Part of CloudBSD (REVYTECH, Inc., founded 2026).
# Native CloudBSD port of official OpenProject. Wrapper files are
# REVYTECH BSD-3-Clause. OpenProject itself remains GPLv3.

PORTNAME=	openproject
DISTVERSIONPREFIX=	v
DISTVERSION=	17.7.2
PORTREVISION=	2
CATEGORIES=	www

MAINTAINER=	mark@cloudbsd.org
COMMENT=	OpenProject project management (Rails, Puma, PostgreSQL)
WWW=		https://www.openproject.org/

LICENSE=	BSD3CLAUSE GPLv3
LICENSE_COMB=	multi
LICENSE_FILE_BSD3CLAUSE=	${FILESDIR}/COPYRIGHT
LICENSE_FILE_GPLv3=	${WRKSRC}/LICENSE

# Official source. Git gems from Gemfile.lock are GH_TUPLE'd into
# vendor/gems (port patches, not an application fork).
USE_GITHUB=	yes
GH_ACCOUNT=	opf
GH_PROJECT=	openproject
# GH_TAGNAME is v17.7.2 via DISTVERSIONPREFIX=v + DISTVERSION.
GH_TUPLE=	opf:dentaku:78eece45bf3f4ed021c05dd2f5411d1c3f9b168a:dentaku \
		opf:md-to-pdf:0cb4597becd2243b810e7ce53bbbbf28b5f05844:mdtopdf \
		opf:omniauth:7eb21563ba047ef86d71f099975587b5ec88f9c9:omniauth \
		opf:omniauth-openid-connect:825d06235b64f6bc872bba709f1c2d48fd5cede4:omniauthoidc \
		opf:omniauth-openid_connect-providers:c7e2498a8b093cfc5693d4960cae2e903a5e10cd:omniauthoidcprov

# frontend/package.json pulls op-blocknote-extensions as a GitHub
# *release* tarball (not a git repo). GH_TUPLE is the wrong shape.
# DISTFILES + MASTER_SITES is the ports-native way. npm 12 defaults
# allow-remote=none and dies with EALLOWREMOTE on that https URL.
# Vendor the tarball, rewrite the spec to file:, keep remotes blocked.
BLOCKNOTE_VER=	0.2.1
BLOCKNOTE_DIST=	op-blocknote-extensions-${BLOCKNOTE_VER}.tgz
MASTER_SITES+=	https://github.com/opf/op-blocknote-extensions/releases/download/v${BLOCKNOTE_VER}/:blocknote
DISTFILES+=	${BLOCKNOTE_DIST}:blocknote
EXTRACT_ONLY=	${_DISTFILES:N${BLOCKNOTE_DIST}}

# Native port modeled on www/gitlab (rc.d, Gemfile patches, files/,
# dynamic WWWDIR plist) plus CloudBSD JSON/rc.d/mdoc/doctor wrappers.
# www/redmine is not the pattern for this tree. Not NO_ARCH.
# Docker/.deb/linux_base are not used; official installers need
# systemd/cgroups. The old FreeBSD 10 rsmith howto is historical only.
#
# Upstream .ruby-version is 4.0.2. lang/ruby40 in this tree is 4.0.6
# (closest packaged Ruby). This tree's Mk/Uses/ruby.mk accepts only
# build/extconf/none/run/setup — not a version token. Pin with
# RUBY_VER=4.0 (ruby:4.0,build,run is IGNORE: Incorrect USES).
# Default RUBY_DEFAULT is 3.4, so ${LOCALBASE}/bin/ruby is ruby34.
# do-build must never call unversioned ruby/bundle: bin/rails is
# #!/usr/bin/env ruby and would leak 3.4.9 (Bundler::RubyVersionMismatch).
# Native gems in 17.7.2: nokogiri, pg, ffi. commonmarker 2.8.3 wraps
# comrak and has no freebsd prebuilt gem — rust/cargo is required.
# rugged is not in Gemfile.lock; do not add it.
# USES=cargo is not used: this is not a Rust port.
#
# Day-one: no BIM IFC Linux blobs, no hocuspocus, no Appsignal.
# Monolith: bundle config set --local {path,without,deployment}; bundle
# install --jobs/--retry only (Bundler 4 removed --deployment/--without).
# into WWWDIR; npm ci; assets:precompile. Node is BUILD only.
# Runtime: two rc.d scripts (Puma 127.0.0.1:3000 and good_job worker).
# PostgreSQL 17 client (server is a sibling jail/service). nginx is
# already the reverse proxy (sample only; not a RUN_DEPENDS).
# Config is under etc/cloudbsd/openproject (CloudBSD JSON law;
# sysutils/hawkeye). Not ${PREFIX}/etc/openproject.
#
# This tree's Mk/Uses is pkgconfig.mk (not pkgconf.mk).
USES=		cpe gmake nodejs:24,build pgsql:17 pkgconfig \
		ruby:build,run shebangfix ssl uidfix
RUBY_VER=	4.0
# shebangfix defaults ruby_CMD to ${LOCALBASE}/bin/ruby (ruby34).
ruby_CMD=	${RUBY}
CPE_VENDOR=	openproject
CPE_PRODUCT=	openproject
SHEBANG_FILES=	bin/rails bin/rake

LIB_DEPENDS=	libffi.so:devel/libffi \
		libxml2.so:textproc/libxml2 \
		libxslt.so:textproc/libxslt

# rust/cargo: commonmarker 2.x (comrak). git: leftover git gem ops.
# jq is only needed if the optional JSON wrapper generates ENV.
# bundle is invoked as ${RUBY} -S ${LOCALBASE}/bin/bundle so a
# ruby34 shebang on the unversioned wrapper cannot leak. Prefer
# bundle40 when the jail/package provides it (see OP_BUNDLE).
BUILD_DEPENDS=	${LOCALBASE}/bin/bundle:sysutils/rubygem-bundler \
		${LOCALBASE}/bin/cargo:lang/rust \
		${LOCALBASE}/bin/npm:www/npm-node24 \
		git:devel/git
RUN_DEPENDS=	jq:textproc/jq \
		${LOCALBASE}/bin/bundle:sysutils/rubygem-bundler \
		${LOCALBASE}/bin/magick:graphics/ImageMagick7@nox11

USERS=		openproject
GROUPS=		openproject

USE_RC_SUBR=	openproject openproject_worker
SUB_FILES=	pkg-message openproject-ctl openproject.8 openproject.conf.5
SUB_LIST=	PREFIX=${PREFIX} \
		WWWDIR=${WWWDIR} \
		VERSION=${DISTVERSION} \
		USERS=${USERS} \
		GROUPS=${GROUPS} \
		RUBY=${RUBY}
PLIST_SUB=	USERS=${USERS} GROUPS=${GROUPS} WWWDIR=${WWWDIR_REL}

OPTIONS_DEFINE=		MEMCACHED PLAINTEXT PROMETHEUS
OPTIONS_DEFAULT=	MEMCACHED
OPTIONS_SUB=		yes

MEMCACHED_DESC=		memcached for Rails cache store
PLAINTEXT_DESC=		allow OPENPROJECT_HTTPS=false (no TLS from nginx)
PROMETHEUS_DESC=	yabeda Prometheus metrics (off day one)

MEMCACHED_RUN_DEPENDS=	${LOCALBASE}/bin/memcached:databases/memcached
# postgresql17 client comes from USES=pgsql:17. Server is sibling/external.
# nginx is already installed on track (TLS + X-Forwarded-Proto https).

WWWDIR=		${PREFIX}/www/openproject

# Official OpenProject build uses these bundle/npm settings.
# CARGO_HOME keeps commonmarker's comrak compile off $HOME.
#
# WRKDIR/.bin is a PATH shim: `ruby` is ruby40 so #!/usr/bin/env ruby
# (bin/rails, gem binstubs) cannot leak ruby34. bundle is bundle40
# when present, else a wrapper that execs ruby40 -S bundle.
# NPM_CONFIG_ALLOW_REMOTE=none: do not disable npm remote policy.
# NPM_CONFIG_ALLOW_FILE=root: the one vendored BlockNote tarball.
BUNDLE_PATH_REL=	vendor/bundle
OP_BINDIR=	${WRKDIR}/.bin
OP_BUNDLE=	${OP_BINDIR}/bundle
MAKE_ENV+=	HOME=${WRKDIR} \
		PATH=${OP_BINDIR}:${PATH} \
		RAILS_ENV=production \
		BUNDLE_PATH=${WRKSRC}/${BUNDLE_PATH_REL} \
		BUNDLE_WITHOUT=development:test:mysql2:sqlite \
		BUNDLE_RETRY=3 \
		CARGO_HOME=${WRKDIR}/.cargo \
		NPM_CONFIG_CACHE=${WRKDIR}/.npm \
		NPM_CONFIG_ALLOW_REMOTE=none \
		NPM_CONFIG_ALLOW_FILE=root

post-extract:
	${MKDIR} ${WRKSRC}/vendor/gems ${WRKSRC}/frontend/vendor
	${CP} -R ${WRKSRC_dentaku} ${WRKSRC}/vendor/gems/dentaku
	${CP} -R ${WRKSRC_mdtopdf} ${WRKSRC}/vendor/gems/md-to-pdf
	${CP} -R ${WRKSRC_omniauth} ${WRKSRC}/vendor/gems/omniauth
	${CP} -R ${WRKSRC_omniauthoidc} ${WRKSRC}/vendor/gems/omniauth-openid-connect
	${CP} -R ${WRKSRC_omniauthoidcprov} ${WRKSRC}/vendor/gems/omniauth-openid_connect-providers
	${CP} ${DISTDIR}/${BLOCKNOTE_DIST} \
		${WRKSRC}/frontend/vendor/${BLOCKNOTE_DIST}

post-patch:
	${REINPLACE_CMD} -e 's/^4\.0\.2$$/4.0.6/' ${WRKSRC}/.ruby-version
	${REINPLACE_CMD} -e 's|https://github.com/opf/op-blocknote-extensions/releases/download/v${BLOCKNOTE_VER}/${BLOCKNOTE_DIST}|file:vendor/${BLOCKNOTE_DIST}|g' \
		${WRKSRC}/frontend/package.json \
		${WRKSRC}/frontend/package-lock.json

# PATH shim so every nested `ruby` / `bundle` is 4.0. Prefer the
# versioned bundle40 binary; otherwise wrap unversioned bundle with
# ruby40 so its shebang cannot select 3.4.9.
pre-build:
	${MKDIR} ${OP_BINDIR}
	${LN} -sf ${RUBY} ${OP_BINDIR}/ruby
	@if [ -x ${LOCALBASE}/bin/bundle${RUBY_SUFFIX} ]; then \
		${LN} -sf ${LOCALBASE}/bin/bundle${RUBY_SUFFIX} ${OP_BINDIR}/bundle; \
		${ECHO_MSG} "===>  using ${LOCALBASE}/bin/bundle${RUBY_SUFFIX}"; \
	else \
		${PRINTF} '#!/bin/sh\nexec %s -S %s/bin/bundle "$$@"\n' \
			${RUBY} ${LOCALBASE} > ${OP_BINDIR}/bundle; \
		${CHMOD} +x ${OP_BINDIR}/bundle; \
		${ECHO_MSG} "===>  wrapping ${LOCALBASE}/bin/bundle with ${RUBY} -S"; \
	fi
	${LN} -sf ${RUBY} ${OP_BINDIR}/ruby${RUBY_SUFFIX}

do-build:
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${RUBY} -S ${OP_BUNDLE} config set --local path '${BUNDLE_PATH_REL}'
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${RUBY} -S ${OP_BUNDLE} config set --local without 'development test mysql2 sqlite'
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${RUBY} -S ${OP_BUNDLE} lock
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${RUBY} -S ${OP_BUNDLE} config set --local deployment true
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${RUBY} -S ${OP_BUNDLE} install \
		--jobs ${MAKE_JOBS_NUMBER} --retry 3
	# Root package.json postinstall is `cd frontend && npm install`
	# (that is the EALLOWREMOTE site). frontend spec is file:vendor/.
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/npm ci
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		SECRET_KEY_BASE=build-only-not-for-runtime \
		DATABASE_URL=nulldb://db \
		${RUBY} -S ${OP_BUNDLE} exec ${RUBY} bin/rails \
		openproject:plugins:register_frontend assets:precompile

do-install:
	${MKDIR} ${STAGEDIR}${WWWDIR} \
		${STAGEDIR}${PREFIX}/sbin \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/openproject \
		${STAGEDIR}${PREFIX}/etc/nginx \
		${STAGEDIR}${PREFIX}/share/man/man8 \
		${STAGEDIR}${PREFIX}/share/man/man5 \
		${STAGEDIR}${DOCSDIR} \
		${STAGEDIR}${WWWDIR}/tmp/pids \
		${STAGEDIR}/var/db/openproject \
		${STAGEDIR}/var/db/openproject/files \
		${STAGEDIR}/var/db/openproject/tmp \
		${STAGEDIR}/var/db/openproject/log \
		${STAGEDIR}/var/run/openproject
	(cd ${WRKSRC} && ${COPYTREE_SHARE} . ${STAGEDIR}${WWWDIR})
	${FIND} ${STAGEDIR}${WWWDIR} \( -name '*.orig' -o -name '*.bak' \) -delete
	${INSTALL_SCRIPT} ${WRKDIR}/openproject-ctl \
		${STAGEDIR}${PREFIX}/sbin/openproject
	${INSTALL_DATA} ${FILESDIR}/openproject.env.sample \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/openproject/openproject.env.sample
	${INSTALL_DATA} ${FILESDIR}/config.json.sample \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/openproject/config.json.sample
	${INSTALL_DATA} ${FILESDIR}/nginx.conf.sample \
		${STAGEDIR}${PREFIX}/etc/nginx/openproject.conf.sample
	${INSTALL_DATA} ${FILESDIR}/COPYRIGHT \
		${STAGEDIR}${DOCSDIR}/COPYRIGHT
	${INSTALL_MAN} ${WRKDIR}/openproject.8 \
		${STAGEDIR}${PREFIX}/share/man/man8
	${INSTALL_MAN} ${WRKDIR}/openproject.conf.5 \
		${STAGEDIR}${PREFIX}/share/man/man5

# WWWDIR is too large to maintain by hand (same approach as www/gitlab).
post-install:
	${FIND} -s ${STAGEDIR}${WWWDIR} -not -type d | ${SORT} | \
		${SED} -e 's#^${STAGEDIR}${PREFIX}/##' >> ${TMPPLIST}
	${ECHO_CMD} "@dir(%%USERS%%,%%GROUPS%%,755) ${WWWDIR_REL}" >> ${TMPPLIST}
	${ECHO_CMD} "@dir(%%USERS%%,%%GROUPS%%,755) ${WWWDIR_REL}/tmp" >> ${TMPPLIST}
	${ECHO_CMD} "@dir(%%USERS%%,%%GROUPS%%,755) ${WWWDIR_REL}/tmp/pids" >> ${TMPPLIST}

do-test:
	@${SH} -n ${FILESDIR}/openproject.in
	@${SH} -n ${FILESDIR}/openproject_worker.in
	@${SH} -n ${FILESDIR}/openproject-ctl.in
	@${SH} -n ${WRKDIR}/openproject-ctl
	@${GREP} -q 'RUBY_VER=	4.0' ${.CURDIR}/Makefile
	@${GREP} -q 'ruby:build,run' ${.CURDIR}/Makefile
	@${GREP} -q 'NPM_CONFIG_ALLOW_REMOTE=none' ${.CURDIR}/Makefile
	@${GREP} -q 'NPM_CONFIG_ALLOW_FILE=root' ${.CURDIR}/Makefile
	@${GREP} -q 'bundle40' ${FILESDIR}/openproject-ctl.in
	@if command -v mandoc >/dev/null 2>&1; then \
		mandoc -T lint -W error ${WRKDIR}/openproject.8 \
			${WRKDIR}/openproject.conf.5; \
	fi

.include <bsd.port.mk>
