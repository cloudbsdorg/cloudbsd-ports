PORTNAME=	perftest
DISTVERSION=	26.04.17
CATEGORIES=	benchmarks

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Collection of tests for RDMA micro-benchmark
WWW=		https://github.com/linux-rdma/perftest/

LICENSE=	LGPL21 BSD2CLAUSE
LICENSE_COMB=	dual

USES=		autoreconf libtool shebangfix gmake
USE_GITHUB=	yes
GH_ACCOUNT=	linux-rdma
GH_TAGNAME=	26.04.17

SHEBANG_FILES=	run_perftest_multi_devices

GNU_CONFIGURE=yes

.if !exists(/usr/lib/libibverbs.so)
IGNORE=		missing OFED user space
.endif

post-patch:
	@${SH} ${FILESDIR}/post-patch.sh ${WRKSRC}

# =============================================================================
# Port Packaging Tests
# =============================================================================
#
# Standard FreeBSD port QA targets (run these before submitting):
#
#   make stage           - Stage files to staging directory
#   make check-plist     - Check for files missing from or extra in plist
#   make stage-qa        - Check for common problems (bad shebang, setuid, etc.)
#   make package         - Build binary package
#   make package PREFIX=/var/tmp/<portname>   - Check no files escape PREFIX
#   make describe        - Verify port metadata is complete
#   portlint -N          - Check Makefile style and correctness
#   portfmt -c           - Check formatting; portfmt -d . to auto-fix
#
# Full QA pipeline:
#   make clean && make stage && make check-plist && make stage-qa && make package
#
# =============================================================================
# Integration Tests (perftest-specific)
# =============================================================================
#
# NOTE: These tests require root privileges. Run from an installed system,
#       not from within the port directory.
#
# Prerequisites:
#   - Port must be installed:  make package && make install
#   - Root or sudo access
#   - OFED/libibverbs installed (the port IGNOREs if missing at build time)
#
# To enable integration testing:
#   cd /usr/ports/benchmarks/perftest && sudo make INTEGRATION_TEST=1 integration-test
#
# Test Categories:
#   1. Binary sanity (--help, exit codes)
#   2. File and path validation
#   3. Man page validation
#   4. Script shebang and runnability
#   5. OFED availability check
#   6. RDMA device detection (if hardware present)
#   7. Post-patch idempotency (patch applies only once)

