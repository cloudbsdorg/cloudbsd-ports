# Copyright (c) 2026 REVYTECH, Inc.
# SPDX-License-Identifier: BSD-2-Clause

PORTNAME=	cloudbsd-review-service
# Must match what scripts/make-distfile.sh produced, because the port fetches
# ${PORTNAME}-${DISTVERSION}${EXTRACT_SUFX} by that exact name. The script
# derives its version from the git tag, so packaging a new release means
# bumping this to the same tag. An UNTAGGED build is named
# 0.0.0.<date>.<sha> and will not match this at all -- deliberately, because a
# package whose version cannot be traced to a tag should not install over one
# that can.
DISTVERSION=	0.1.0
CATEGORIES=	devel

MAINTAINER=	mark@cloudbsd.org
COMMENT=	MCP service running a panel of independent code reviewers over one diff
WWW=		https://github.com/cloudbsdorg/cloudbsd-review-service

LICENSE=	BSD2CLAUSE
LICENSE_FILE=	${WRKSRC}/LICENSE

# The distfile is produced by scripts/make-distfile.sh in the source repository
# and is NOT fetchable.
#
# This is deliberate rather than a gap. cloudbsd-review-service is private, and
# its one dependency -- cloudbsd-backend-services-common -- is private AND
# untagged, so USE_GITHUB cannot work from a poudriere jail with no credentials
# and `go build` cannot resolve the module at all. make-distfile.sh vendors the
# dependency INTO the tarball from a committed revision, records which revision
# in a VENDORED file, and proves the result builds with GOPROXY=off and no
# sibling checkout before it writes anything.
#
# The Jenkins job runs that script in the same job as this build and before it.
# A distfile produced by a step somebody is supposed to remember to run is how
# www/mdweb came to fail every build on a missing tarball.
MASTER_SITES=	file://${DISTDIR}/
DISTFILES=	${PORTNAME}-${DISTVERSION}${EXTRACT_SUFX}
# NO distinfo in git, and NO NO_CHECKSUM either.
#
# The hash of a produced distfile changes with every commit packaged, so a
# distinfo cannot be committed beside this Makefile. That was used to justify
# NO_CHECKSUM=yes, and three separate review rounds objected to the same thing:
# post-stage below EXECUTES what comes out of this tarball, so an unverified
# distfile is build-time code execution, not a missing convenience.
#
# A missing distinfo FAILS, which is what makes this work. Measured on the
# builder rather than assumed, because a review round argued the opposite --
# that the framework prints "No checksum file" and returns success:
#
#   $ make -C <port with no distinfo> checksum
#   ===> Fetching all distfiles required by dummytest-1.0 for building
#   => No checksum file (/.../distinfo).
#   *** Error code 1
#   rc=1
#
# With a distinfo present the same command reports "SHA256 Checksum OK" and
# exits 0. So the distinfo is GENERATED, in the same job, between producing the
# tarball and building the port: Jenkinsfile.service-port updates the tree, produces the
# distfile, runs `make makesum`, and then runs `make checksum` to prove the
# result verifies before poudriere is handed the build. Building this port by
# hand from a git checkout will fail on the missing distinfo, which is correct
# -- there is no supported way to build it outside that job.
#
# Be exact about what that buys, because a checksum described as more than it
# is stops being read: a distinfo generated immediately after the same job
# produced the tarball covers the makesum-to-build window and nothing wider.
# Anyone able to substitute the tarball could substitute it BEFORE makesum, and
# the hash would then bless the substitution.
#
# What it does remove is the case that actually happens: a stale or truncated
# file of the right name being extracted and executed with nothing noticing.
# Pinning the hash to the git tag outside the job -- make-distfile.sh emitting
# it into a committed artifact the job compares against -- is what would close
# the rest, and that is not done here.

