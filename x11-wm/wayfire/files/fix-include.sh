#!/bin/sh
# Add missing #include <wayfire/config/section.hpp> to option-wrapper.hpp
FILE="$1"
if ! grep -q '<wayfire/config/section.hpp>' "$FILE"; then
	/bin/ed -s "$FILE" << 'EOF'
/#include <wayfire\/config\/option\.hpp>/a
#include <wayfire/config/section.hpp>
.
w
q
EOF
fi
