#!/bin/sh
# Exercise cloudbsd_review_prestart against real files, on real FreeBSD sh,
# with the real stat(1). Every row asserts an exit code AND a reason string:
# a refusal for the wrong reason is as wrong as no refusal.
#
# Must run as root: the accept rows require a root-owned 0600 file in a
# root-owned, non-group-writable directory, which is the whole point.
#
#	doas sh tests/prestart.sh files/cloudbsd_review.in
#
# It is run by the `Test the rc script` stage of Jenkinsfile.service-port. A
# test nothing runs is a check that cannot refuse anything.
set -u
SRC=${1:?usage: prestart.sh /path/to/cloudbsd_review.in}
[ "$(id -u)" = 0 ] || { echo "must run as root"; exit 3; }

# Under /root, NOT under /tmp. The prestart now walks every ancestor of the
# credentials file and refuses a group- or world-writable one, so a fixture in
# /tmp (mode 1777) is refused before any row's own condition is reached -- and
# every refusal row then "passes" for the wrong reason while every accept row
# fails. /root is 0700 root-owned, and this script already requires root.
D=$(mktemp -d /root/prestart-test.XXXXXXXX) || {
	echo "could not create a fixture directory under /root"; exit 3; }
trap 'rm -rf "$D"' EXIT

# Every cloudbsd_review_* function, lifted out. Named individually rather than
# by a range, because a helper added to the rc script and not added here is not
# a missing test -- it is 31 rows failing with "not found", which is what
# happened when cloudbsd_review_check_path arrived.
sed -n '/^cloudbsd_review_[a-z_]*()$/,/^}$/p' "$SRC" > "$D/fn.sh"
grep -q '^cloudbsd_review_prestart()' "$D/fn.sh" || {
	echo "could not extract cloudbsd_review_prestart"; exit 3; }
grep -q '^cloudbsd_review_refuse()' "$D/fn.sh" || {
	echo "could not extract cloudbsd_review_refuse"; exit 3; }
# Every function the rc script defines must have come across. A helper the
# prestart calls and this file did not lift is a "not found" in every row.
for _f in $(sed -n 's/^\(cloudbsd_review_[a-z_]*\)()$/\1/p' "$SRC"); do
	grep -q "^${_f}()" "$D/fn.sh" || {
		echo "did not extract $_f"; exit 3; }
done

cat > "$D/harness.sh" <<'HEOF'
warn() { echo "warn: $*" >&2; }
# install(1), honouring -d and -o against the fixture rather than returning 0.
#
# A no-op stub meant the state directory was never created, so the checks that
# run against it -- its owner, its ancestors -- could not be exercised at all,
# and a `stat` on the directory the prestart had just "created" failed. The
# rows would have been green while testing nothing.
install() {
	_mode=""; _owner=""; _group=""; _dir=""
	while [ $# -gt 0 ]; do
		case "$1" in
		-d) shift ;;
		-m) _mode=$2; shift 2 ;;
		-o) _owner=$2; shift 2 ;;
		-g) _group=$2; shift 2 ;;
		*) _dir=$1; shift ;;
		esac
	done
	[ -n "$_dir" ] || return 1
	mkdir -p "$_dir" || return 1
	[ -z "$_mode" ] || chmod "$_mode" "$_dir" || return 1
	# -g honoured, not discarded: the rc script passes it so the state
	# directory does not inherit wheel, and a stub that drops it makes every
	# row fail on a group the real install would never have set.
	[ -z "$_owner" ] || chown "${_owner}${_group:+:$_group}" "$_dir" || return 1
	return 0
}

# Dump the exported roster on the way out, from an EXIT trap, so it is printed
# on the REFUSAL path too. Called inline it could not be: the prestart `exit`s
# on a refusal, so every line after the call is unreachable and the
# "refused, and exported anyway" invariant could never fire -- it was asserting
# the absence of output that nothing would have produced either way.
dump_exports() {
	env | grep "^CLOUDBSD_REVIEW_" | sed "s/^/CHILD-/"
	return 0
}
HEOF

: > "$D/config.json"
mkdir -p "$D/state"; chown 0 "$D/state"; chmod 0755 "$D/state"

