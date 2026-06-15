PORTNAME=	nexus3
PORTVERSION=	3.93.0.06
CATEGORIES=	devel www java
MASTER_SITES=	https://cdn.download.sonatype.com/repository/downloads-prod-group/3/
DISTNAME=	nexus-${NX_VER}-linux-x86_64

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Sonatype Nexus Repository Manager 3
WWW=		https://www.sonatype.com/products/repository-oss

LICENSE=	EPL
LICENSE_FILE=	${WRKSRC}/OSS-LICENSE.txt

RUN_DEPENDS=	${LOCALBASE}/openjdk21/bin/java:java/openjdk21
BUILD_DEPENDS=	${LOCALBASE}/openjdk21/bin/java:java/openjdk21

USES=		cpe
CPE_VENDOR=	sonatype
CPE_PRODUCT=	nexus_repository

NO_ARCH=	yes
NO_BUILD=	yes
NO_TEST=	yes

# Version for download filenames (PORTVERSION with last . replaced by -)
NX_VER=		${PORTVERSION:C/^(.+)\.(.+)$/\1-\2/}
# Architecture mapping for download filenames
_NX_ARCH=	${ARCH:S/amd64/x86_64/:S/aarch64/aarch_64/}

USE_RC_SUBR=	nexus3

NEXUS_USER=	nexus
NEXUS_GROUP=	nexus
GROUPS=		${NEXUS_GROUP}
USERS=		${NEXUS_USER}

NEXUS_HOME=	${PREFIX}/nexus3
VARDIR=	/var
VARRUN=	${VARDIR}/run
NEXUS_RUNDIR=	${VARRUN}
NEXUS_LOGDIR=	${VARDIR}/log/${PORTNAME}
NEXUS_WORKDIR=	${VARDIR}/sonatype-work/${PORTNAME}

JAVA_HOME=	${LOCALBASE}/openjdk21

WRKSRC=		${WRKDIR}/nexus-${NX_VER}

SUB_FILES=	pkg-message pkg-deinstall pkg-install
SUB_LIST=	NEXUS_RC=${PORTNAME} \
		DESC="${COMMENT}" \
		VERSION=${PORTVERSION} \
		USER=${NEXUS_USER} \
		GROUP=${NEXUS_GROUP} \
		HOME=${NEXUS_HOME} \
		PREFIX=${PREFIX} \
		VARDIR=${VARDIR} \
		RUNDIR=${NEXUS_RUNDIR} \
		LOGDIR=${NEXUS_LOGDIR} \
		WORKDIR=${NEXUS_WORKDIR} \
		JAVA_HOME=${JAVA_HOME}
PLIST_SUB=	USER=${NEXUS_USER} \
		GROUP=${NEXUS_GROUP} \
		HOME=${NEXUS_HOME} \
		VARDIR=${VARDIR} \
		RUNDIR=${NEXUS_RUNDIR} \
		LOGDIR=${NEXUS_LOGDIR} \
		WORKDIR=${NEXUS_WORKDIR} \
		VERSION=${PORTVERSION} \
		JAVA_HOME=${JAVA_HOME}

do-install:
	@${MKDIR} ${STAGEDIR}${NEXUS_HOME}
	@# Copy everything
	@(cd ${WRKSRC} && ${COPYTREE_SHARE} . ${STAGEDIR}${NEXUS_HOME})
	@# Remove bundled JDK - use system JDK instead
	@${RM} -rf ${STAGEDIR}${NEXUS_HOME}/jdk
	@${CHMOD} +x ${STAGEDIR}${NEXUS_HOME}/bin/nexus
	@${MKDIR} ${STAGEDIR}${NEXUS_WORKDIR}
	@${MKDIR} ${STAGEDIR}${NEXUS_WORKDIR}/log
	@${MKDIR} ${STAGEDIR}${NEXUS_WORKDIR}/tmp
	@${MKDIR} ${STAGEDIR}${NEXUS_RUNDIR}
	@${MKDIR} ${STAGEDIR}${NEXUS_LOGDIR}
	@${MKDIR} ${STAGEDIR}${PREFIX}/sonatype-work
	@${TOUCH} ${STAGEDIR}${NEXUS_WORKDIR}/clean_cache
	@${TOUCH} ${STAGEDIR}${NEXUS_WORKDIR}/log/.placeholder
	@${TOUCH} ${STAGEDIR}${NEXUS_WORKDIR}/tmp/.placeholder
	@${PW} groupadd ${NEXUS_GROUP} || true
	@${PW} useradd ${NEXUS_USER} -g ${NEXUS_GROUP} -d /nonexistent -s /usr/sbin/nologin || true
	@${CHOWN} -R ${NEXUS_USER}:${NEXUS_GROUP} ${STAGEDIR}${NEXUS_HOME}
	@${CHOWN} -R ${NEXUS_USER}:${NEXUS_GROUP} ${STAGEDIR}${NEXUS_WORKDIR}
	@${CHOWN} -R ${NEXUS_USER}:${NEXUS_GROUP} ${STAGEDIR}${PREFIX}/sonatype-work
	# Install pkg deinstall and install scripts
	@${MKDIR} ${STAGEDIR}${PREFIX}/pkgdb
	@${SED} -e 's|%%HOME%%|${NEXUS_HOME}|g' \
		${FILESDIR}/pkg-deinstall.in > ${STAGEDIR}${PREFIX}/pkgdb/+DEINSTALL
	@${CHMOD} 755 ${STAGEDIR}${PREFIX}/pkgdb/+DEINSTALL
	@${SED} -e 's|%%HOME%%|${NEXUS_HOME}|g' \
		${FILESDIR}/pkg-install.in > ${STAGEDIR}${PREFIX}/pkgdb/+INSTALL
	@${CHMOD} 755 ${STAGEDIR}${PREFIX}/pkgdb/+INSTALL

.include <bsd.port.mk>
