# Copyright (c) 2026 REVYTECH, Inc.
# SPDX-License-Identifier: BSD-3-Clause
#
# Part of CloudBSD (REVYTECH, Inc., founded 2026).
# Native CloudBSD port of official OpenProject. Wrapper files are
# REVYTECH BSD-3-Clause. OpenProject itself remains GPLv3.

PORTNAME=	openproject
DISTVERSIONPREFIX=	v
DISTVERSION=	17.7.2
PORTREVISION=	1
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
GH_TUPLE=	opf:dentaku:78eece45bf3f4ed021c05dd2f5411d1c3f9b168a:dentaku \
		opf:md-to-pdf:0cb4597becd2243b810e7ce53bbbbf28b5f05844:mdtopdf \
		opf:omniauth:7eb21563ba047ef86d71f099975587b5ec88f9c9:omniauth \
		opf:omniauth-openid-connect:825d06235b64f6bc872bba709f1c2d48fd5cede4:omniauthoidc \
		opf:omniauth-openid_connect-providers:c7e2498a8b093cfc5693d4960cae2e903a5e10cd:omniauthoidcprov

# Native port modeled on www/gitlab (rc.d, Gemfile patches, files/,
# dynamic WWWDIR plist) plus CloudBSD JSON/rc.d/mdoc/doctor wrappers.
# www/redmine is not the pattern for this tree. Not NO_ARCH.
# Docker/.deb/linux_base are not used; official installers need
# systemd/cgroups. The old FreeBSD 10 rsmith howto is historical only.
#
# Upstream .ruby-version is 4.0.2. lang/ruby40 in this tree is 4.0.6
# (closest packaged Ruby). Pin ruby:4.0 even if the default is 3.4.
# Native gems in 17.7.2: nokogiri, pg, ffi. commonmarker 2.8.3 wraps
# comrak and has no freebsd prebuilt gem — rust/cargo is required.
# rugged is not in Gemfile.lock; do not add it.
# USES=cargo is not used: this is not a Rust port.
#
# Day-one: no BIM IFC Linux blobs, no hocuspocus, no Appsignal.
# Build: vendor git gems, bundle into vendor/bundle, npm ci,
# assets:precompile. Runtime: two rc.d scripts (Puma 127.0.0.1:3000
# and good_job worker). nginx is already the jail reverse proxy
# (sample only; not a RUN_DEPENDS).
USES=		cpe gmake nodejs:24,build pkgconf ruby:4.0,build,run \
		shebangfix ssl uidfix
CPE_VENDOR=	openproject
CPE_PRODUCT=	openproject
SHEBANG_FILES=	bin/rails bin/rake

LIB_DEPENDS=	libffi.so:devel/libffi \
		libxml2.so:textproc/libxml2 \
		libxslt.so:textproc/libxslt

# rust/cargo: commonmarker 2.x (comrak). git: leftover git gem ops.
# jq is only needed if the optional JSON wrapper generates ENV.
BUILD_DEPENDS=	${LOCALBASE}/bin/bundle:sysutils/rubygem-bundler \
		${LOCALBASE}/bin/cargo:lang/rust \
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
		GROUPS=${GROUPS}
PLIST_SUB=	USERS=${USERS} GROUPS=${GROUPS} WWWDIR=${WWWDIR_REL}

OPTIONS_DEFINE=		MEMCACHED
OPTIONS_SINGLE=		PGVER
OPTIONS_SINGLE_PGVER=	PG16 PG17
OPTIONS_DEFAULT=	PG17 MEMCACHED
OPTIONS_SUB=		yes

PG16_DESC=		PostgreSQL 16 client and server
PG17_DESC=		PostgreSQL 17 client and server
MEMCACHED_DESC=		memcached for Rails cache store

PG16_USES=		pgsql:16
PG16_RUN_DEPENDS=	postgres:databases/postgresql16-server
PG17_USES=		pgsql:17
PG17_RUN_DEPENDS=	postgres:databases/postgresql17-server
MEMCACHED_RUN_DEPENDS=	${LOCALBASE}/bin/memcached:databases/memcached
# nginx is already installed on track (TLS + X-Forwarded-Proto https).
# files/nginx.conf.sample is installed unconditionally; no nginx RUN_DEPENDS.

