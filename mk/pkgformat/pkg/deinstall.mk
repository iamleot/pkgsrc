# $NetBSD: deinstall.mk,v 1.2 2013/05/09 23:37:26 riastradh Exp $

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
# Set the appropriate flags to pass to pkg_delete(1) based on the value
# of DEINSTALLDEPENDS (see pkgsrc/mk/install/deinstall.mk).
#
.if defined(DEINSTALLDEPENDS)
.  if empty(DEINSTALLDEPENDS:M[nN][oO])
.    if !empty(DEINSTALLDEPENDS:M[aA][lL][lL])
_PKG_ARGS_DEINSTALL.${_spkg_}+=	-r	# for "update" target
.    else
_PKG_ARGS_DEINSTALL.${_spkg_}+=	-r -R	# for removing stuff in bulk builds
.    endif
.  endif
.endif

.if defined(PKG_VERBOSE)
_PKG_ARGS_DEINSTALL.${_spkg_}+=	-v
.endif

.if defined(PKG_PRESERVE.${_spkg_})
.  if defined(_UPDATE_RUNNING) && !empty(_UPDATE_RUNNING:M[yY][eE][sS])
_PKG_ARGS_DEINSTALL.${_spkg_}+=	-N -f -f	# update w/o removing any files

MAKEFLAGS.su-deinstall+=	_UPDATE_RUNNING=YES
.  endif
.endif
.  endfor
.else	# !SUBPACKAGES
# Set the appropriate flags to pass to pkg_delete(1) based on the value
# of DEINSTALLDEPENDS (see pkgsrc/mk/install/deinstall.mk).
#
.if defined(DEINSTALLDEPENDS)
.  if empty(DEINSTALLDEPENDS:M[nN][oO])
.    if !empty(DEINSTALLDEPENDS:M[aA][lL][lL])
_PKG_ARGS_DEINSTALL+=	-r	# for "update" target
.    else
_PKG_ARGS_DEINSTALL+=	-r -R	# for removing stuff in bulk builds
.    endif
.  endif
.endif

.if defined(PKG_VERBOSE)
_PKG_ARGS_DEINSTALL+=	-v
.endif

.if defined(PKG_PRESERVE)
.  if defined(_UPDATE_RUNNING) && !empty(_UPDATE_RUNNING:M[yY][eE][sS])
_PKG_ARGS_DEINSTALL+=	-N -f -f	# update w/o removing any files

MAKEFLAGS.su-deinstall+=	_UPDATE_RUNNING=YES
.  endif
.endif
.endif	# SUBPACKAGES

# _pkgformat-deinstall:
#	Removes a package from the system.
#
# See also:
#	deinstall
#
_pkgformat-deinstall: .PHONY
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
	${RUN}								\
	if [ x"${OLDNAME.${_spkg_}}" = x ]; then					\
		found=`${PKG_INFO} -e "${PKGNAME.${_spkg_}}" || ${TRUE}`;		\
	else								\
		found=${OLDNAME.${_spkg_}};					\
	fi;								\
	case "$$found" in						\
	"") found=`${_PKG_BEST_EXISTS} ${PKGWILDCARD.${_spkg_}:Q} || ${TRUE}`;;	\
	esac;								\
	if ${TEST} -n "$$found"; then					\
		${ECHO} "Running ${PKG_DELETE} ${_PKG_ARGS_DEINSTALL.${_spkg_}} $$found"; \
		${PKG_DELETE} ${_PKG_ARGS_DEINSTALL.${_spkg_}} "$$found" || ${TRUE} ; \
	fi
.  endfor
.else	# !SUBPACKAGES
	${RUN}								\
	if [ x"${OLDNAME}" = x ]; then					\
		found=`${PKG_INFO} -e "${PKGNAME}" || ${TRUE}`;		\
	else								\
		found=${OLDNAME};					\
	fi;								\
	case "$$found" in						\
	"") found=`${_PKG_BEST_EXISTS} ${PKGWILDCARD:Q} || ${TRUE}`;;	\
	esac;								\
	if ${TEST} -n "$$found"; then					\
		${ECHO} "Running ${PKG_DELETE} ${_PKG_ARGS_DEINSTALL} $$found"; \
		${PKG_DELETE} ${_PKG_ARGS_DEINSTALL} "$$found" || ${TRUE} ; \
	fi
.endif	# SUBPACKAGES
.if defined(DEINSTALLDEPENDS) && !empty(DEINSTALLDEPENDS:M[yY][eE][sS])
# XXX Need to handle BUILD_DEPENDS/TOOL_DEPENDS split.
.  for _pkg_ in ${BUILD_DEPENDS:C/:.*$//}
	${RUN}								\
	found=`${_PKG_BEST_EXISTS} ${_pkg_:Q} || ${TRUE}`;		\
	if ${TEST} -n "$$found"; then					\
		${ECHO} "Running ${PKG_DELETE} ${_PKG_ARGS_DEINSTALL} $$found"; \
		${PKG_DELETE} ${_PKG_ARGS_DEINSTALL} "$$found" || ${TRUE}; \
	fi
.  endfor
.endif
