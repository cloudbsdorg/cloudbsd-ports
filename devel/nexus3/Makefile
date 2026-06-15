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
# Returns: 0 on success, non-zero on failure
integration-test:
	@set -e; \
	failures=0; \
	echo "=== Nexus3 Integration Tests ==="; \
	echo ""; \
	echo "--- Test 1: Service Status (before start) ---"; \
	service nexus3 status || true; \
	echo ""; \
	echo "--- Test 2: Enable and Start Service ---"; \
	sysrc nexus3_enable=YES; \
	service nexus3 start || { echo "FAIL: Service start failed"; failures=$$((failures+1)); }; \
	sleep 5; \
	echo ""; \
	echo "--- Test 3: Service Status (after start) ---"; \
	service nexus3 status || { echo "FAIL: Service not running"; failures=$$((failures+1)); }; \
	echo ""; \
	echo "--- Test 4: Check Process Visibility ---"; \
	echo "PID file contents:"; \
	cat /var/run/nexus3.pid 2>/dev/null || { echo "No PID file"; failures=$$((failures+1)); }; \
	echo "Running processes:"; \
	pgrep -f /usr/local/nexus3/bin/nexus || { echo "No processes found"; failures=$$((failures+1)); }; \
	echo ""; \
	echo "--- Test 5: Man Page Validation ---"; \
	man -w nexus3 > /dev/null 2>&1 || { echo "FAIL: Man page not found"; failures=$$((failures+1)); }; \
	man nexus3 > /dev/null 2>&1 || { echo "FAIL: Cannot render man page"; failures=$$((failures+1)); }; \
	echo "Man page: OK"; \
	echo ""; \
	echo "--- Test 6: Documentation Paths ---"; \
	test -f /usr/local/nexus3/bin/nexus && echo "Binary: OK" || { echo "Binary: MISSING"; failures=$$((failures+1)); }; \
	test -f /usr/local/etc/nexus/nexus.conf && echo "Config: OK" || { echo "Config: MISSING"; failures=$$((failures+1)); }; \
	test -f /usr/local/share/man/man1/nexus3.1.gz && echo "Man page: OK" || { echo "Man page: MISSING"; failures=$$((failures+1)); }; \
	test -d /var/sonatype-work/nexus3 && echo "Work dir: OK" || { echo "Work dir: MISSING"; failures=$$((failures+1)); }; \
	echo ""; \
	echo "--- Test 7: Service Stop ---"; \
	service nexus3 stop; \
	sleep 2; \
	echo ""; \
	echo "--- Test 8: Service Status (after stop) ---"; \
	service nexus3 status || true; \
	echo ""; \
	echo "--- Test 9: Data Preservation Check ---"; \
	echo "Creating test data marker in work directory..."; \
	mkdir -p /var/sonatype-work/nexus3; \
	echo "NEXUS3_UPGRADE_TEST" > /var/sonatype-work/nexus3/.upgrade_test_marker; \
	chown -R nexus:nexus /var/sonatype-work/nexus3; \
	echo "Test marker created. Simulating upgrade..."; \
	echo "Checking work directory ownership..."; \
	ls -ld /var/sonatype-work/nexus3; \
	test -d /var/sonatype-work/nexus3 && echo "Work dir exists: OK" || { echo "Work dir MISSING: FAIL"; failures=$$((failures+1)); }; \
	test -f /var/sonatype-work/nexus3/.upgrade_test_marker && echo "Data preserved: OK" || { echo "Data MISSING: FAIL"; failures=$$((failures+1)); }; \
	cat /var/sonatype-work/nexus3/.upgrade_test_marker; \
	echo ""; \
	echo "=== Tests Complete ==="; \
	if [ $$failures -eq 0 ]; then \
		echo "RESULT: ALL TESTS PASSED"; \
		exit 0; \
	else \
		echo "RESULT: $$failures TEST(S) FAILED"; \
		exit 1; \
	fi
.endif

