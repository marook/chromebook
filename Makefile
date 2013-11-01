PREFIX="/usr/share/themes"

THEME_NAME="chromebook"
THEME_INSTALL_DIR="${PREFIX}/${THEME_NAME}"

all:

include Makefile.gen

install: ${ALL_THEME_FILES}
