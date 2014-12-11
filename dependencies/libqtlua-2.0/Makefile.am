
ACLOCAL_AMFLAGS = -I build

SUBDIRS = src tools test doc

if EXAMPLES
SUBDIRS += examples
endif

EXTRA_DIST = bootstrap COPYING.LESSER CMakeLists.txt config.hh.cmake

doc: manual internals

manual:
	mkdoc -I src --conf-file manual.conf

internals:
	mkdoc -I src --conf-file internals.conf

www:
	mkdoc --conf-file web.conf

.PHONY: doc

