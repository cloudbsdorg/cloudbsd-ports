# Shared settings for REVYTECH Wayfire stack ports.
# Included from each port Makefile via:
#   .include "${.CURDIR}/../../revytech/wayfire/Makefile.inc"
#
# These ports are SEPARATE from stock FreeBSD wayfire (WayfireWM / ports@).
# They install the same binary names and therefore CONFLICTS_INSTALL with
# the stock packages — pick one stack.

REVYTECH_MAINTAINER?=	mark@revytechinc.com
REVYTECH_GH_ACCOUNT?=	revytechinc

# Product line version shown in package version field (not a git tag).
REVYTECH_DISTVERSION?=	0.11.0.20260720

# Pinned commits (origin master/main) — keep in sync with VERSIONS
REVYTECH_SHA_WF_CONFIG?=	99e50f85e339657097af3a6071ef6e765a70e0f6
REVYTECH_SHA_WAYFIRE?=		e925f212b0ab9efd7ccf046f99540b88ea555183
REVYTECH_SHA_PLUGINS?=		4290ddf13bfadb344d45cb25c47f7825bbdc8a30
REVYTECH_SHA_WCM?=		84063a07ccfc5be2a96b98d934271761a1730c2b
REVYTECH_SHA_WF_SHELL?=		37865472c54d179043ad90f4bd316928f4d9849d
REVYTECH_SHA_WF_OSK?=		c305f8d3f0ebade336c62c8b8da1ff86f88b7509
REVYTECH_SHA_WF_JSON?=		d6a43dfdda5717befe0188508d514cbb934c2657
REVYTECH_SHA_LY?=313f582136353a14aaba154d77e0849e303f0199
