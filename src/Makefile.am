
shlibdir = $(libdir)/shlib
dist_shlib_DATA = $(srcdir)/lib/*

EXTRA_DIST = $(dist_shlib_DATA)

distcleancheck_listfiles = \
  find -type f -exec sh -c 'test -f $(scrdir)/{} || echo {}'

