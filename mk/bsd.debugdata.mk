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
#	TODO: the name of this variable should be changed because it can be
#	TODO: easily confused with PKG_DEBUG_LEVEL!
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

PKG_DEBUGLEVEL?=	default

.if ${PKG_DEBUGLEVEL} != "small" && ${PKG_DEBUGLEVEL} != "default" && \
   ${PKG_DEBUGLEVEL} != "detailed"
PKG_FAIL_REASON+=	"[bsd.debugdata.mk] ${PKG_DEBUGLEVEL} is not a valid PKG_DEBUGLEVEL."
.endif

# All binaries and shared libraries.
_FIND_DEBUGGABLEDATA_ERE=	(bin/|sbin/|libexec/|\.(dylib|sl|so)$$|lib/lib.*\.(dylib|sl|so))

_FIND_DEBUGGABLEDATA_FILELIST_CMD?=					\
	${FIND} ${DESTDIR}${PREFIX} \! -type d -print | ${SORT} |	\
	${SED} -e "s|^${DESTDIR}${PREFIX}/||" |				\
	(while read file; do						\
		${TEST} -h "$$file" || ${ECHO} "$$file";		\
	done)

# Pass debug flags and debug level to the compiler
.if !empty(PKGSRC_COMPILER:Mclang)
.  if ${PKG_DEBUGLEVEL} == "small" || ${PKG_DEBUGLEVEL} == "default"
_WRAP_EXTRA_ARGS.CC+=	-g
CWRAPPERS_APPEND.cc+=	-g
.  elif ${PKG_DEBUGLEVEL} == "detailed"
_WRAP_EXTRA_ARGS.CC+=	-g3
CWRAPPERS_APPEND.cc+=	-g3
.  endif
.elif !empty(PKGSRC_COMPILER:Mgcc)
.  if ${PKG_DEBUGLEVEL} == "small"
_WRAP_EXTRA_ARGS.CC+=	-g1
CWRAPPERS_APPEND.cc+=	-g1
.  elif ${PKG_DEBUGLEVEL} == "default"
_WRAP_EXTRA_ARGS.CC+=	-g
CWRAPPERS_APPEND.cc+=	-g
.  elif ${PKG_DEBUGLEVEL} == "detailed"
_WRAP_EXTRA_ARGS.CC+=	-g3
CWRAPPERS_APPEND.cc+=	-g3
.  endif
.else
_WRAP_EXTRA_ARGS.CC+=	-g
CWRAPPERS_APPEND.cc+=	-g
.endif

PLIST_SRC_DFLT+=	${_PLIST_DEBUGDATA}

.PHONY: generate-strip-debugdata
post-install: generate-strip-debugdata
generate-strip-debugdata:
	@${STEP_MSG} "Stripping debug symbols"
	${RUN}								\
	cd ${DESTDIR:Q}${PREFIX:Q};					\
	${_FIND_DEBUGGABLEDATA_FILELIST_CMD} |				\
	${EGREP} -h ${_FIND_DEBUGGABLEDATA_ERE:Q} |			\
	while read f; do						\
		${TOOLS_PLATFORM.objdump} -f $${f} >/dev/null 2>&1 || continue;	\
		( ${TOOLS_PLATFORM.objcopy} --only-keep-debug			\
			${DESTDIR}${PREFIX}/$$f ${DESTDIR}${PREFIX}/$${f}.debug	\
		&& ${TOOLS_PLATFORM.objcopy} --strip-debug -p -R .gnu_debuglink	\
			--add-gnu-debuglink=${DESTDIR}${PREFIX}/$${f}.debug	\
			${DESTDIR}${PREFIX}/$$f					\
		&& ${ECHO} "$${f}.debug"					\
			>> ${_PLIST_DEBUGDATA}					\
		) || (rm -f ${DESTDIR}${PREFIX}/$${f}.debug; false)		\
	done

# TODO: Modify generate-strip-debugdata in order to generate the `.debug' files
# TODO: in an directory, not directly in ${DESTDIR}${PREFIX}.
# TODO: Write a install-strip-debugdata that INSTALL the `.debug' files in the
# TODO: ${DESTDIR}${PREFIX} with the proper permissions. In this way we will
# TODO: have some kind of "control" over that.

.endif	# PKG_DEBUG_DATA

.endif	# BSD_DEBUGDATA_MK
