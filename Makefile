
all:

install: ~/.gtkrc-2.0

~/.gtkrc-2.0: src/gtkrc-2.0
	cp "$^" "$@"
