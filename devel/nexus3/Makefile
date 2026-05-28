PORTNAME=	nexus3
PORTVERSION=	3.77.2.02
CATEGORIES=	devel www java
MASTER_SITES=	https://download.sonatype.com/nexus/3/
DISTNAME=	nexus-3.77.2-02-unix

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Sonatype Nexus Repository Manager 3
WWW=		https://www.sonatype.com/products/repository-oss

LICENSE=	EPL
LICENSE_FILE=	${WRKSRC}/OSS-LICENSE.txt

RUN_DEPENDS=	${LOCALBASE}/openjdk17/bin/java:java/openjdk17
BUILD_DEPENDS=	${LOCALBASE}/openjdk17/bin/java:java/openjdk17

USES=		cpe
CPE_VENDOR=	sonatype
CPE_PRODUCT=	nexus_repository

NO_ARCH=	yes
NO_BUILD=	yes
NO_TEST=	yes

USE_RC_SUBR=	nexus3

NEXUS_USER=	nexus
NEXUS_GROUP=	nexus
GROUPS=		${NEXUS_GROUP}
USERS=		${NEXUS_USER}

NEXUS_HOME=	${PREFIX}/nexus3
NEXUS_RUNDIR=	/var/run
NEXUS_LOGDIR=	/var/log/${PORTNAME}
NEXUS_WORKDIR=	/var/sonatype-work/${PORTNAME}

JAVA_HOME=	${LOCALBASE}/openjdk17

WRKSRC=		${WRKDIR}/nexus-3.77.2-02

SUB_FILES=	pkg-message
SUB_LIST=	NEXUS_RC=${PORTNAME} \
		DESC="${COMMENT}" \
		VERSION=${PORTVERSION} \
		USER=${NEXUS_USER} \
		GROUP=${NEXUS_GROUP} \
		HOME=${NEXUS_HOME} \
		RUNDIR=${NEXUS_RUNDIR} \
		LOGDIR=${NEXUS_LOGDIR} \
		WORKDIR=${NEXUS_WORKDIR} \
		JAVA_HOME=${JAVA_HOME}
PLIST_SUB=	USER=${NEXUS_USER} \
		GROUP=${NEXUS_GROUP} \
		HOME=${NEXUS_HOME} \
		RUNDIR=${NEXUS_RUNDIR} \
		LOGDIR=${NEXUS_LOGDIR} \
		WORKDIR=${NEXUS_WORKDIR} \
		VERSION=${PORTVERSION} \
		JAVA_HOME=${JAVA_HOME}

do-install:
	@${MKDIR} ${STAGEDIR}${NEXUS_HOME}
	@(cd ${WRKSRC} && ${COPYTREE_SHARE} . ${STAGEDIR}${NEXUS_HOME})
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

.include <bsd.port.mk>
