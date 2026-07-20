#!/bin/sh
# Fetch git submodules missing from the GitHub archive tarball.
# Pins match revytechinc/wayfire master subprojects (see revytech/wayfire/VERSIONS).
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
		git -C "${srcdir}" fetch -q --depth 1 origin "${commit}"
		git -C "${srcdir}" checkout -q "${commit}"
		echo "${name} fetched successfully"
	else
		echo "${name} already present, skipping"
	fi
}

# Bundled helpers still needed even with system wf-config / wlroots
fetch_submodule "wf-json"  "https://github.com/revytechinc/wf-json.git"  "70039e13cdeaebd8ec498ed30bf5ab91c2e313ec"
fetch_submodule "wf-utils" "https://github.com/revytechinc/wf-utils.git" "329c3ff01724d82947f61c45332f75d3534e8454"
fetch_submodule "wf-touch" "https://github.com/revytechinc/wf-touch.git" "093d8943df03cc8a2667990a065513c1bf2b57e0"