fail=0 ran=0
check() { # <label> <want-rc> <want-reason>  (RUNAS/NOCONFIG/CREDPATH/STATEDIR override)
	label=$1 want_rc=$2 want_re=$3
	# The status comes from the SHELL, not from an echoed $?. The prestart
	# `exit`s rather than returning on a refusal -- deliberately, so that
	# `service forcestart` cannot walk past it -- so every line after the
	# call is unreachable on a refusal row, and an "RC=$?" echo would
	# simply never print.
	# env -i, so the child starts EMPTY.
	#
	# dump_exports greps the environment for CLOUDBSD_REVIEW_*, and nothing
	# cleared them before. The Jenkins job that runs this file also runs an
	# integration test that needs those very variables set -- so in that job
	# every refusal row would fail "refused, and exported anyway" and every
	# accept row would pass with the parser having exported nothing at all,
	# which is precisely the confusion reading from a child was meant to end.
	out=$(env -i PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin \
		RUNAS="${RUNAS:-nobody}" STATEDIR="${STATEDIR:-}" ARGS="${ARGS:-}" \
		sh -c '. "$1"; . "$2"
		cloudbsd_review_credfile="$3"
		cloudbsd_review_config="$4"
		cloudbsd_review_runas="${RUNAS}"
		cloudbsd_review_args="${ARGS}"
		# Its own state directory, under the fixture. The prestart checks the
		# REAL path before it reaches any credential check, so with a hardcoded
		# /var/db/cloudbsd this suite could only pass on a host that already
		# had it -- a fresh Jenkins agent does not, and every row would have
		# failed on "cannot stat" rather than on the thing it tests.
		cloudbsd_review_statedir="$5"
		trap dump_exports EXIT
		cloudbsd_review_prestart
		echo "COMMAND=[${command-unset}]"
		exit 0' \
		_ "$D/harness.sh" "$D/fn.sh" "${CREDPATH:-$D/dir/credentials}" \
		"${NOCONFIG:-$D/config.json}" "${STATEDIR:-$D/state/review}" 2>&1)
	rc=$?
	ran=$((ran + 1))
	if [ "$rc" != "$want_rc" ]; then
		echo "FAIL $label: rc=$rc want=$want_rc"
		printf '%s\n' "$out" | sed 's/^/     | /'
		fail=$((fail + 1)); return
	fi
	if [ -n "$want_re" ] && ! printf '%s\n' "$out" | grep -q -- "$want_re"; then
		echo "FAIL $label: rc correct but reason missing: $want_re"
		printf '%s\n' "$out" | sed 's/^/     | /'
		fail=$((fail + 1)); return
	fi
	# A global invariant, not a row: nothing is exported unless the WHOLE
	# file was accepted. The loop used to export as it went, so a file
	# rejected on line 5 had already exported lines 1 to 4 -- reachable,
	# because `service forcestart` ignores a start_precmd failure.
	if [ "$want_rc" != 0 ] && printf '%s\n' "$out" | grep -q 'CHILD-CLOUDBSD_REVIEW_'; then
		echo "FAIL $label: refused, and exported anyway"
		printf '%s\n' "$out" | sed 's/^/     | /'
		fail=$((fail + 1)); return
	fi
	# And the credentials never appear in the log. With no `=` in a line the
	# "variable name" IS the whole line, so a pasted token was being copied
	# into syslog by the very check that rejected it.
	if printf '%s\n' "$out" | grep -q 'sk-averyrealsecret'; then
		echo "FAIL $label: a rejected line was echoed into the log"
		fail=$((fail + 1)); return
	fi
	echo "ok   $label"
}

setup() { # setup <file-mode> <file-owner> <dir-mode> ; content on stdin
	rm -rf "$D/dir"; mkdir -p "$D/dir"
	cat > "$D/dir/credentials"
	chmod "$1" "$D/dir/credentials"; chown "$2" "$D/dir/credentials"
	chmod "$3" "$D/dir"; chown 0 "$D/dir"
}

ROSTER='CLOUDBSD_REVIEW_REVIEWERS=[{"name":"grok"}]'

# --- the happy path, first, so a refusal row proves something -------------
setup 600 0 755 <<X
# a comment
CLOUDBSD_REVIEW_TARGETS=cursor,grok
$ROSTER
GROK_API_KEY=sk-notreal
X
# Read from a CHILD, deliberately. Reading CLOUDBSD_REVIEW_TARGETS in the same
# shell passes just as well if the loop used a plain assignment -- and a plain
# assignment is a shell local that daemon(8)'s child never sees, which is the
# whole bug.
check "accepts a root-owned 0600 file" 0 'CHILD-CLOUDBSD_REVIEW_TARGETS=cursor,grok'

# a final line with no newline must not be dropped
printf '%s\nCLOUDBSD_REVIEW_TARGETS=cursor' "$ROSTER" > "$D/dir/credentials"
chmod 600 "$D/dir/credentials"; chown 0 "$D/dir/credentials"
check "keeps an unterminated last line" 0 'CHILD-CLOUDBSD_REVIEW_TARGETS=cursor'

# --- the config file, which nothing used to check -------------------------
setup 600 0 755 <<X
CLOUDBSD_REVIEW_TARGETS=cursor
$ROSTER
X
NOCONFIG=/nonexistent/config.json
check "refuses a missing config.json" 1 'is not a readable file'
# `[ -r <dir> ]` is TRUE for a readable directory, so pointing the config at the
# directory instead of the file passed, daemon forked, and the child died.
NOCONFIG=$D
check "refuses a config that is a directory" 1 'is not a readable file'
NOCONFIG=config.json
check "refuses a relative config path" 1 'must be an absolute path'
# config.json is a control surface, not just a file that must exist: it carries
# the listen address and names auth.tokenFile, so a writable one re-points the
# service without needing any credential at all.
: > "$D/cfg-ww"; chown 0 "$D/cfg-ww"; chmod 0666 "$D/cfg-ww"
NOCONFIG="$D/cfg-ww"
check "refuses a world-writable config" 1 'must be root-owned and not writable by others'
: > "$D/cfg-own"; chown 65534 "$D/cfg-own"; chmod 0644 "$D/cfg-own"
NOCONFIG="$D/cfg-own"
check "refuses a config owned by another user" 1 'must be root-owned and not writable by others'
ln -s "$D/config.json" "$D/cfg-link"
NOCONFIG="$D/cfg-link"
check "refuses a config reached through a symlink" 1 'is a symlink'
unset NOCONFIG

# A RELATIVE credentials path used to HANG. The ancestor walk climbs with
# dirname until it reaches "/", and from a relative path it never does:
# dirname "credentials" is ".", dirname "." is ".", and the loop spins for
# ever -- at boot, in the prestart whose whole job is to refuse things.
CREDPATH=credentials
check "refuses a relative credentials path" 1 'must be an absolute path'
CREDPATH=foo/credentials
check "refuses a relative nested credentials path" 1 'must be an absolute path'
unset CREDPATH

# --- the credentials file itself ------------------------------------------
setup 644 0 755 </dev/null
check "refuses mode 644" 1 'is mode 644'
setup 606 0 755 </dev/null
check "refuses mode 606" 1 'is mode 606'
setup 660 0 755 </dev/null
check "refuses mode 660" 1 'is mode 660'
setup 600 65534 755 </dev/null
check "refuses a non-root owner" 1 'not root'
rm -rf "$D/dir"; mkdir -p "$D/dir"; : > "$D/other"; ln -s "$D/other" "$D/dir/credentials"
check "refuses a symlink" 1 'is a symlink'
rm -rf "$D/dir"; mkdir -p "$D/dir"
check "refuses a missing file" 1 'does not exist'

# --- a symlink COMPONENT on the path as written ---------------------------
# realpath validates the ancestors of the RESOLVED directory, while the read at
# the end opens the ORIGINAL path. A symlink component sits on neither walk, so
# whoever can write the directory holding it retargets the link between the
# checks and the read.
rm -rf "$D/dir" "$D/real"; mkdir -p "$D/real"
printf 'CLOUDBSD_REVIEW_TARGETS=cursor\n%s\n' "$ROSTER" > "$D/real/credentials"
chmod 600 "$D/real/credentials"; chown 0 "$D/real/credentials"
chmod 755 "$D/real"; chown 0 "$D/real"
ln -s "$D/real" "$D/dir"
check "refuses a symlink directory component" 1 'must be a real directory'
rm -f "$D/dir"

# --- the parent directory -------------------------------------------------
setup 600 0 777 </dev/null
check "refuses a world-writable parent" 1 'group- or world-writable'
setup 600 0 775 </dev/null
check "refuses a group-writable parent" 1 'group- or world-writable'
setup 600 0 2775 </dev/null
check "refuses setgid+group-writable 2775" 1 'group- or world-writable'
setup 600 0 1777 </dev/null
check "refuses sticky+world-writable 1777" 1 'group- or world-writable'
setup 600 0 755 </dev/null; chown 65534 "$D/dir"
check "refuses a non-root parent" 1 'is owned by uid'

# --- the content ----------------------------------------------------------
setup 600 0 755 <<'X'
command=/bin/sh
X
check "refuses setting command" 1 'does not begin with a valid variable name'
setup 600 0 755 <<'X'
PATH=/tmp/evil
X
check "refuses setting PATH" 1 'is not a variable this service reads'
setup 600 0 755 <<'X'
LD_PRELOAD=/tmp/evil.so
X
check "refuses setting LD_PRELOAD" 1 'is not a variable this service reads'
setup 600 0 755 <<'X'
name=somethingelse
X
check "refuses clobbering rc.subr name" 1 'does not begin with a valid variable name'
setup 600 0 755 <<'X'
CLOUDBSD_REVIEW_X Y=1
X
check "refuses a name with a space" 1 'does not begin with a valid variable name'
setup 600 0 755 <<'X'
CLOUDBSD_REVIEW-X=1
X
check "refuses a name with a dash" 1 'does not begin with a valid variable name'
setup 600 0 755 <<'X'
NOTANASSIGNMENT
X
check "refuses a line that is not NAME=value" 1 'line 1 is not NAME=value'
setup 600 0 755 <<'X'
sk-averyrealsecret
X
check "does not echo a rejected line into the log" 1 'line 1 is not NAME=value'
setup 600 0 755 <<X
CLOUDBSD_REVIEW_TARGETS=a=b=c
$ROSTER
X
check "keeps = inside a value" 0 'CHILD-CLOUDBSD_REVIEW_TARGETS=a=b=c'

# --- the state the comment claims to refuse, reached through the front door -
# A missing file is refused because a service with no roster "answers every
# tool normally and reviews nothing". An EMPTY file reaches that same state and
# passed every check; so does a comment-only one, an explicit empty value, and
# -- the one that survived a whole review round -- an empty JSON list, which is
# not blank and so satisfies any non-empty test. The Go service does not save
# us: config.go logs "no reviewers configured" and returns a working registry
# on purpose.
setup 600 0 755 </dev/null
check "refuses an empty credentials file" 1 'sets no usable CLOUDBSD_REVIEW_TARGETS'
setup 600 0 755 <<'X'
# nothing but comments

X
check "refuses a comment-only file" 1 'sets no usable CLOUDBSD_REVIEW_TARGETS'
setup 600 0 755 <<X
CLOUDBSD_REVIEW_TARGETS=
$ROSTER
X
check "refuses an empty TARGETS value" 1 'sets no usable CLOUDBSD_REVIEW_TARGETS'
setup 600 0 755 <<'X'
CLOUDBSD_REVIEW_TARGETS=cursor
X
check "refuses a file with no REVIEWERS" 1 'sets no usable CLOUDBSD_REVIEW_REVIEWERS'
setup 600 0 755 <<'X'
CLOUDBSD_REVIEW_TARGETS=cursor
CLOUDBSD_REVIEW_REVIEWERS=[]
X
check "refuses an empty JSON roster" 1 'sets no usable CLOUDBSD_REVIEW_REVIEWERS'
setup 600 0 755 <<'X'
CLOUDBSD_REVIEW_TARGETS=,
CLOUDBSD_REVIEW_REVIEWERS=[{"name":"grok"}]
X
check "refuses a TARGETS of only punctuation" 1 'sets no usable CLOUDBSD_REVIEW_TARGETS'
setup 600 0 755 <<'X'
CLOUDBSD_REVIEW_TARGETS=""
CLOUDBSD_REVIEW_REVIEWERS=[{"name":"grok"}]
X
# Nothing here strips quoting, which pkg-message says -- so this is two literal
# quote characters, not an empty value, and it was passing.
check "refuses a quoted-empty TARGETS" 1 'sets no usable CLOUDBSD_REVIEW_TARGETS'

# --- nothing exported when a later line is refused ------------------------
setup 600 0 755 <<X
CLOUDBSD_REVIEW_TARGETS=cursor
$ROSTER
PATH=/tmp/evil
X
check "exports nothing when a later line is refused" 1 'is not a variable this service reads'

# --- the state directory --------------------------------------------------
# It gets the same ancestor walk as the credentials path. It used to get only
# its immediate parent, on the argument that root is the only writer -- which
# describes the default, not the check, and the path is rc.conf-settable.
setup 600 0 755 <<X
CLOUDBSD_REVIEW_TARGETS=cursor
$ROSTER
X
rm -rf "$D/st"; mkdir -p "$D/st/real"; chown 0 "$D/st" "$D/st/real"
chmod 755 "$D/st"; chmod 777 "$D/st/real"
STATEDIR="$D/st/real/review"
check "refuses a world-writable state parent" 1 'group- or world-writable'
chmod 755 "$D/st/real"; ln -s "$D/st/real" "$D/st/link"
STATEDIR="$D/st/link/review"
check "refuses a symlink state parent" 1 'must be a real directory'
rm -rf "$D/st2"; mkdir -p "$D/st2/review"; chown 0 "$D/st2"; chmod 755 "$D/st2"
# 0750 deliberately: the mode check runs before the owner check, so a fixture
# left at mkdir's default 0755 would make this row pass on the mode message and
# never exercise the ownership test it is named for.
chown 0 "$D/st2/review"; chmod 0750 "$D/st2/review"
STATEDIR="$D/st2/review"
# An EXISTING state directory owned by somebody else was never checked, so the
# child got a HOME it could not write and the agent CLIs failed far from here.
check "refuses a state directory owned by another user" 1 'the service writes its state there'
unset STATEDIR

# --- the operator's extra arguments ---------------------------------------
# command_args puts -config first and appends these after it, and Go's flag
# package takes the LAST value -- so one rc.conf line points the service at a
# file none of the checks above ever looked at.
setup 600 0 755 <<X
CLOUDBSD_REVIEW_TARGETS=cursor
$ROSTER
X
ARGS="-config /tmp/other.json"
check "refuses -config in the operator args" 1 'cloudbsd_review_args names -config'
ARGS="--config=/tmp/other.json"
check "refuses --config= in the operator args" 1 'cloudbsd_review_args names -config'
# The value is spliced into a line rc.subr evaluates as root, so it is not
# argv. And the -config guard was space-delimited, so a tab slipped past it.
ARGS='-x $(id)'
check "refuses command substitution in args" 1 'not part of a plain flag'
ARGS='-x `id`'
check "refuses backticks in args" 1 'not part of a plain flag'
ARGS='-x ; id'
check "refuses a command separator in args" 1 'not part of a plain flag'
ARGS=$(printf -- '-x\t-config /tmp/other.json')
check "refuses a tab-separated -config" 1 'not part of a plain flag'
ARGS="-loglevel debug"
check "allows ordinary operator args" 0 'CHILD-CLOUDBSD_REVIEW_TARGETS=cursor'
unset ARGS

# --- the runas account ----------------------------------------------------
setup 600 0 755 <<X
CLOUDBSD_REVIEW_TARGETS=cursor
$ROSTER
X
# export, and unset afterwards: `VAR=x somefunc` is a POSIX wart -- for a
# function the assignment may persist after the call, so a later row would
# quietly inherit it -- and `sh -c` above only sees exported variables anyway.
RUNAS=root; export RUNAS
check "refuses running as root" 1 'must not run as root'
RUNAS=nosuchuser_zzz
check "refuses an unknown runas user" 1 'no such user'
# `id -u 799` resolves, so this passed the uid-0 test -- and daemon(8) then
# calls getpwnam("799") in the child, after the supervisor has already returned
# success. A start that reports success and leaves nothing running.
RUNAS=799
check "refuses a numeric runas" 1 'must be a user NAME'
unset RUNAS

echo
echo "$ran rows, $fail failed"
[ "$fail" = 0 ]