WWWDIR=		${PREFIX}/www/openproject

# Official OpenProject build uses these bundle/npm settings.
# CARGO_HOME keeps commonmarker's comrak compile off $HOME.
BUNDLE_PATH_REL=	vendor/bundle
MAKE_ENV+=	HOME=${WRKDIR} \
		RAILS_ENV=production \
		BUNDLE_PATH=${WRKSRC}/${BUNDLE_PATH_REL} \
		BUNDLE_WITHOUT=development:test \
		BUNDLE_RETRY=3 \
		CARGO_HOME=${WRKDIR}/.cargo \
		NPM_CONFIG_CACHE=${WRKDIR}/.npm

post-extract:
	${MKDIR} ${WRKSRC}/vendor/gems
	${CP} -R ${WRKSRC_dentaku} ${WRKSRC}/vendor/gems/dentaku
	${CP} -R ${WRKSRC_mdtopdf} ${WRKSRC}/vendor/gems/md-to-pdf
	${CP} -R ${WRKSRC_omniauth} ${WRKSRC}/vendor/gems/omniauth
	${CP} -R ${WRKSRC_omniauthoidc} ${WRKSRC}/vendor/gems/omniauth-openid-connect
	${CP} -R ${WRKSRC_omniauthoidcprov} ${WRKSRC}/vendor/gems/omniauth-openid_connect-providers

post-patch:
	${REINPLACE_CMD} -e 's/^4\.0\.2$$/4.0.6/' ${WRKSRC}/.ruby-version

do-build:
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/bundle config set --local path '${BUNDLE_PATH_REL}'
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/bundle config set --local without 'development test'
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/bundle install --jobs ${MAKE_JOBS_NUMBER} --retry 3
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/npm ci
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		SECRET_KEY_BASE=build-only-not-for-runtime \
		DATABASE_URL=nulldb://db \
		${LOCALBASE}/bin/bundle exec bin/rails \
		openproject:plugins:register_frontend assets:precompile

do-install:
	${MKDIR} ${STAGEDIR}${WWWDIR} \
		${STAGEDIR}${PREFIX}/sbin \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/openproject \
		${STAGEDIR}${PREFIX}/etc/nginx \
		${STAGEDIR}${PREFIX}/share/man/man8 \
		${STAGEDIR}${PREFIX}/share/man/man5 \
		${STAGEDIR}${DOCSDIR} \
		${STAGEDIR}${WWWDIR}/log \
		${STAGEDIR}${WWWDIR}/tmp/pids \
		${STAGEDIR}${WWWDIR}/tmp/cache \
		${STAGEDIR}${WWWDIR}/files \
		${STAGEDIR}/var/db/openproject \
		${STAGEDIR}/var/log/openproject \
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
	${ECHO_CMD} "@dir(%%USERS%%,%%GROUPS%%,755) ${WWWDIR_REL}/log" >> ${TMPPLIST}
	${ECHO_CMD} "@dir(%%USERS%%,%%GROUPS%%,755) ${WWWDIR_REL}/tmp" >> ${TMPPLIST}
	${ECHO_CMD} "@dir(%%USERS%%,%%GROUPS%%,755) ${WWWDIR_REL}/tmp/pids" >> ${TMPPLIST}
	${ECHO_CMD} "@dir(%%USERS%%,%%GROUPS%%,755) ${WWWDIR_REL}/files" >> ${TMPPLIST}

do-test:
	@${SH} -n ${FILESDIR}/openproject.in
	@${SH} -n ${FILESDIR}/openproject_worker.in
	@${SH} -n ${WRKDIR}/openproject-ctl
	@if command -v mandoc >/dev/null 2>&1; then \
		mandoc -T lint -W error ${WRKDIR}/openproject.8 \
			${WRKDIR}/openproject.conf.5; \
	fi

.include <bsd.port.mk>