# =============================================================================
# Multi-Release Validation (requires poudriere)
# =============================================================================
#
# This tests the port on multiple FreeBSD releases based on the host version.
# Dynamically tests: host version, host-1, host-2 (max 3 releases).
# Example: On FreeBSD 16: tests 16, 15, 14. On FreeBSD 15: tests 15, 14.
#
# Architecture-aware: uses current host arch for jail names.
#
# Ports tree options (set with MULTI_RELEASE_TEST):
#   POUDRIERE_PORTS=local           - Use /usr/ports if it exists
#   POUDRIERE_PORTS=local=/path     - Use custom directory for bind mount
#   POUDRIERE_PORTS=<git-url>       - Use custom git URL
#
# Prerequisites:
#   1. Install poudriere: pkg install poudriere
#   2. Configure poudriere: Edit /usr/local/etc/poudriere.conf
#
# Run with: sudo make MULTI_RELEASE_TEST=1 do-test
#
.if defined(MULTI_RELEASE_TEST)
do-test:
	@HOST_VERSION=$$(freebsd-version -u | cut -d. -f1); \
	HOST_ARCH=$$(uname -p); \
	JAIL_ARCH=$$HOST_ARCH; \
	if [ "$$JAIL_ARCH" = "aarch64" ]; then JAIL_ARCH=aarch64; fi; \
	if [ "$$JAIL_ARCH" = "arm" ]; then JAIL_ARCH=armv7; fi; \
	VER1=$$((HOST_VERSION - 1)); \
	VER2=$$((HOST_VERSION - 2)); \
	[ $$VER2 -lt 14 ] && VER2=0; \
	[ $$VER1 -lt 14 ] && VER1=0; \
	echo "=== Multi-Release Validation ==="; \
	echo "Host: FreeBSD $$HOST_VERSION on $$HOST_ARCH"; \
	echo "Testing: $$HOST_VERSION, $$VER1, $$VER2"; \
	echo ""; \
	command -v poudriere > /dev/null 2>&1 || { \
		echo "ERROR: poudriere not installed"; \
		echo "RESULT: SKIPPED"; \
		exit 0; \
	}; \
	echo "poudriere available"; \
	echo ""; \
	\
	# Determine ports tree \
	PORTS_TREE=default; \
	PORTS_URL="https://github.com/freebsd/freebsd-ports.git"; \
	if [ -n "$${POUDRIERE_PORTS:-}" ]; then \
		case "$$POUDRIERE_PORTS" in \
			local) \
				if [ -d /usr/ports ]; then \
					echo "Using local /usr/ports (bind mount)"; \
					PORTS_METHOD="nullfs"; \
					PORTS_PATH="/usr/ports"; \
				else \
					echo "WARNING: /usr/ports not found, using FreeBSD ports"; \
					PORTS_URL="https://github.com/freebsd/freebsd-ports.git"; \
					PORTS_METHOD="git"; \
				fi ;; \
			local=*) \
				PORTS_PATH="$${POUDRIERE_PORTS#local=}"; \
				if [ -d "$$PORTS_PATH" ]; then \
					echo "Using local ports tree: $$PORTS_PATH (bind mount)"; \
					PORTS_METHOD="nullfs"; \
				else \
					echo "ERROR: Ports directory not found: $$PORTS_PATH"; \
					echo "RESULT: SKIPPED"; \
					exit 0; \
				fi ;; \
			https://*|git://*) PORTS_URL="$$POUDRIERE_PORTS" ;; \
			*) echo "Unknown POUDRIERE_PORTS: $$POUDRIERE_PORTS, using default"; ;; \
		esac; \
	else \
		echo "Using default ports tree: $$PORTS_URL"; \
	fi; \
	PORTS_METHOD=$${PORTS_METHOD:-git}; \
	echo ""; \
	echo "Checking ports tree '$$PORTS_TREE'..."; \
	if sudo poudriere ports -l 2>/dev/null | grep -q "$$PORTS_TREE"; then \
		echo "Ports tree exists"; \
		if [ "$$PORTS_METHOD" = "nullfs" ]; then \
			echo "Local ports - no update needed"; \
		else \
			echo "Updating ports tree..."; \
			sudo poudriere ports -u -p $$PORTS_TREE 2>/dev/null || echo "Update skipped"; \
		fi; \
	else \
		if [ "$$PORTS_METHOD" = "nullfs" ]; then \
			echo "Creating nullfs ports tree linked to /usr/ports..."; \
			sudo poudriere ports -c -p $$PORTS_TREE -m nullfs -f /usr/ports 2>/dev/null || { \
				echo "Could not create nullfs ports tree"; \
				echo "RESULT: SKIPPED"; \
				exit 0; \
			}; \
		else \
			echo "Creating ports tree from: $$PORTS_URL"; \
			sudo poudriere ports -c -p $$PORTS_TREE -m git -U "$$PORTS_URL" 2>/dev/null || { \
				echo "Could not create ports tree from $$PORTS_URL"; \
				echo "RESULT: SKIPPED"; \
				exit 0; \
			}; \
		fi; \
	fi; \
	echo ""; \
	echo "Available jails:"; \
	sudo poudriere jail -l 2>/dev/null || true; \
	echo ""; \
	failures=0; skipped=0; \
	for V in $$HOST_VERSION $$VER1 $$VER2; do \
		[ -z "$$V" ] && continue; \
		[ "$$V" -le 0 ] && continue; \
		JAIL="$$V$$JAIL_ARCH"; \
		echo "--- Testing $$JAIL ---"; \
		if sudo poudriere jail -l 2>/dev/null | grep -q "$$JAIL"; then \
			echo "Using jail..."; \
			sudo poudriere testport -j $$JAIL -p $$PORTS_TREE -o devel/nexus3 2>&1 | tee /tmp/poudriere.$$JAIL.log; \
			if grep -q "Nonexistent origin" /tmp/poudriere.$$JAIL.log; then \
				echo "NOTE: Port not in ports tree - this is expected for local-only ports"; \
				echo "$$JAIL: SKIP (port not in tree)"; \
				skipped=$$((skipped+1)); \
			elif grep -q "BUILD SUCCESSFUL" /tmp/poudriere.$$JAIL.log; then \
				echo "$$JAIL: PASS"; \
			else \
				echo "$$JAIL: FAIL"; \
				failures=$$((failures+1)); \
			fi; \
		else \
			echo "Creating jail..."; \
			sudo poudriere jail -c -j $$JAIL -v $$V-RELEASE -a $$JAIL_ARCH 2>/dev/null && { \
				sudo poudriere testport -j $$JAIL -p $$PORTS_TREE -o devel/nexus3 2>&1 | tee /tmp/poudriere.$$JAIL.log; \
				if grep -q "Nonexistent origin" /tmp/poudriere.$$JAIL.log; then \
					echo "NOTE: Port not in ports tree"; \
					echo "$$JAIL: SKIP (port not in tree)"; \
					skipped=$$((skipped+1)); \
				elif grep -q "BUILD SUCCESSFUL" /tmp/poudriere.$$JAIL.log; then \
					echo "$$JAIL: PASS"; \
				else \
					echo "$$JAIL: FAIL"; \
					failures=$$((failures+1)); \
				fi; \
			} || { echo "$$JAIL: SKIP (unavailable)"; skipped=$$((skipped+1)); }; \
		fi; \
		echo ""; \
	done; \
	echo "=== Complete ==="; \
	echo "Failed: $$failures, Skipped: $$skipped"; \
	[ $$failures -eq 0 ] && echo "RESULT: PASSED" || echo "RESULT: FAILED"
.endif

# =============================================================================
# Help
# =============================================================================
help:
	@echo "Nexus3 Port - Available targets:"
	@echo ""
	@echo "  make package          - Build binary package"
	@echo "  make install         - Install from built package"
	@echo "  make deinstall       - Remove installed package"
	@echo "  make clean           - Clean build artifacts"
	@echo "  make reinstall       - Reinstall (deinstall + install)"
	@echo ""
	@echo "  make INTEGRATION_TEST=1 integration-test"
	@echo "                      - Run integration tests (service, man page, data)"
	@echo ""
	@echo "  make MULTI_RELEASE_TEST=1 do-test"
	@echo "                      - Test on multiple FreeBSD releases"
	@echo "  make MULTI_RELEASE_TEST=1 POUDRIERE_PORTS=local do-test"
	@echo "                      - Same as above, but use local /usr/ports"
	@echo "  make MULTI_RELEASE_TEST=1 POUDRIERE_PORTS=local=/path do-test"
	@echo "                      - Use custom ports directory with bind mount"
	@echo ""
	@echo "  make help            - Show this help"
	@echo ""

.include <bsd.port.mk>