USES=		go:modules
GO_PKGNAME=	github.com/cloudbsdorg/cloudbsd-review-service
GO_TARGET=	./cmd/cloudbsd-review:${PREFIX}/sbin/cloudbsd-review
# -mod=vendor, not the framework's module fetching: the vendor directory is the
# whole point of the distfile and the build must not reach the network to
# confirm what is already in the tarball.
GO_BUILDFLAGS=	-mod=vendor -ldflags="-s -X main.version=${DISTVERSION}"
GO_TESTFLAGS=	-mod=vendor
MAKE_ENV+=	CGO_ENABLED=0 GOPROXY=off GOFLAGS=-mod=vendor
CGO_ENABLED=	0

USE_RC_SUBR=	cloudbsd_review

# The service shells out to agent CLIs and talks to remote endpoints. It does
# not need root and must not have it.
#
# USERS/GROUPS is checked against UID_FILES/GID_FILES at build time and fails
# the build if the account is not registered in one of them. Ours is registered
# in this directory rather than in ${PORTSDIR}/UIDs, which the tree update
# replaces wholesale -- see the comment in ./UIDs.
USERS=		cloudbsd_review
GROUPS=		cloudbsd_review
UID_FILES=	${PORTSDIR}/UIDs ${.CURDIR}/UIDs
GID_FILES=	${PORTSDIR}/GIDs ${.CURDIR}/GIDs

SUB_FILES=	pkg-message
SUB_LIST=	PREFIX=${PREFIX}

# NO @dir for /var/db/cloudbsd here, deliberately.
#
# These entries were added because USERS= makes the framework run
# `install -d -g <group> -o <login> <homedir>`, and the reasoning was that this
# would leave the PARENT owned by the service account and the rc script would
# then refuse to start for ever. Measured on the builder, that reasoning was
# wrong: xinstall creates intermediates root:wheel 0755 and chowns only the
# final component, so /var/db/cloudbsd comes out root's exactly as the rc
# script requires.
#
# They are not merely unnecessary -- a plist @dir with no matching directory in
# ${STAGEDIR} is what check-plist reports as missing, so keeping them on a
# false premise risked failing the build to fix a problem that did not exist.
# The rc script creates and checks the tree at start.
PLIST_FILES=	sbin/cloudbsd-review \
		"@sample etc/cloudbsd/review/config.json.sample" \
		"@sample etc/cloudbsd/review/reviewers.json.sample" \
		"@dir etc/cloudbsd/review"

post-install:
	@${MKDIR} ${STAGEDIR}${PREFIX}/etc/cloudbsd/review
	${INSTALL_DATA} ${WRKSRC}/packaging/freebsd/etc/review/reviewers.json.sample \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/review/reviewers.json.sample
	${INSTALL_DATA} ${WRKSRC}/packaging/freebsd/etc/review/config.json.sample \
		${STAGEDIR}${PREFIX}/etc/cloudbsd/review/config.json.sample

# The package is only useful if the binary it installed actually starts, and a
# green build says nothing about that.
#
# What `-version` proves is bounded, and the bound is worth stating because an
# overclaim here is how a check stops being read: it proves the file execs on
# this ABI and parses a flag. Not even the dynamic loader -- CGO_ENABLED=0
# above makes this a static binary. It does NOT touch config parsing, the
# reviewer registry or the listener. A binary that passes this and then dies on
# its own config.json is not caught here -- it is caught by the integration
# test in Jenkinsfile.service-port, which installs the package and runs it.
#
# It FAILS the build. The first version printed a note and exited success,
# which is a check that cannot refuse anything -- a binary that does not run
# would have been packaged and shipped with a line in the log nobody reads.
# stderr is deliberately NOT discarded: `2>&1 >/dev/null` threw away the one
# line that would have said why.
post-stage:
	@if ! ${STAGEDIR}${PREFIX}/sbin/cloudbsd-review -version >/dev/null; then \
		${ECHO_MSG} "cloudbsd-review -version did not answer: the staged binary does not run"; \
		exit 1; \
	fi

.include <bsd.port.mk>
