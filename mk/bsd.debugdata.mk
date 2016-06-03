#	$NetBSD$
#
# This Makefile fragment is included by bsd.pkg.mk and implements the
# logic needed to strip debug symbols off the program/libraries.
#
# User-settable variables:
#
# PKG_DEBUGDATA
#	If "yes", install stripped debug symbols for all programs and shared
#	libraries. Please notice that if it is defined INSTALL_UNSTRIPPED will
#	be also defined internally.
#
# PKG_DEBUGLEVEL
#	Used to control the granularity of the debug information. Can be
#	"small", "default", "detailed".
#
# Package-settable variables:
#
# DEBUGDATA_FILES
#	A list of programs and shared libraries for which the debug symbols
#	should be stripped off
#
# See also:
#	INSTALL_UNSTRIPPED	
#
# Keywords: debug
#

#
# XXX: various notes
#
# o INSTALL_UNSTRIPPED will be probably needed to be defined (see
#   _INSTALL_UNSTRIPPED in bsd.pkg.mk).
# o For all the logic we will probably need - at least for the moment - to
#   inject post-install(s) ad-hoc targets that will run `objcopy' to strip the
#   debug symbols off the programs/libraries. A possible place to look is
#   pax.mk.
# o GENERATE_PLIST should be used to dynamically generate the PLIST
#   corresponding to the DEBUGDATA_FILES. For an example on how it is
#   used please see lang/perl5/packlist.mk.

.if !defined(BSD_DEBUGDATA_MK)
BSD_DEBUGDATA_MK=	# defined

#
# WIP and still EXPERIMENTAL!
#
.if !empty(PKG_DEBUGDATA:M[yY][eE][sS])

# Avoid to pass options to strip to cc(1) and install(1) as we need to handle
# theme here differently.
_INSTALL_UNSTRIPPED=	# defined

.if !empty(DEBUGDATA_FILES)

# Pass debug flags to the compiler
# TODO: honor PKG_DEBUGLEVEL!
_WRAP_EXTRA_ARGS.CC+=	-g
CWRAPPERS_APPEND.cc+=	-g

_INSTALL_ALL_TARGETS+=	post-install-strip-debugdata

.PHONY: post-install-strip-debugdata
post-install: post-install-strip-debugdata
post-install-strip-debugdata:
	@${STEP_MSG} "Stripping debug symbols"
	${RUN}									\
	for f in ${DEBUGDATA_FILES}; do						\
		( ${TOOLS_PLATFORM.objcopy} --only-keep-debug			\
			${DESTDIR}${PREFIX}/$$f ${DESTDIR}${PREFIX}/$${f}.debug	\
		&& ${TOOLS_PLATFORM.objcopy} --strip-debug -p -R .gnu_debuglink	\
			--add-gnu-debuglink=${DESTDIR}${PREFIX}/$${f}.debug	\
			${DESTDIR}${PREFIX}/$$f					\
		) || (rm -f ${DESTDIR}${PREFIX}/$${f}.debug; false)		\
	done
.endif	# DEBUGDATA_FILES

.endif	# PKG_DEBUG_DATA

.endif	# BSD_DEBUGDATA_MK
