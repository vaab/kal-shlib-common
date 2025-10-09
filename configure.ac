AC_INIT(esyscmd(. pkg/pkginfo && echo -n $pkg_name),
	esyscmd(. pkg/pkginfo && echo -n $pkg_version),
	esyscmd(. pkg/pkginfo && echo -n $pkg_bug_report_email))

dnl XXXVAAB : Should make a macro for 
dnl
dnl define('SH_FETCH','esyscmd(. pkg/pkginfo && echo -n $pkg_name)')
dnl
dnl AND check that file loaded is existent...




AM_INIT_AUTOMAKE

AC_PROG_INSTALL
AC_PATH_PROGS(BASH, bash)

if test -z "${BASH}"; then 
   echo "You need BASH to run this script... "
   exit 1
fi

EMAIL="esyscmd(. pkg/author && echo -n $author_email)"
AC_SUBST(EMAIL)
AUTHOR="esyscmd(. pkg/author && echo -n $author_name)"
AC_SUBST(AUTHOR)
CR_DATE="esyscmd(. pkg/licence && echo -n $licence_date)"
AC_SUBST(CR_DATE)

MAJOR_VERSION="$(./autogen.sh --get-version | cut -f 1,2 -d . )"
AC_SUBST(MAJOR_VERSION)
SHLIB_PACKAGE_NAME="$(./autogen.sh --get-name | cut -f 3- -d - )"
AC_SUBST(SHLIB_PACKAGE_NAME)


dnl EXE_NAME=""
dnl AC_SUBST(EXE_NAME)

STATE="esyscmd(. pkg/pkginfo && echo -n $pkg_maturity)"

AC_SUBST(STATE)
AC_OUTPUT(Makefile
	  src/Makefile) 

