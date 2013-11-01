PREFIX="/usr/share/themes"

THEME_NAME="chromebook"
THEME_INSTALL_DIR="${PREFIX}/${THEME_NAME}"

all:

install: ${THEME_INSTALL_DIR}/gtk-2.0/gtkrc

${THEME_INSTALL_DIR}/gtk-2.0/gtkrc: src/gtkrc-2.0
	mkdir -p `dirname "$@"`
	cp "$^" "$@"
