PORTNAME=	perftest
DISTVERSION=	26.04.17
CATEGORIES=	benchmarks

MAINTAINER=	mark@cloudbsd.org
COMMENT=	Collection of tests for RDMA micro-benchmark
WWW=		https://github.com/linux-rdma/perftest/

LICENSE=	LGPL21 BSD2CLAUSE
LICENSE_COMB=	dual

USES=		autoreconf libtool shebangfix
USE_GITHUB=	yes
GH_ACCOUNT=	linux-rdma

SHEBANG_FILES=	run_perftest_multi_devices

GNU_CONFIGURE=yes

.if !exists(/usr/lib/libibverbs.so)
IGNORE=		missing OFED user space
.endif

.include <bsd.port.mk>
