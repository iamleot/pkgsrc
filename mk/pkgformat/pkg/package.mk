# $NetBSD: package.mk,v 1.15 2016/05/09 00:07:23 joerg Exp $

.if defined(PKG_SUFX)
WARNINGS+=		"PKG_SUFX is deprecated, please use PKG_COMPRESSION"
.  if ${PKG_SUFX} == ".tgz"
PKG_COMPRESSION=	gzip
.  elif ${PKG_SUFX} == ".tbz"
PKG_COMPRESSION=	bzip2
.  else
WARNINGS+=		"Unsupported value for PKG_SUFX"
.  endif
.endif
PKG_SUFX?=		.tgz
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
FILEBASE.${_spkg_}?=		${PKGBASE.${_spkg_}}
PKGFILE.${_spkg_}?=		${PKGREPOSITORY}/${FILEBASE.${_spkg_}}-${PKGVERSION}${PKG_SUFX}
STAGE_PKGFILE.${_spkg_}?=	${WRKDIR}/.packages/${FILEBASE.${_spkg_}}-${PKGVERSION}${PKG_SUFX}
.  endfor
.else	# !SUBPACKAGES
FILEBASE?=		${PKGBASE}
PKGFILE?=		${PKGREPOSITORY}/${FILEBASE}-${PKGVERSION}${PKG_SUFX}
STAGE_PKGFILE?=		${WRKDIR}/.packages/${FILEBASE}-${PKGVERSION}${PKG_SUFX}
.endif	# SUBPACKAGES
PKGREPOSITORY?=		${PACKAGES}/${PKGREPOSITORYSUBDIR}
PKGREPOSITORYSUBDIR?=	All

