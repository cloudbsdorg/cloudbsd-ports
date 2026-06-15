#!/bin/sh
# FreeBSD OFED compatibility: patch perftest for older OFED headers

WRKSRC="${1:-.}"
cd "${WRKSRC}" || exit 1

echo "Applying FreeBSD OFED patches..."

# 0. Add configure check for ibv_parent_domain_init_attr struct
if ! grep -q "ibv_parent_domain_init_attr" configure.ac 2>/dev/null; then
    LINE=$(/usr/bin/grep -n "ibv_create_flow" configure.ac 2>/dev/null | head -1 | cut -d: -f1)
    if [ -n "$LINE" ]; then
        /usr/bin/sed -i '' "${LINE}a\\
AC_CHECK_TYPE([struct ibv_parent_domain_init_attr],\\
	[AC_DEFINE([HAVE_IBV_PARENT_DOMAIN_INIT_ATTR], [1], [struct ibv_parent_domain_init_attr is available])],,\\
	[#include <infiniband/verbs.h>])" configure.ac
        echo "  + configure.ac: ibv_parent_domain_init_attr check"
    fi
fi

# 1. Add missing OFED stub constants to perftest_parameters.h
if ! grep -qi "FreeBSD OFED compatibility: stubs" src/perftest_parameters.h 2>/dev/null; then
    /usr/bin/sed -i '' \
        -e '/^#endif \/\* PERFTEST_RESOURCES_H \*\/$/a\
\
/* FreeBSD OFED compatibility: stubs for newer rdma-core constants */\
#ifndef RDMA_OPTION_ID_ACK_TIMEOUT\
#define RDMA_OPTION_ID_ACK_TIMEOUT 3\
#endif\
#ifndef IBV_ODP_SUPPORT_SRQ_RECV\
#define IBV_ODP_SUPPORT_SRQ_RECV 0\
#endif\
#ifndef IBV_CQ_INIT_ATTR_MASK_PD\
#define IBV_CQ_INIT_ATTR_MASK_PD 0\
#endif\
' src/perftest_parameters.h
    echo "  + perftest_parameters.h stubs"
fi

# 2. Add RDMA_OPTION_ID_ACK_TIMEOUT stub to perftest_communication.h
if ! grep -qi "FreeBSD OFED compatibility: ACK_TIMEOUT" src/perftest_communication.h 2>/dev/null; then
    /usr/bin/sed -i '' \
        -e '/^#endif \/\* PERFTEST_COMMUNICATION_H \*\/$/a\
\
/* FreeBSD OFED compatibility: stub for newer rdma-core constant */\
#ifndef RDMA_OPTION_ID_ACK_TIMEOUT\
#define RDMA_OPTION_ID_ACK_TIMEOUT 3\
#endif\
' src/perftest_communication.h
    echo "  + perftest_communication.h stub"
fi

# 3. Fix xrc_odp_caps - replace with 0 (feature not available on FreeBSD)
if ! grep -q "xrc_odp_caps.*unavailable" src/perftest_resources.c 2>/dev/null; then
    /usr/bin/sed -i '' \
        -e 's/check_odp_transport_caps(user_param, dattr\.xrc_odp_caps)/check_odp_transport_caps(user_param, 0) \/\* xrc_odp_caps unavailable \*\//g' \
        src/perftest_resources.c
    echo "  + perftest_resources.c: xrc_odp_caps fixed"
fi

# 4. Guard parent_domain init block (if-else structure)
if ! grep -q "HAVE_IBV_PARENT_DOMAIN_INIT_ATTR" src/perftest_resources.c 2>/dev/null; then
    # Write a perl script that reads the source file, patches it, and writes it back
    cat > /tmp/perftest_patch4.pl << 'PL_SCRIPT'
use strict;
local $/;
open(F, "src/perftest_resources.c") or die "Cannot open src/perftest_resources.c: $!\n";
my $content = <F>;
close(F);

my $repl = "\n#ifdef HAVE_IBV_PARENT_DOMAIN_INIT_ATTR\n"
        . "\tint need_parent_domain = 0;\n"
        . "#ifdef HAVE_TD_API\n"
        . "\tneed_parent_domain |= user_param->no_lock;\n"
        . "#endif\n\n"
        . "\tif (need_parent_domain) {\n"
        . "\t\tstruct ibv_parent_domain_init_attr pad_attr = {\n"
        . "\t\t\t.pd = ctx->pd,\n"
        . "\t\t\t.comp_mask = 0,\n"
        . "\t\t};\n\n"
        . "#ifdef HAVE_TD_API\n"
        . "\t\tif (user_param->no_lock) {\n"
        . "\t\t\tstruct ibv_td_init_attr td_attr = {0};\n"
        . "\t\t\tctx->td = ibv_alloc_td(ctx->context, &td_attr);\n"
        . "\t\t\tif (!ctx->td) {\n"
        . "\t\t\t\tfprintf(stderr, \"Couldn't allocate TD\\n\");\n"
        . "\t\t\t\tgoto pd;\n"
        . "\t\t\t}\n"
        . "\t\t\tpad_attr.td = ctx->td;\n"
        . "\t\t}\n"
        . "#endif\n\n"
        . "\t\tctx->pad = ibv_alloc_parent_domain(ctx->context, &pad_attr);\n"
        . "\t\tif (!ctx->pad) {\n"
        . "\t\t\tfprintf(stderr, \"Couldn't allocate PAD\\n\");\n"
        . "\t\t\tgoto td;\n"
        . "\t\t}\n"
        . "\t} else {\n"
        . "\t\tctx->pad = ctx->pd;\n"
        . "\t}\n"
        . "#else\n"
        . "\t/* FreeBSD OFED compatibility: parent_domain_init_attr not available */\n"
        . "\tctx->pad = ctx->pd;\n"
        . "#endif\n";

# Match: two newlines + tab + int need_parent_domain (unique anchor)
if ($content =~ /(\n\n\tint need_parent_domain = 0;)/) {
    my $prefix = $1;
    my $rest = substr($content, index($content, $prefix) + length($prefix));
    my $depth = 0;
    my $found_if = 0;
    my $block_end = 0;
    for (my $i = 0; $i < length($rest); $i++) {
        my $c = substr($rest, $i, 1);
        if ($c eq "{") { $depth++; $found_if = 1; }
        elsif ($c eq "}") {
            $depth--;
            if ($found_if && $depth == 0) {
                my $after = substr($rest, $i + 1);
                # "} else {" — do NOT stop; continue to consume else body
                if ($after =~ /^\s+else\s*\{/) { next; }
                $block_end = $i + 1; last;
            }
        }
    }
    if ($block_end > 0) {
        my $block = substr($rest, 0, $block_end);
        $content =~ s/\Q$prefix$block\E/$repl/;
    }
}

open(W, ">src/perftest_resources.c") or die "Cannot write src/perftest_resources.c: $!\n";
print W $content;
close(W);
PL_SCRIPT
    perl /tmp/perftest_patch4.pl
    rm -f /tmp/perftest_patch4.pl
    echo "  + perftest_resources.c: parent_domain init guarded"
fi

# 5. Guard parent_domain in create_cq_ex
if ! grep -q "HAVE_PARENT_DOMAIN" src/perftest_resources.c 2>/dev/null; then
    cat > /tmp/perftest_patch5.pl << 'PL_SCRIPT'
use strict;
local $/;
open(F, "src/perftest_resources.c") or die $!;
my $c = <F>;
close(F);
# send_cq_attr: 1-tab outer, 2-tab inner
$c =~ s{(\t)if \(ctx->pad != ctx->pd\) \{\n\t\tsend_cq_attr\.parent_domain = ctx->pad;\n\t\tsend_cq_attr\.comp_mask = IBV_CQ_INIT_ATTR_MASK_PD;\n\t\}}{${1}#ifdef HAVE_PARENT_DOMAIN\n${1}\tif (ctx->pad != ctx->pd) {\n${1}\t\tsend_cq_attr.parent_domain = ctx->pad;\n${1}\t\tsend_cq_attr.comp_mask = IBV_CQ_INIT_ATTR_MASK_PD;\n${1}\t}\n${1}#endif\n}gs;
# recv_cq_attr: 2-tab outer, 3-tab inner
$c =~ s{(\t\t)if \(ctx->pad != ctx->pd\) \{\n\t\t\trecv_cq_attr\.parent_domain = ctx->pad;\n\t\t\trecv_cq_attr\.comp_mask = IBV_CQ_INIT_ATTR_MASK_PD;\n\t\t\}}{${1}#ifdef HAVE_PARENT_DOMAIN\n${1}\tif (ctx->pad != ctx->pd) {\n${1}\t\trecv_cq_attr.parent_domain = ctx->pad;\n${1}\t\trecv_cq_attr.comp_mask = IBV_CQ_INIT_ATTR_MASK_PD;\n${1}\t}\n${1}#endif\n}gs;
open(W, ">src/perftest_resources.c") or die $!;
print W $c;
close(W);
PL_SCRIPT
    perl /tmp/perftest_patch5.pl
    rm -f /tmp/perftest_patch5.pl
    echo "  + perftest_resources.c: parent_domain in CQ creation guarded"
fi

# 6. Fix ibv_alloc_null_mr
if ! grep -q "ibv_alloc_null_mr not available on FreeBSD" src/perftest_resources.c 2>/dev/null; then
    cat > /tmp/perftest_patch6.pl << 'PL_SCRIPT'
use strict;
local $/;
open(F, "src/perftest_resources.c") or die $!;
my $c = <F>;
close(F);
$c =~ s{(\t)if \(user_param->use_null_mr\) \{\n\t\tctx->null_mr = ibv_alloc_null_mr\(ctx->pd\);\n\t\tif \(!ctx->null_mr\) \{\n\t\t\tfprintf\(stderr, "Couldn.t create null MR\\n"\);\n\t\t\treturn FAILURE;\n\t\t\}\n\t\}}{{
#ifdef HAVE_IBV_ALLOC_NULL_MR
${1}if (user_param->use_null_mr) {
${1}\tctx->null_mr = ibv_alloc_null_mr(ctx->pd);
${1}\tif (!ctx->null_mr) {
${1}\t\tfprintf(stderr, "Couldn't create null MR\\n");
${1}\t\treturn FAILURE;
${1}\t}
${1}}
#else
${1}if (user_param->use_null_mr) {
${1}\tfprintf(stderr, "ibv_alloc_null_mr not available on FreeBSD\\n");
${1}\treturn FAILURE;
${1}}
#endif
}}gs;
open(W, ">src/perftest_resources.c") or die $!;
print W $c;
close(W);
PL_SCRIPT
    perl /tmp/perftest_patch6.pl
    rm -f /tmp/perftest_patch6.pl
    echo "  + perftest_resources.c: ibv_alloc_null_mr guarded"
fi

echo "Done."
exit 0
