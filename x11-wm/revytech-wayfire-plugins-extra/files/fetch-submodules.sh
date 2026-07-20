#!/bin/sh
# Fetch plugins-extra submodules not present in GitHub archives.
# Pins from revytech/wayfire/VERSIONS (wayfire-plugins-extra master).
WRKSRC="$1"

fetch_submodule() {
	name="$1"
	url="$2"
	commit="$3"
	srcdir="${WRKSRC}/subprojects/${name}"

	if [ ! -f "${srcdir}/meson.build" ]; then
		echo "Fetching ${name} (commit ${commit})..."
		rm -rf "${srcdir}"
		mkdir -p "${srcdir}"
		git init -q "${srcdir}"
		git -C "${srcdir}" remote add origin "${url}"
		git -C "${srcdir}" fetch -q origin "${commit}"
		git -C "${srcdir}" checkout -q "${commit}"
		echo "${name} fetched successfully"
	else
		echo "${name} already present, skipping"
	fi
}

fetch_submodule "filters" \
	"https://github.com/soreau/filters.git" \
	"8fcaad8192a2be0566a624cfdb20bb101f0d5ca2"
fetch_submodule "focus-request" \
	"https://gitlab.com/wayfireplugins/focus-request.git" \
	"b5c5029f1a695bcd79e2fa0de615cd8028f64f62"
fetch_submodule "pixdecor" \
	"https://github.com/soreau/pixdecor.git" \
	"76a0e8996b41f0df87f0d9c65c816693f1c3fefc"
fetch_submodule "wayfire-shadows" \
	"https://github.com/timgott/wayfire-shadows.git" \
	"4bfdbbf1abe40519183b9a1e1648a732bc656f13"
