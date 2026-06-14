#!/bin/sh
# Fetch git submodules not included in the GitHub tarball.
# Submodules at wayfire-plugins-extra commit a65af25 (v0.11.0)
WRKSRC="$1"

fetch_submodule() {
    local name="$1"
    local url="$2"
    local commit="$3"
    local srcdir="${WRKSRC}/subprojects/${name}"

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

# Submodule commits from wayfire-plugins-extra a65af25 (from git ls-tree HEAD)
fetch_submodule "filters"          "https://github.com/soreau/filters.git"              "00024b531548817ac6c7fed7436e55c4edc5caab"
fetch_submodule "focus-request"   "https://gitlab.com/wayfireplugins/focus-request.git" "b5c5029f1a695bcd79e2fa0de615cd8028f64f62"
fetch_submodule "pixdecor"        "https://github.com/soreau/pixdecor.git"            "8a0b02861221450947f02352d97c81a115ffe05d"
fetch_submodule "wayfire-shadows" "https://github.com/timgott/wayfire-shadows.git"  "453c21713dbe1ebbd209cfa29c14fbb6e9a9d991"