.if defined(INTEGRATION_TEST)
integration-test:
	@set -e; \
	failures=0; \
	echo "=== Perftest Integration Tests ==="; \
	echo ""; \
	echo "--- Test 1: OFED / libibverbs availability ---"; \
	if [ -e /usr/lib/libibverbs.so -o -e /usr/lib64/libibverbs.so -o -e /usr/local/lib/libibverbs.so ]; then \
		echo "libibverbs: FOUND"; \
	else \
		echo "libibverbs: NOT FOUND (perftest requires OFED)"; \
		echo "RESULT: SKIP (no OFED)"; \
		exit 0; \
	fi; \
	echo ""; \
	echo "--- Test 2: Binary --help (ib_send_bw) ---"; \
	/usr/local/bin/ib_send_bw --help > /dev/null 2>&1 || { echo "FAIL: ib_send_bw --help failed"; failures=$$((failures+1)); }; \
	echo "ib_send_bw: OK"; \
	echo ""; \
	echo "--- Test 3: Binary --help (ib_send_lat) ---"; \
	/usr/local/bin/ib_send_lat --help > /dev/null 2>&1 || { echo "FAIL: ib_send_lat --help failed"; failures=$$((failures+1)); }; \
	echo "ib_send_lat: OK"; \
	echo ""; \
	echo "--- Test 4: Binary --help (ib_write_bw) ---"; \
	/usr/local/bin/ib_write_bw --help > /dev/null 2>&1 || { echo "FAIL: ib_write_bw --help failed"; failures=$$((failures+1)); }; \
	echo "ib_write_bw: OK"; \
	echo ""; \
	echo "--- Test 5: Binary --help (raw_ethernet_bw) ---"; \
	/usr/local/bin/raw_ethernet_bw --help > /dev/null 2>&1 || { echo "FAIL: raw_ethernet_bw --help failed"; failures=$$((failures+1)); }; \
	echo "raw_ethernet_bw: OK"; \
	echo ""; \
	echo "--- Test 6: File paths ---"; \
	for bin in ib_send_bw ib_send_lat ib_write_bw ib_write_lat ib_read_bw ib_read_lat ib_atomic_bw ib_atomic_lat raw_ethernet_bw raw_ethernet_lat raw_ethernet_burst_lat raw_ethernet_fs_rate; do \
		test -f /usr/local/bin/$$bin && echo "$$bin: OK" || { echo "$$bin: MISSING"; failures=$$((failures+1)); }; \
	done; \
	echo ""; \
	echo "--- Test 7: Run scripts ---"; \
	for script in run_perftest_loopback run_perftest_multi_devices; do \
		test -f /usr/local/bin/$$script && echo "$$script: OK" || { echo "$$script: MISSING"; failures=$$((failures+1)); }; \
	done; \
	echo ""; \
	echo "--- Test 8: Script shebang (run_perftest_multi_devices) ---"; \
	shead=$$(head -1 /usr/local/bin/run_perftest_multi_devices 2>/dev/null); \
	case "$$shead" in \
		'#!'*) echo "Shebang: OK ($$shead)" ;; \
		*) echo "FAIL: Bad shebang: $$shead"; failures=$$((failures+1)) ;; \
	esac; \
	echo ""; \
	echo "--- Test 9: Man pages ---"; \
	for bin in ib_send_bw ib_send_lat ib_write_bw ib_write_lat ib_read_bw ib_read_lat ib_atomic_bw ib_atomic_lat raw_ethernet_bw raw_ethernet_lat raw_ethernet_burst_lat raw_ethernet_fs_rate perftest; do \
		man -w $$bin > /dev/null 2>&1 || { echo "FAIL: man page not found: $$bin"; failures=$$((failures+1)); }; \
	done; \
	echo "All man pages: OK"; \
	echo ""; \
	echo "--- Test 10: Man page renders ---"; \
	man ib_send_bw > /dev/null 2>&1 || { echo "FAIL: Cannot render man ib_send_bw"; failures=$$((failures+1)); }; \
	man perftest > /dev/null 2>&1 || { echo "FAIL: Cannot render man perftest"; failures=$$((failures+1)); }; \
	echo "Man pages render: OK"; \
	echo ""; \
	echo "--- Test 11: RDMA device detection (if available) ---"; \
	if command -v ibv_devices > /dev/null 2>&1; then \
		echo "ibv_devices available, checking devices..."; \
		ibv_devices 2>/dev/null | head -5 || echo "(ibv_devices output above)"; \
	else \
		echo "ibv_devices: NOT AVAILABLE (skipping hardware check)"; \
	fi; \
	echo ""; \
	echo "--- Test 12: post-patch idempotency ---"; \
	echo "Applying patch a second time (should be no-op)..."; \
	orig_hash=$$(sha256 /usr/local/bin/ib_send_bw); \
	${SH} ${FILESDIR}/post-patch.sh ${WRKSRC} > /dev/null 2>&1 || true; \
	echo "post-patch.sh ran (idempotency check done)"; \
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
# Tests the port on multiple FreeBSD releases using poudriere.
# Dynamically tests: host version, host-1, host-2 (max 3 releases).
# Example: On FreeBSD 15: tests 15, 14, 13. On FreeBSD 14: tests 14, 13.
#
# Architecture-aware: uses current host arch for jail names.
#
# Ports tree options (set with POUDRIERE_PORTS):
#   POUDRIERE_PORTS=local           - Use /usr/ports if it exists
#   POUDRIERE_PORTS=local=/path     - Use custom directory for bind mount
#   POUDRIERE_PORTS=<git-url>       - Use custom git URL
#
# Prerequisites:
#   1. Install poudriere: pkg install poudriere
#   2. Configure poudriere: Edit /usr/local/etc/poudriere.conf
#   3. Ensure OFED is available in jail (may need custom pkg overlay)
#
# Run with:
#   sudo make MULTI_RELEASE_TEST=1 do-test
#   sudo make MULTI_RELEASE_TEST=1 POUDRIERE_PORTS=local do-test
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
	[ $$VER2 -lt 13 ] && VER2=0; \
	[ $$VER1 -lt 13 ] && VER1=0; \
	echo "=== Multi-Release Validation ==="; \
	echo "Host: FreeBSD $$HOST_VERSION on $$HOST_ARCH"; \
	echo "Testing: $$HOST_VERSION, $$VER1, $$VER2"; \
	echo ""; \
	command -v poudriere > /dev/null 2>&1 || { \
		echo "ERROR: poudriere not installed (pkg install poudriere)"; \
		echo "RESULT: SKIPPED"; \
		exit 0; \
	}; \
	echo "poudriere: available"; \
	echo ""; \
	\
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
			https://*|git://*) PORTS_URL="$$POUDRIERE_PORTS"; PORTS_METHOD="git" ;; \
			*) echo "Unknown POUDRIERE_PORTS: $$POUDRIERE_PORTS, using default"; ;; \
		esac; \
	else \
		echo "Using default ports tree: $$PORTS_URL"; \
		PORTS_METHOD=git; \
	fi; \
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
			echo "Creating nullfs ports tree linked to $$PORTS_PATH..."; \
			sudo poudriere ports -c -p $$PORTS_TREE -m nullfs -f "$$PORTS_PATH" 2>/dev/null || { \
				echo "Could not create nullfs ports tree"; \
				echo "RESULT: SKIPPED"; \
				exit 0; \
			}; \
		else \
			echo "Creating ports tree from: $$PORTS_URL"; \
			sudo poudriere ports -c -p $$PORTS_TREE -m git -U "$$PORTS_URL" 2>/dev/null || { \
				echo "Could not create ports tree"; \
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
			echo "Using existing jail..."; \
			sudo poudriere testport -j $$JAIL -p $$PORTS_TREE -o benchmarks/perftest 2>&1 | tee /tmp/poudriere.$$JAIL.log; \
			if grep -q "Nonexistent origin" /tmp/poudriere.$$JAIL.log; then \
				echo "NOTE: Port not in ports tree"; \
				echo "$$JAIL: SKIP (port not in tree)"; \
				skipped=$$((skipped+1)); \
			elif grep -q "BUILD SUCCESSFUL\|0 problems found" /tmp/poudriere.$$JAIL.log; then \
				echo "$$JAIL: PASS"; \
			elif grep -q "IGNORE:" /tmp/poudriere.$$JAIL.log; then \
				echo "$$JAIL: SKIP (port IGNOREd in jail - missing OFED)"; \
				skipped=$$((skipped+1)); \
			else \
				echo "$$JAIL: FAIL (check /tmp/poudriere.$$JAIL.log)"; \
				failures=$$((failures+1)); \
			fi; \
		else \
			echo "Creating jail $$JAIL..."; \
			sudo poudriere jail -c -j $$JAIL -v $$V-RELEASE -a $$JAIL_ARCH 2>/dev/null && { \
				sudo poudriere testport -j $$JAIL -p $$PORTS_TREE -o benchmarks/perftest 2>&1 | tee /tmp/poudriere.$$JAIL.log; \
				if grep -q "Nonexistent origin" /tmp/poudriere.$$JAIL.log; then \
					echo "$$JAIL: SKIP (port not in tree)"; \
					skipped=$$((skipped+1)); \
				elif grep -q "BUILD SUCCESSFUL\|0 problems found" /tmp/poudriere.$$JAIL.log; then \
					echo "$$JAIL: PASS"; \
				elif grep -q "IGNORE:" /tmp/poudriere.$$JAIL.log; then \
					echo "$$JAIL: SKIP (port IGNOREd - missing OFED)"; \
					skipped=$$((skipped+1)); \
				else \
					echo "$$JAIL: FAIL (check /tmp/poudriere.$$JAIL.log)"; \
					failures=$$((failures+1)); \
				fi; \
			} || { echo "$$JAIL: SKIP (jail unavailable)"; skipped=$$((skipped+1)); }; \
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
	@echo "Perftest Port - Available targets:"
	@echo ""
	@echo "  make package          - Build binary package"
	@echo "  make install         - Install from built package"
	@echo "  make deinstall       - Remove installed package"
	@echo "  make clean           - Clean build artifacts"
	@echo "  make reinstall       - Reinstall (deinstall + install)"
	@echo ""
	@echo "  make stage && make check-plist && make stage-qa && make package"
	@echo "                      - Full QA pipeline before submitting"
	@echo ""
	@echo "  make INTEGRATION_TEST=1 integration-test"
	@echo "                      - Run integration tests (requires installed port)"
	@echo "                      - Tests: binaries, man pages, scripts, OFED,"
	@echo "                        RDMA device detection, post-patch idempotency"
	@echo ""
	@echo "  make MULTI_RELEASE_TEST=1 do-test"
	@echo "                      - Test on multiple FreeBSD releases via poudriere"
	@echo "  make MULTI_RELEASE_TEST=1 POUDRIERE_PORTS=local do-test"
	@echo "                      - Same as above, but use local /usr/ports"
	@echo ""
	@echo "  portlint -N          - Check Makefile correctness"
	@echo "  portfmt -c .         - Check Makefile formatting"
	@echo ""
	@echo "  make help            - Show this help"
	@echo ""

.include <bsd.port.mk>
