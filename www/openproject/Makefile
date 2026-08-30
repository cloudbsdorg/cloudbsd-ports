# Copyright (c) 2026 REVYTECH, Inc.
# SPDX-License-Identifier: BSD-3-Clause
#
# Part of CloudBSD (REVYTECH, Inc., founded 2026).
# Native CloudBSD port of official OpenProject. Wrapper files are
# REVYTECH BSD-3-Clause. OpenProject itself remains GPLv3.

PORTNAME=	openproject
DISTVERSIONPREFIX=	v
DISTVERSION=	17.7.2
CATEGORIES=	www

MAINTAINER=	mark@cloudbsd.org
COMMENT=	OpenProject project management (Rails, Puma, PostgreSQL)
WWW=		https://www.openproject.org/

LICENSE=	BSD3CLAUSE GPLv3
LICENSE_COMB=	multi
LICENSE_FILE_BSD3CLAUSE=	${FILESDIR}/COPYRIGHT
LICENSE_FILE_GPLv3=	${WRKSRC}/LICENSE

USE_GITHUB=	yes
GH_ACCOUNT=	opf
GH_PROJECT=	openproject

# Native build: official source, bundle into vendor/bundle, npm +
# assets:precompile (same steps as OpenProject docker/prod/setup).
# Runtime is Puma on 127.0.0.1:3000 behind nginx. No linux_base, Docker,
# or deb packages.
USES=		cpe gmake nodejs:24,build ruby:4.0,build,run ssl
CPE_VENDOR=	openproject
CPE_PRODUCT=	openproject

# jq translates CloudBSD JSON into OpenProject ENV. ImageMagick is used
# by mini_magick for attachments. bundler drives vendor/bundle.
BUILD_DEPENDS=	${LOCALBASE}/bin/bundle:sysutils/rubygem-bundler
RUN_DEPENDS=	jq:textproc/jq \
		${LOCALBASE}/bin/bundle:sysutils/rubygem-bundler \
		${LOCALBASE}/bin/magick:graphics/ImageMagick7

USERS=		openproject
GROUPS=		openproject

USE_RC_SUBR=	openproject
SUB_FILES=	pkg-message openproject-ctl openproject.8 openproject.conf.5
SUB_LIST=	PREFIX=${PREFIX} \
		WWWDIR=${WWWDIR} \
		VERSION=${DISTVERSION} \
		USERS=${USERS} \
		GROUPS=${GROUPS}
PLIST_SUB=	USERS=${USERS} GROUPS=${GROUPS} WWWDIR=${WWWDIR_REL}

OPTIONS_DEFINE=		MEMCACHED NGINX
OPTIONS_SINGLE=		PGVER
OPTIONS_SINGLE_PGVER=	PG16 PG17
OPTIONS_DEFAULT=	PG17 MEMCACHED NGINX
OPTIONS_SUB=		yes

PG16_DESC=		PostgreSQL 16 client and server
PG17_DESC=		PostgreSQL 17 client and server
MEMCACHED_DESC=		memcached for Rails cache store
NGINX_DESC=		nginx reverse proxy sample (X-Forwarded-Proto https)

PG16_USES=		pgsql:16
PG16_RUN_DEPENDS=	postgres:databases/postgresql16-server
PG17_USES=		pgsql:17
PG17_RUN_DEPENDS=	postgres:databases/postgresql17-server
MEMCACHED_RUN_DEPENDS=	${LOCALBASE}/bin/memcached:databases/memcached
NGINX_RUN_DEPENDS=	nginx:www/nginx

# Official OpenProject build uses these bundle/npm settings.
BUNDLE_PATH_REL=	vendor/bundle
MAKE_ENV+=	HOME=${WRKDIR} \
		RAILS_ENV=production \
		BUNDLE_PATH=${WRKSRC}/${BUNDLE_PATH_REL} \
		BUNDLE_WITHOUT=development:test \
		BUNDLE_RETRY=3 \
		NPM_CONFIG_CACHE=${WRKDIR}/.npm

do-build:
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/bundle config set --local path '${BUNDLE_PATH_REL}'
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/bundle config set --local without 'development test'
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/bundle install --jobs ${MAKE_JOBS_NUMBER} --retry 3
	cd ${WRKSRC} && ${SETENV} ${MAKE_ENV} \
		${LOCALBASE}/bin/npm install
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
	@${SH} -n ${WRKDIR}/openproject-ctl
	@if command -v mandoc >/dev/null 2>&1; then \
		mandoc -T lint -W error ${WRKDIR}/openproject.8 \
			${WRKDIR}/openproject.conf.5; \
	fi

.include <bsd.port.mk>
