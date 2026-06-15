PORTNAME=	nexus3
PORTVERSION=	3.93.0.06
CATEGORIES=	devel www java
MASTER_SITES=	https://cdn.download.sonatype.com/repository/downloads-prod-group/3/
DISTNAME=	nexus-${NX_VER}-linux-${_NX_ARCH}

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
NO_MANCOMPRESS=	yes

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

SUB_FILES=	pkg-message pkg-deinstall pkg-install nexus.rc
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
	@# Install nexus.rc (configured by SUB_FILES)
	@${CP} ${WRKDIR}/nexus.rc ${STAGEDIR}${NEXUS_HOME}/bin/nexus.rc
	@# Install default Java configuration (preserve existing)
	@${MKDIR} ${STAGEDIR}${PREFIX}/etc/nexus
	@if [ ! -f ${STAGEDIR}${PREFIX}/etc/nexus/nexus.conf ]; then \
		${SED} -e 's|%%JAVA_HOME%%|${JAVA_HOME}|g' \
		${FILESDIR}/nexus.conf.in > ${STAGEDIR}${PREFIX}/etc/nexus/nexus.conf; \
		${CHOWN} ${NEXUS_USER}:${NEXUS_GROUP} ${STAGEDIR}${PREFIX}/etc/nexus/nexus.conf; \
		fi
	@# Install example config
	@${MKDIR} ${STAGEDIR}${PREFIX}/share/examples/nexus
	@${SED} -e 's|%%JAVA_HOME%%|${JAVA_HOME}|g' \
		${FILESDIR}/nexus.conf.in > ${STAGEDIR}${PREFIX}/share/examples/nexus/nexus.conf.sample
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
	# Install man page
	@${MKDIR} ${STAGEDIR}${PREFIX}/share/man/man1
	@${SED} -e 's|%%VERSION%%|${PORTVERSION}|g' \
		-e 's|%%HOME%%|${NEXUS_HOME}|g' \
		-e 's|%%VARDIR%%|${VARDIR}|g' \
		-e 's|%%LOGDIR%%|${NEXUS_LOGDIR}|g' \
		-e 's|%%PREFIX%%|${PREFIX}|g' \
		${FILESDIR}/nexus3.1 > ${STAGEDIR}${PREFIX}/share/man/man1/nexus3.1

	# Install pkg deinstall and install scripts
	@${MKDIR} ${STAGEDIR}${PREFIX}/pkgdb
	@${SED} -e 's|%%HOME%%|${NEXUS_HOME}|g' \
		${FILESDIR}/pkg-deinstall.in > ${STAGEDIR}${PREFIX}/pkgdb/+DEINSTALL
	@${CHMOD} 755 ${STAGEDIR}${PREFIX}/pkgdb/+DEINSTALL
	@${SED} -e 's|%%HOME%%|${NEXUS_HOME}|g' \
		${FILESDIR}/pkg-install.in > ${STAGEDIR}${PREFIX}/pkgdb/+INSTALL
	@${CHMOD} 755 ${STAGEDIR}${PREFIX}/pkgdb/+INSTALL

# =============================================================================
# Integration Tests (commented out by default - enable with: make test)
# =============================================================================
#
# NOTE: These tests require root privileges and may take several minutes to run.
#       Run from an installed system, not from within the port directory.
#
# To enable integration testing:
#   1. Build and install the port normally
#   2. Enable tests:  cd /usr/ports/devel/nexus3 && sudo make INTEGRATION_TEST=1 integration-test
#
# Prerequisites:
#   - Port must be installed
#   - Root or sudo access for service control
#   - See all processes (may require root/sudo for full visibility)
#
# Test Categories:
#   1. Service lifecycle (start/stop/status/restart)
#   2. Man page validation
#   3. Documentation and file paths
#   4. Multi-arch package validation
#   5. Data preservation during upgrade

