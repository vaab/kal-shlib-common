
shlibdir = $(libdir)/shlib/$(SHLIB_PACKAGE_NAME)/$(MAJOR_VERSION)
autoloaddir = $(shlibdir)/autoload

dist_shlib_DATA = $(srcdir)/lib/lib*.sh
dist_autoload_DATA = $(wildcard $(srcdir)/lib/autoload/*)

EXTRA_DIST = $(dist_shlib_DATA) $(dist_autoload_DATA)

distcleancheck_listfiles = \
  find -type f -exec sh -c 'test -f $(scrdir)/{} || echo {}'
