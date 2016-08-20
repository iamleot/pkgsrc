# $NetBSD$
#
# This file verifies that all binaries and libraries used by the package have
# correctly stripped the debug symbols and if they exists.
#
# User-settable variables:
#
# CHECK_DEBUGDATA
#	Whether the check should be enabled or not.
#
#	Default value: "yes" for PKG_DEVELOPERs, "no" otherwise.
#
# Package-settable variables:
#
# CHECK_DEBUGDATA_SKIP
#	A list of shell patterns (like man/*) that should be excluded
#	from the check. Note that a * in a pattern also matches a slash
#	in a pathname.
#
#	Default value: empty.
#
# CHECK_DEBUGDATA_SUPPORTED
#	Whether the check should be enabled for this package or not.
#
#	Default value: yes
#

_VARGROUPS+=			check-debugdata
_USER_VARS.check-debugdata=	CHECK_DEBUGDATA
_PKG_VARS.check-debugdata=	CHECK_DEBUGDATA_SUPPORTED

.if !empty(PKG_DEBUGDATA:M[yY][eE][sS]) && ${PKG_DEVELOPER:Uno} != "no"
CHECK_DEBUGDATA?=	yes
.else
CHECK_DEBUGDATA?=	no
.endif
CHECK_DEBUGDATA_SUPPORTED?=	yes
CHECK_DEBUGDATA_SKIP?=		# none

# All binaries and shared libraries.
_CHECK_DEBUGDATA_ERE=	(bin/|sbin/|libexec/|\.(dylib|sl|so)$$|lib/lib.*\.(dylib|sl|so))

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
PLISTS+=	${PLIST.${_spkg_}}
.  endfor
_CHECK_DEBUGDATA_FILELIST_CMD?=	${SED} -e '/^@/d' -e '/\.debug$$/d' ${PLISTS} |	\
	(while read file; do							\
		${TEST} -h "$$file" || ${ECHO} "$$file";			\
	done)
.else	# !SUBPACKAGES
_CHECK_DEBUGDATA_FILELIST_CMD?=	${SED} -e '/^@/d' -e '/\.debug$$/d' ${PLIST} |	\
	(while read file; do							\
		${TEST} -h "$$file" || ${ECHO} "$$file";			\
	done)
.endif	# SUBPACKAGES

.if !empty(CHECK_DEBUGDATA:M[Yy][Ee][Ss]) && \
    !empty(CHECK_DEBUGDATA_SUPPORTED:M[Yy][Ee][Ss])
privileged-install-hook: _check-debugdata

USE_TOOLS+=		objdump

_check-debugdata: error-check .PHONY
	@${STEP_MSG} "Checking for missing debug data in ${PKGNAME}"
	${RUN} rm -f ${ERROR_DIR}/${.TARGET}
	${RUN}								\
	cd ${DESTDIR:Q}${PREFIX:Q};					\
	${_CHECK_DEBUGDATA_FILELIST_CMD} |				\
	${EGREP} -h ${_CHECK_DEBUGDATA_ERE:Q} |				\
	while read file; do						\
		case "$$file" in					\
		${CHECK_DEBUGDATA_SKIP:@p@${p}) continue ;;@}		\
		*) ;;							\
		esac;							\
		dpfile=${DESTDIR}${PREFIX}/$$file;			\
		if [ ! -r "$$dpfile" ]; then				\
			${DELAYED_WARNING_MSG}				\
			    "[check-debugdata.mk] File \"$$dpfile\" cannot be read."; \
			continue;					\
		fi;							\
		{ odoutput=`LC_ALL=C ${TOOLS_PLATFORM.objdump} -hw	\
		    -j '.gnu_debuglink' "$$dpfile" 2>&1`; exitcode=$$?; }	\
		    || true;							\
		case $$odoutput in					\
		*File\ format\ not\ recognized*) : ${INFO_MSG} "[check-debugdata.mk] " \
		    "File format of $${dpfile} not recognized (ok).";	\
		    continue;						\
		    ;;							\
		*) if [ $$exitcode -ne 0 ]; then			\
			${DELAYED_ERROR_MSG}				\
			   "[check-debugdata.mk] File \"$$dpfile\" does not have " \
			   ".gnu_debuglink section.";			\
			continue;					\
		fi;							\
		;;							\
		esac;							\
		if [ -r "$${dpfile}.debug" ]; then			\
			{ ${TOOLS_PLATFORM.objdump} -hw -j '.debug_info'	\
			    "$${dpfile}.debug" >/dev/null 2>&1; exitcode=$$?; }	\
			    || true;						\
			if [ $$exitcode -ne 0 ]; then			\
				${DELAYED_WARNING_MSG}			\
				    "[check-debugdata.mk] File "	\
				    "\"$${dpfile}.debug\" does not "	\
				    "contain .debug_info section.";	\
			fi;						\
		else							\
			${DELAYED_ERROR_MSG}				\
			   "[check-debugdata.mk] File "			\
			   "\"$${dpfile}.debug\" cannot be read.";	\
		fi;							\
	done

.else
_check-debugdata: error-check .PHONY
	@${WARNING_MSG} "Skipping debug data check."
.endif