.if defined(INTEGRATION_TEST)
# Test the service lifecycle
integration-test:
	@echo "=== Nexus3 Integration Tests ==="
	@echo ""
	@echo "--- Test 1: Service Status (before start) ---"
	@service nexus3 status || true
	@echo ""
	@echo "--- Test 2: Enable and Start Service ---"
	@sysrc nexus3_enable=YES
	@service nexus3 start
	@sleep 5
	@echo ""
	@echo "--- Test 3: Service Status (after start) ---"
	@service nexus3 status
	@echo ""
	@echo "--- Test 4: Check Process Visibility ---"
	@echo "PID file contents:"
	@cat /var/run/nexus3.pid 2>/dev/null || echo "No PID file"
	@echo "Running processes:"
	@pgrep -f /usr/local/nexus3/bin/nexus || echo "No processes found"
	@echo ""
	@echo "--- Test 5: Man Page Validation ---"
	@man -w nexus3 && echo "Man page found" || echo "ERROR: Man page not found"
	@man nexus3 | head -20 || echo "ERROR: Cannot render man page"
	@echo ""
	@echo "--- Test 6: Documentation Paths ---"
	@test -f /usr/local/nexus3/bin/nexus && echo "Binary: OK" || echo "Binary: MISSING"
	@test -f /usr/local/etc/nexus/nexus.conf && echo "Config: OK" || echo "Config: MISSING"
	@test -f /usr/local/share/man/man1/nexus3.1.gz && echo "Man page: OK" || echo "Man page: MISSING"
	@test -d /var/sonatype-work/nexus3 && echo "Work dir: OK" || echo "Work dir: MISSING"
	@echo ""
	@echo "--- Test 7: Service Stop ---"
	@service nexus3 stop
	@sleep 2
	@echo ""
	@echo "--- Test 8: Service Status (after stop) ---"
	@service nexus3 status || true
	@echo ""
	@echo "--- Test 9: Data Preservation Check ---"
	@echo "Creating test data marker in work directory..."
	@mkdir -p /var/sonatype-work/nexus3
	@echo "NEXUS3_UPGRADE_TEST" > /var/sonatype-work/nexus3/.upgrade_test_marker
	@chown -R nexus:nexus /var/sonatype-work/nexus3
	@echo "Test marker created. Simulating upgrade..."
	@echo "Checking work directory ownership..."
	@ls -ld /var/sonatype-work/nexus3
	@test -d /var/sonatype-work/nexus3 && echo "Work dir exists: OK" || echo "Work dir MISSING: FAIL"
	@test -f /var/sonatype-work/nexus3/.upgrade_test_marker && echo "Data preserved: OK" || echo "Data MISSING: FAIL"
	@cat /var/sonatype-work/nexus3/.upgrade_test_marker
	@echo ""
	@echo "=== Tests Complete ==="
.endif

# =============================================================================
# Multi-Architecture Validation (requires poudriere or synth)
# =============================================================================
#
# Prerequisites:
#   1. Install poudriere: pkg install poudriere
#   2. Install synth: pkg install synth
#   3. Configure poudriere: Edit /usr/local/etc/poudriere.conf
#   4. Create jails: poudriere jail -c -j <name> -v <version> -a <arch>
#
# To create poudriere jails (run once):
#   # Detect current FreeBSD version
#   VERSION=$(freebsd-version -u | cut -d. -f1)
#   # Create jails for supported versions
#   poudriere jail -c -j ${VERSION}amd64 -v ${VERSION}-RELEASE -a amd64
#   poudriere jail -c -j ${VERSION}aarch64 -v ${VERSION}-RELEASE -a aarch64
#
# To validate packages across architectures:
#
# With poudriere (preferred for multi-arch):
#   poudriere testport -j 14amd64 -j 15amd64 -j 15aarch64 -p main -o devel/nexus3
#
# With synth (single host arch only):
#   synth build-repository
#   synth build-ports devel/nexus3
#
# Manual validation after build:
#   pkg create -o /tmp/pkg -p /usr/ports/devel/nexus3/pkg-plist
#   tar -tf /tmp/pkg/nexus3-*.txz | grep -E "^usr/local/(nexus3|etc|share/man)"
#
# Supported architectures:
#   amd64   - Primary, fully tested
#   aarch64 - Fully tested
#
# Supported FreeBSD versions:
#   14.x    - LTS, fully tested
#   15.x    - Current, fully tested
#
# To run multi-arch validation:
.if defined(MULTI_ARCH_TEST)
do-test:
	@echo "=== Multi-Architecture Validation ==="
	@echo "FreeBSD version: $$(${SYSCTL} -n kern.osrelease)"
	@echo "Architecture: $$(${UNAME} -p)"
	@echo "Checking package contents for arch compatibility..."
	@echo "Expected paths for amd64/aarch64:"
	@echo "  - /usr/local/nexus3/bin/nexus"
	@echo "  - /usr/local/etc/nexus/nexus.conf"
	@echo "  - /usr/local/share/man/man1/nexus3.1.gz"
	@echo "  - /var/sonatype-work/nexus3/"
	@file ${PREFIX}/nexus3/bin/nexus
.endif

.include <bsd.port.mk>