######################################################################
### package-create (PRIVATE, pkgsrc/mk/package/package.mk)
######################################################################
### package-create creates the binary package.
###
.PHONY: package-create
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
package-create: ${PKGFILE.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
package-create: ${PKGFILE}
.endif	# SUBPACKAGES

######################################################################
### stage-package-create (PRIVATE, pkgsrc/mk/package/package.mk)
######################################################################
### stage-package-create creates the binary package for stage install.
###
.PHONY: stage-package-create
.if !empty(SUBPACKAGES)
stage-package-create:	stage-install
.  for _spkg_ in ${SUBPACKAGES}
stage-package-create:	${STAGE_PKGFILE.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
stage-package-create:	stage-install ${STAGE_PKGFILE}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_PKG_ARGS_PACKAGE.${_spkg_}+=	${_PKG_CREATE_ARGS.${_spkg_}}
_PKG_ARGS_PACKAGE.${_spkg_}+=	-F ${PKG_COMPRESSION}
_PKG_ARGS_PACKAGE.${_spkg_}+=	-I ${PREFIX} -p ${DESTDIR}${PREFIX}
.if ${_USE_DESTDIR} == "user-destdir"
_PKG_ARGS_PACKAGE.${_spkg_}+=	-u ${REAL_ROOT_USER} -g ${REAL_ROOT_GROUP}
.endif

${STAGE_PKGFILE.${_spkg_}}: ${_CONTENTS_TARGETS.${_spkg_}}
	@${STEP_MSG} "Creating binary package ${.TARGET}"
	${RUN} ${MKDIR} ${.TARGET:H}; ${_ULIMIT_CMD}			\
	tmpname=${.TARGET:S,${PKG_SUFX}$,.tmp${PKG_SUFX},};		\
	if ! ${PKG_CREATE} ${_PKG_ARGS_PACKAGE.${_spkg_}} "$$tmpname"; then	\
		exitcode=$$?; ${RM} -f "$$tmpname"; exit $$exitcode;	\
	fi
.if !empty(SIGN_PACKAGES:U:Mgpg)
	@${STEP_MSG} "Signing binary package ${.TARGET} (GPG)"
	${RUN} tmpname=${.TARGET:S,${PKG_SUFX}$,.tmp${PKG_SUFX},};	\
	${PKG_ADMIN} gpg-sign-package "$$tmpname" ${.TARGET}
.elif !empty(SIGN_PACKAGES:U:Mx509)
	@${STEP_MSG} "Signing binary package ${.TARGET} (X509)"
	${RUN} tmpname=${.TARGET:S,${PKG_SUFX}$,.tmp${PKG_SUFX},};	\
	${PKG_ADMIN} x509-sign-package "$$tmpname" ${.TARGET}		\
		${X509_KEY} ${X509_CERTIFICATE}
.else
	${RUN} tmpname=${.TARGET:S,${PKG_SUFX}$,.tmp${PKG_SUFX},};	\
	${MV} -f "$$tmpname" ${.TARGET}
.endif

.if ${PKGFILE.${_spkg_}} != ${STAGE_PKGFILE.${_spkg_}}
${PKGFILE.${_spkg_}}: ${STAGE_PKGFILE.${_spkg_}}
	@${STEP_MSG} "Creating binary package ${.TARGET}"
	${RUN} ${MKDIR} ${.TARGET:H};					\
	${LN} -f ${STAGE_PKGFILE.${_spkg_}} ${PKGFILE.${_spkg_}} 2>/dev/null ||		\
		${CP} -pf ${STAGE_PKGFILE.${_spkg_}} ${PKGFILE.${_spkg_}}
.endif
.  endfor
.else	# !SUBPACKAGES
_PKG_ARGS_PACKAGE+=	${_PKG_CREATE_ARGS}
_PKG_ARGS_PACKAGE+=	-F ${PKG_COMPRESSION}
_PKG_ARGS_PACKAGE+=	-I ${PREFIX} -p ${DESTDIR}${PREFIX}
.if ${_USE_DESTDIR} == "user-destdir"
_PKG_ARGS_PACKAGE+=	-u ${REAL_ROOT_USER} -g ${REAL_ROOT_GROUP}
.endif

${STAGE_PKGFILE}: ${_CONTENTS_TARGETS}
	@${STEP_MSG} "Creating binary package ${.TARGET}"
	${RUN} ${MKDIR} ${.TARGET:H}; ${_ULIMIT_CMD}			\
	tmpname=${.TARGET:S,${PKG_SUFX}$,.tmp${PKG_SUFX},};		\
	if ! ${PKG_CREATE} ${_PKG_ARGS_PACKAGE} "$$tmpname"; then	\
		exitcode=$$?; ${RM} -f "$$tmpname"; exit $$exitcode;	\
	fi
.if !empty(SIGN_PACKAGES:U:Mgpg)
	@${STEP_MSG} "Signing binary package ${.TARGET} (GPG)"
	${RUN} tmpname=${.TARGET:S,${PKG_SUFX}$,.tmp${PKG_SUFX},};	\
	${PKG_ADMIN} gpg-sign-package "$$tmpname" ${.TARGET}
.elif !empty(SIGN_PACKAGES:U:Mx509)
	@${STEP_MSG} "Signing binary package ${.TARGET} (X509)"
	${RUN} tmpname=${.TARGET:S,${PKG_SUFX}$,.tmp${PKG_SUFX},};	\
	${PKG_ADMIN} x509-sign-package "$$tmpname" ${.TARGET}		\
		${X509_KEY} ${X509_CERTIFICATE}
.else
	${RUN} tmpname=${.TARGET:S,${PKG_SUFX}$,.tmp${PKG_SUFX},};	\
	${MV} -f "$$tmpname" ${.TARGET}
.endif

.if ${PKGFILE} != ${STAGE_PKGFILE}
${PKGFILE}: ${STAGE_PKGFILE}
	@${STEP_MSG} "Creating binary package ${.TARGET}"
	${RUN} ${MKDIR} ${.TARGET:H};					\
	${LN} -f ${STAGE_PKGFILE} ${PKGFILE} 2>/dev/null ||		\
		${CP} -pf ${STAGE_PKGFILE} ${PKGFILE}
.endif
.endif	# SUBPACKAGES

######################################################################
### package-remove (PRIVATE)
######################################################################
### package-remove removes the binary package from the package
### repository.
###
.PHONY: package-remove
.if !empty(SUBPACKAGES)
package-remove:
.  for _spkg_ in ${SUBPACKAGES}
	${RUN} ${RM} -f ${PKGFILE.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
package-remove:
	${RUN} ${RM} -f ${PKGFILE}
.endif	# SUBPACKAGES

######################################################################
### stage-package-remove (PRIVATE)
######################################################################
### stage-package-remove removes the binary package for stage install
###
.PHONY: stage-package-remove
.if !empty(SUBPACKAGES)
stage-package-remove:
.  for _spkg_ in ${SUBPACKAGES}
	${RUN} ${RM} -f ${STAGE_PKGFILE.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
stage-package-remove:
	${RUN} ${RM} -f ${STAGE_PKGFILE}
.endif	# SUBPACKAGES

######################################################################
### tarup (PUBLIC)
######################################################################
### tarup is a public target to generate a binary package from an
### installed package instance.
###
_PKG_TARUP_CMD= ${LOCALBASE}/bin/pkg_tarup

.PHONY: tarup
tarup: package-remove tarup-pkg

######################################################################
### tarup-pkg (PRIVATE)
######################################################################
### tarup-pkg creates a binary package from an installed package instance
### using "pkg_tarup".
###
.if !empty(SUBPACKAGES)
tarup-pkg:
.  for _spkg_ in ${SUBPACKAGES}
	${RUN} [ -x ${_PKG_TARUP_CMD} ] || exit 1;			\
	${PKGSRC_SETENV} PKG_DBDIR=${_PKG_DBDIR} PKG_SUFX=${PKG_SUFX}	\
		PKGREPOSITORY=${PKGREPOSITORY}				\
		${_PKG_TARUP_CMD} -f ${FILEBASE.${_spkg_}} ${PKGNAME.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
tarup-pkg:
	${RUN} [ -x ${_PKG_TARUP_CMD} ] || exit 1;			\
	${PKGSRC_SETENV} PKG_DBDIR=${_PKG_DBDIR} PKG_SUFX=${PKG_SUFX}	\
		PKGREPOSITORY=${PKGREPOSITORY}				\
		${_PKG_TARUP_CMD} -f ${FILEBASE} ${PKGNAME}
.endif	# SUBPACKAGES

######################################################################
### package-install (PUBLIC)
######################################################################
### When DESTDIR support is active, package-install uses package to
### create a binary package and installs it.
### Otherwise it is identical to calling package.
###

.PHONY: package-install real-package-install su-real-package-install
.if defined(_PKGSRC_BARRIER)
package-install: package real-package-install
.else
package-install: barrier
.endif

.PHONY: stage-package-install
.if defined(_PKGSRC_BARRIER)
stage-package-install: stage-package-create real-package-install
.else
stage-package-install: barrier
.endif

.if !empty(USE_CROSS_COMPILE:M[yY][eE][sS])
real-package-install: su-real-package-install
.else
real-package-install: su-target
.endif

# XXXleot: does PKGNAME_REQD need to be SUBPACKAGES-ified?
.if !empty(SUBPACKAGES)
MAKEFLAGS.su-real-package-install=	PKGNAME_REQD=${PKGNAME_REQD:Q}
su-real-package-install:
.  for _spkg_ in ${SUBPACKAGES}
	@${PHASE_MSG} "Installing binary package of "${PKGNAME.${_spkg_}:Q}
.if !empty(USE_CROSS_COMPILE:M[yY][eE][sS])
	@${MKDIR} ${_CROSS_DESTDIR}${PREFIX}
	${PKG_ADD} -m ${MACHINE_ARCH} -I -p ${_CROSS_DESTDIR}${PREFIX} ${STAGE_PKGFILE.${_spkg_}}
	@${ECHO} "Fixing recorded cwd..."
	@${SED} -e 's|@cwd ${_CROSS_DESTDIR}|@cwd |' ${_PKG_DBDIR}/${PKGNAME.${_spkg_}:Q}/+CONTENTS > ${_PKG_DBDIR}/${PKGNAME.${_spkg_}:Q}/+CONTENTS.tmp
	@${MV} ${_PKG_DBDIR}/${PKGNAME.${_spkg_}:Q}/+CONTENTS.tmp ${_PKG_DBDIR}/${PKGNAME.${_spkg_}:Q}/+CONTENTS
.else
	${RUN} case ${_AUTOMATIC:Q}"" in					\
	[yY][eE][sS])	${PKG_ADD} -A ${STAGE_PKGFILE.${_spkg_}} ;;		\
	*)		${PKG_ADD} ${STAGE_PKGFILE.${_spkg_}} ;;			\
	esac
.endif
.  endfor
.else	# !SUBPACKAGES
MAKEFLAGS.su-real-package-install=	PKGNAME_REQD=${PKGNAME_REQD:Q}
su-real-package-install:
	@${PHASE_MSG} "Installing binary package of "${PKGNAME:Q}
.if !empty(USE_CROSS_COMPILE:M[yY][eE][sS])
	@${MKDIR} ${_CROSS_DESTDIR}${PREFIX}
	${PKG_ADD} -m ${MACHINE_ARCH} -I -p ${_CROSS_DESTDIR}${PREFIX} ${STAGE_PKGFILE}
	@${ECHO} "Fixing recorded cwd..."
	@${SED} -e 's|@cwd ${_CROSS_DESTDIR}|@cwd |' ${_PKG_DBDIR}/${PKGNAME:Q}/+CONTENTS > ${_PKG_DBDIR}/${PKGNAME:Q}/+CONTENTS.tmp
	@${MV} ${_PKG_DBDIR}/${PKGNAME:Q}/+CONTENTS.tmp ${_PKG_DBDIR}/${PKGNAME:Q}/+CONTENTS
.else
	${RUN} case ${_AUTOMATIC:Q}"" in					\
	[yY][eE][sS])	${PKG_ADD} -A ${STAGE_PKGFILE} ;;		\
	*)		${PKG_ADD} ${STAGE_PKGFILE} ;;			\
	esac
.endif
.endif	# SUBPACKAGES
