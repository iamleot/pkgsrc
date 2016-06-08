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

.if !defined(BSD_DEBUGDATA_MK)
BSD_DEBUGDATA_MK=	# defined

#
# WIP and still EXPERIMENTAL!
#
.if !empty(PKG_DEBUGDATA:M[yY][eE][sS])

# Avoid to pass options to strip to cc(1) and install(1) as we need to handle
# theme here differently.
_INSTALL_UNSTRIPPED=	# defined

# PLIST containing all stripped debugging symbols
_PLIST_DEBUGDATA=	${WRKDIR}/.PLIST-debugdata

.if !empty(DEBUGDATA_FILES)

# Pass debug flags to the compiler
# TODO: honor PKG_DEBUGLEVEL!
_WRAP_EXTRA_ARGS.CC+=	-g
CWRAPPERS_APPEND.cc+=	-g

PLIST_SRC_DFLT+=	${_PLIST_DEBUGDATA}

.PHONY: generate-strip-debugdata
post-install: generate-strip-debugdata
generate-strip-debugdata:
	@${STEP_MSG} "Stripping debug symbols"
	${RUN}									\
	for f in ${DEBUGDATA_FILES}; do						\
		( ${TOOLS_PLATFORM.objcopy} --only-keep-debug			\
			${DESTDIR}${PREFIX}/$$f ${DESTDIR}${PREFIX}/$${f}.debug	\
		&& ${TOOLS_PLATFORM.objcopy} --strip-debug -p -R .gnu_debuglink	\
			--add-gnu-debuglink=${DESTDIR}${PREFIX}/$${f}.debug	\
			${DESTDIR}${PREFIX}/$$f					\
		&& ${ECHO} "$${f}.debug"					\
			>> ${_PLIST_DEBUGDATA}					\
		) || (rm -f ${DESTDIR}${PREFIX}/$${f}.debug; false)		\
	done

.endif	# DEBUGDATA_FILES

.endif	# PKG_DEBUG_DATA

.endif	# BSD_DEBUGDATA_MK
