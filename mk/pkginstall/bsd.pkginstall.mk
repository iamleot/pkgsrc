# $NetBSD: bsd.pkginstall.mk,v 1.70 2017/06/01 13:29:18 jlam Exp $
#
# This Makefile fragment is included by bsd.pkg.mk and implements the
# common INSTALL/DEINSTALL scripts framework.  To use the pkginstall
# framework, simply set the relevant variables to customize the install
# scripts to the package.
#
# User-settable variables:
#
# FONTS_VERBOSE indicates whether the +FONTS scriptlet will output a message
#	noting the actions taken if PKG_UPDATE_FONTS_DB is YES.  It is either
#	YES or NO and defaults to YES for PKG_DEVELOPERs, otherwise NO.
#
# INFO_FILES_VERBOSE indicates whether the +INFO_FILES scriptlet will output
#	a message noting the actions taken.  It is either YES or NO and
#	defaults to  YES for PKG_DEVELOPERs, otherwise NO.
#
# TODOleot: The various *_VARS.pkginstall here need to be adjusted for
# TODOleot: subpackages.
#
_VARGROUPS+=		pkginstall
_USER_VARS.pkginstall= \
	FONTS_VERBOSE \
	INFO_FILES_VERBOSE \
	OCAML_FINDLIB_REGISTER_VERBOSE \
	PKG_CREATE_USERGROUP \
	PKG_CONFIG PKG_CONFIG_PERMS \
	PKG_RCD_SCRIPTS \
	PKG_REGISTER_SHELLS \
	PKG_UPDATE_FONTS_DB
_PKG_VARS.pkginstall= \
	DEINSTALL_TEMPLATES INSTALL_TEMPLATES \
	DEINSTALL_SRC INSTALL_SRC \
	FILES_SUBST \
	PKG_USERS PKG_GROUPS USERGROUP_PHASE
.for u in ${PKG_USERS}
_PKG_VARS.pkginstall+=	PKG_UID.${u} PKG_GECOS.${u} PKG_HOME.${u} PKG_SHELL.${u}
.endfor
.for g in ${PKG_GROUPS}
_PKG_VARS.pkginstall+=	PKG_GID.${g}
.endfor
_PKG_VARS.pkginstall+= \
	SPECIAL_PERMS \
	CONF_FILES REQD_FILES \
	CONF_FILES_MODE REQD_FILES_MODE \
	CONF_FILES_PERMS REQD_FILES_PERMS \
	RCD_SCRIPTS ${RCD_SCRIPTS:@s@RCD_SCRIPT_SRC.${s}@} \
	OWN_DIRS MAKE_DIRS REQD_DIRS \
	OWN_DIRS_PERMS MAKE_DIRS_PERMS REQD_DIRS_PERMS \
	PKG_SYSCONFDIR_PERMS \
	PKG_SHELL \
	FONTS_DIRS.ttf FONTS_DIRS.type1 FONTS_DIRS.x11 \
_SYS_VARS.pkginstall= \
	SETUID_ROOT_PERMS \
	SETGID_GAMES_PERMS \
	SHLIB_TYPE \
	LDCONFIG_ADD_CMD \
	LDCONFIG_REMOVE_CMD

# The Solaris /bin/sh does not know the ${foo#bar} shell substitution.
# This shell function serves a similar purpose, but is specialized on
# stripping ${PREFIX}/ from a pathname.
_FUNC_STRIP_PREFIX= \
	strip_prefix() {						\
	  ${AWK} 'END {							\
	    plen = length(prefix);					\
	      if (substr(s, 1, plen) == prefix) {			\
	        s = substr(s, 1 + plen, length(s) - plen);		\
	      }								\
	      print s;							\
	    }' s="$$1" prefix=${PREFIX:Q}/ /dev/null;			\
	}

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_PKGINSTALL_DIR.${_spkg_}=	${WRKDIR}/.pkginstall.${_spkg_}
.  endfor
.else # !SUBPACKAGES
_PKGINSTALL_DIR=	${WRKDIR}/.pkginstall
.endif	# SUBPACKAGES

# XXX This should not be duplicated from the install module, but we
# XXX need this until pkginstall is refactored.
# XXX
PKG_DB_TMPDIR?=		${WRKDIR}/.pkgdb

# These are the template scripts for the INSTALL/DEINSTALL scripts.
# Packages may do additional work in the INSTALL/DEINSTALL scripts by
# overriding the variables DEINSTALL_TEMPLATES and INSTALL_TEMPLATES to
# point to additional script fragments.  These bits are included after
# the main install/deinstall script fragments.
#
# For SUBPACKAGES the INSTALL/DEINSTALL scripts are per-spkgs, respectively
# INSTALL.<spkg> and DEINSTALL.<spkg>.
# Every subpcakage can also override HEADER_TEMPLATES.<spkg>,
# DEINSTALL_TEMPLATES.<spkg> and INSTALL_TEMPLATES.<spkg>.
#
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_HEADER_TMPL?=	${.CURDIR}/../../mk/pkginstall/header
HEADER_TEMPLATES.${_spkg_}?=	# empty
.if exists(${PKGDIR}/HEADER.${_spkg_}) && \
    empty(HEADER_TEMPLATES.${_spkg_}:M${PKGDIR}/HEADER.${_spkg_})
HEADER_TEMPLATES.${_spkg_}+=	${PKGDIR}/HEADER.${_spkg_}
.endif
DEINSTALL_TEMPLATES.${_spkg_}?=	# empty
.if exists(${PKGDIR}/DEINSTALL.${_spkg_}) && \
    empty(DEINSTALL_TEMPLATES.${_spkg_}:M${PKGDIR}/DEINSTALL.${_spkg_})
DEINSTALL_TEMPLATES.${_spkg_}+=	${PKGDIR}/DEINSTALL.${_spkg_}
.endif
_DEINSTALL_TMPL?=	${.CURDIR}/../../mk/pkginstall/deinstall
_INSTALL_UNPACK_TMPL.${_spkg_}?=	# empty
_INSTALL_TMPL?=		${.CURDIR}/../../mk/pkginstall/install
INSTALL_TEMPLATES.${_spkg_}?=	# empty
.if exists(${PKGDIR}/INSTALL.${_spkg_}) && \
    empty(INSTALL_TEMPLATES.${_spkg_}:M${PKGDIR}/INSTALL.${_spkg_})
INSTALL_TEMPLATES.${_spkg_}+=	${PKGDIR}/INSTALL.${_spkg_}
.endif
_INSTALL_DATA_TMPL.${_spkg_}?=	# empty
_FOOTER_TMPL?=		${.CURDIR}/../../mk/pkginstall/footer
.  endfor
.else # !SUBPACKAGES
_HEADER_TMPL?=		${.CURDIR}/../../mk/pkginstall/header
HEADER_TEMPLATES?=	# empty
.if exists(${PKGDIR}/HEADER) && \
    empty(HEADER_TEMPLATES:M${PKGDIR}/HEADER)
HEADER_TEMPLATES+=	${PKGDIR}/HEADER
.endif
DEINSTALL_TEMPLATES?=	# empty
.if exists(${PKGDIR}/DEINSTALL) && \
    empty(DEINSTALL_TEMPLATES:M${PKGDIR}/DEINSTALL)
DEINSTALL_TEMPLATES+=	${PKGDIR}/DEINSTALL
.endif
_DEINSTALL_TMPL?=	${.CURDIR}/../../mk/pkginstall/deinstall
_INSTALL_UNPACK_TMPL?=	# empty
_INSTALL_TMPL?=		${.CURDIR}/../../mk/pkginstall/install
INSTALL_TEMPLATES?=	# empty
.if exists(${PKGDIR}/INSTALL) && \
    empty(INSTALL_TEMPLATES:M${PKGDIR}/INSTALL)
INSTALL_TEMPLATES+=	${PKGDIR}/INSTALL
.endif
_INSTALL_DATA_TMPL?=	# empty
_FOOTER_TMPL?=		${.CURDIR}/../../mk/pkginstall/footer
.endif	# SUBPACKAGES

# _DEINSTALL_TEMPLATES and _INSTALL_TEMPLATES are the list of source
#	files that are concatenated to form the DEINSTALL/INSTALL
#	scripts.
#	For SUBPACKAGES there per-spkg and are respectively
#	_DEINSTALL_TEMPLATES.<spkg> and _INSTALL_TEMPLATES.<spkg>
#
# _DEINSTALL_TEMPLATES_DFLT and _INSTALL_TEMPLATES_DFLT are the list of
#	template files minus any user-supplied templates.
#
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_DEINSTALL_TEMPLATES.${_spkg_}=	${_HEADER_TMPL} ${HEADER_TEMPLATES.${_spkg_}}	\
				${DEINSTALL_TEMPLATES.${_spkg_}}		\
				${_DEINSTALL_TMPL}				\
				${_FOOTER_TMPL}
_INSTALL_TEMPLATES.${_spkg_}=	${_HEADER_TMPL} ${HEADER_TEMPLATES.${_spkg_}}	\
				${_INSTALL_UNPACK_TMPL.${_spkg_}}		\
				${_INSTALL_TMPL}				\
				${INSTALL_TEMPLATES.${_spkg_}}			\
				${_FOOTER_TMPL}					\
				${_INSTALL_DATA_TMPL.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
_DEINSTALL_TEMPLATES=	${_HEADER_TMPL} ${HEADER_TEMPLATES}		\
			${DEINSTALL_TEMPLATES}				\
			${_DEINSTALL_TMPL}				\
			${_FOOTER_TMPL}
_INSTALL_TEMPLATES=	${_HEADER_TMPL} ${HEADER_TEMPLATES}		\
			${_INSTALL_UNPACK_TMPL}				\
			${_INSTALL_TMPL}				\
			${INSTALL_TEMPLATES}				\
			${_FOOTER_TMPL}					\
			${_INSTALL_DATA_TMPL}
.endif	# SUBPACKAGES

_DEINSTALL_TEMPLATES_DFLT=	${_HEADER_TMPL}				\
				${_DEINSTALL_TMPL}			\
				${_FOOTER_TMPL}
_INSTALL_TEMPLATES_DFLT=	${_HEADER_TMPL}				\
				${_INSTALL_TMPL}			\
				${_FOOTER_TMPL}

# These are the list of source files that are concatenated to form the
# INSTALL/DEINSTALL scripts.
#
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
DEINSTALL_SRC.${_spkg_}?=	${_DEINSTALL_TEMPLATES.${_spkg_}}
INSTALL_SRC.${_spkg_}?=		${_INSTALL_TEMPLATES.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
DEINSTALL_SRC?=		${_DEINSTALL_TEMPLATES}
INSTALL_SRC?=		${_INSTALL_TEMPLATES}
.endif	# SUBPACKAGES

# FILES_SUBST lists what to substitute in DEINSTALL/INSTALL scripts and in
# rc.d scripts.
#
# For SUBPACKAGES the FILES_SUBST list is honored by each subpackages.
# Additional per-spkg substitutions are provided via FILES_SUBST.<spkg>
#
# TODOleot: This will probably need to be per-spkg with a FILES_SUBST variable
# TODOleot: shared by every spkgs and proper FILES_SUBST.<spkg>.
# TODOleot: While the definition was adjusted to use FILES_SUBST.<spkg> the
# TODOleot: usage of FILES_SUBST are still not adjusted!
#
FILES_SUBST+=		PREFIX=${PREFIX:Q}
FILES_SUBST+=		LOCALBASE=${LOCALBASE:Q}
FILES_SUBST+=		X11BASE=${X11BASE:Q}
FILES_SUBST+=		VARBASE=${VARBASE:Q}
FILES_SUBST+=		PKG_SYSCONFBASE=${PKG_SYSCONFBASE:Q}
FILES_SUBST+=		PKG_SYSCONFBASEDIR=${PKG_SYSCONFBASEDIR:Q}
# TODOleot: PKG_SYSCONFDIR should be per-spkg
FILES_SUBST+=		CONF_DEPENDS=${CONF_DEPENDS:C/:.*//:Q}
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
FILES_SUBST.${_spkg_}+=		PKG_SYSCONFDIR=${PKG_SYSCONFDIR.${_spkg_}:Q}
FILES_SUBST.${_spkg_}+=		PKGBASE.${_spkg_}=${PKGBASE.${_spkg_}:Q}
.  endfor
.else	# !SUBPACKAGES
FILES_SUBST+=		PKG_SYSCONFDIR=${PKG_SYSCONFDIR:Q}
FILES_SUBST+=		PKGBASE=${PKGBASE:Q}
.endif	# SUBPACKAGES

# PKG_USERS represents the users to create for the package.  It is a
#	space-separated list of elements of the form
#
#		user:group
#
# The following variables are optional and specify further details of
# the user accounts listed in PKG_USERS:
#
# PKG_UID.<user> is the hardcoded numeric UID for <user>.
# PKG_GECOS.<user> is <user>'s description, as well as contact info.
# PKG_HOME.<user> is the home directory for <user>.
# PKG_SHELL.<user> is the login shell for <user>.
#
#
# PKG_GROUPS represents the groups to create for the package.  It is a
#	space-separated list of elements of the form
#
#		group
#
# The following variables are optional and specify further details of
# the user accounts listed in PKG_GROUPS:
#
# PKG_GID.<group> is the hardcoded numeric GID for <group>.
#
# For example:
#
#	PKG_GROUPS+=	mail
#	PKG_USERS+=	courier:mail
#
#	PKG_GECOS.courier=	Courier authlib and mail user
#
# USERGROUP_PHASE is set to the phase just before which users and
#	groups need to be created.  Valid values are "configure" and
#	"build" and "pre-install".
#	If not defined, then by default users and groups are created
#	as pare of the +INSTALL script.  If this is defined, then
#	the numeric UIDs and GIDs of users and groups required by this
#	package are hardcoded into the +INSTALL script.
#
# For SUBPACKAGES PKG_GROUPS and PKG_USERS are per-spkg and can be defined
# via PKG_GROUPS.<spkg> and PKG_USERS.<spkg>.
#
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
PKG_GROUPS.${_spkg_}?=		# empty
PKG_USERS.${_spkg_}?=		# empty
_PKG_USER_HOME.${_spkg_}?=	/nonexistent
_PKG_USER_SHELL.${_spkg_}?=	${NOLOGIN}
FILES_SUBST.${_spkg_}+=		PKG_USER_HOME=${_PKG_USER_HOME.${_spkg_}:Q}
FILES_SUBST.${_spkg_}+=		PKG_USER_SHELL=${_PKG_USER_SHELL.${_spkg_}:Q}
.  endfor
.else	# !SUBPACKAGES
PKG_GROUPS?=		# empty
PKG_USERS?=		# empty
_PKG_USER_HOME?=	/nonexistent
_PKG_USER_SHELL?=	${NOLOGIN}
FILES_SUBST+=		PKG_USER_HOME=${_PKG_USER_HOME:Q}
FILES_SUBST+=		PKG_USER_SHELL=${_PKG_USER_SHELL:Q}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
USE_GAMESGROUP.${_spkg_}?=	no
SETGIDGAME.${_spkg_}?=		${USE_GAMESGROUP.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
USE_GAMESGROUP?=	no
SETGIDGAME?=            ${USE_GAMESGROUP}
.endif	# SUBPACKAGES
# If USE_GAMESGROUP == yes, then we need the "games" group.
# SETGIDGAME is a deprecated alias for USE_GAMESGROUP.
#
# If USE_GAMESGROUP is set, GAMES_GROUP, GAMEMODE, SETGID_GAMES_PERMS,
# etc. variables can be used to install setgid games and their data
# files.
#
# SETGIDGAME is a deprecated alternative variable with the same
# purpose but a murky history and unclear semantics; it is being
# phased out because it conflicts with a like-named build variable in
# the NetBSD base system.
#
# For SUBPACKAGES USE_GAMESGROUP and SETGIDGAME are per-subpackage and
# respectively USE_GAMESGROUP.<spkg> and SETGIDGAME.<spkg>
#
# For now we also create the "games" user; this should not be used and
# should be removed at some point.
#
# TODOleot: Adjust _BUILD_DEFS for SUBPACKAGES case.
#
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
.if (defined(USE_GAMESGROUP.${_spkg_}) && !empty(USE_GAMESGROUP.${_spkg_}:M[yY][eE][sS])) ||\
    (defined(SETGIDGAME.${_spkg_}) && !empty(SETGIDGAME.${_spkg_}:M[yY][eE][sS]))
PKG_GROUPS.${_spkg_}+=	${GAMES_GROUP}
PKG_USERS.${_spkg_}+=	${GAMES_USER}:${GAMES_GROUP}
_BUILD_DEFS+=	GAMES_GROUP GAMES_USER GAMEDATAMODE GAMEDIRMODE GAMEMODE
.endif
.  endfor
.else	# !SUBPACKAGES
.if (defined(USE_GAMESGROUP) && !empty(USE_GAMESGROUP:M[yY][eE][sS])) ||\
    (defined(SETGIDGAME) && !empty(SETGIDGAME:M[yY][eE][sS]))
PKG_GROUPS+=	${GAMES_GROUP}
PKG_USERS+=	${GAMES_USER}:${GAMES_GROUP}
_BUILD_DEFS+=	GAMES_GROUP GAMES_USER GAMEDATAMODE GAMEDIRMODE GAMEMODE
.endif
.endif	# SUBPACKAGES

# Interix is very special in that users and groups cannot have the
# same name.  Interix.mk tries to work around this by overriding
# some specific package defaults.  If we get here and there's still a
# conflict, add a breakage indicator to make sure the package won't
# compile without changing something.
#
.if !empty(OPSYS:MInterix)
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
.    for user in ${PKG_USERS.${_spkg_}:C/\\\\//g:C/:.*//}
.      if !empty(PKG_GROUPS.${_spkg_}:M${user})
PKG_FAIL_REASON+=	"User and group '${user}' cannot have the same name on Interix"
.      endif
.    endfor
.  endfor
.else	# !SUBPACKAGES
.  for user in ${PKG_USERS:C/\\\\//g:C/:.*//}
.    if !empty(PKG_GROUPS:M${user})
PKG_FAIL_REASON+=	"User and group '${user}' cannot have the same name on Interix"
.    endif
.  endfor
.endif	# SUBPACKAGES
.endif

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
.if !empty(PKG_USERS.${_spkg_}) || !empty(PKG_GROUPS.${_spkg_})
DEPENDS.${_spkg_}+=		${_USER_DEPENDS}
.endif
.  endfor
.else	# !SUBPACKAGES
.if !empty(PKG_USERS) || !empty(PKG_GROUPS)
DEPENDS+=		${_USER_DEPENDS}
.endif
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_INSTALL_USERGROUP_FILE.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/usergroup
.  endfor
.else	# !SUBPACKAGES
_INSTALL_USERGROUP_FILE=	${_PKGINSTALL_DIR}/usergroup
.endif	# SUBPACKAGES
.if exists(../../mk/pkginstall/usergroupfuncs.${OPSYS})
_INSTALL_USERGROUPFUNCS_FILE?=	../../mk/pkginstall/usergroupfuncs.${OPSYS}
.else
_INSTALL_USERGROUPFUNCS_FILE?=	../../mk/pkginstall/usergroupfuncs
.endif
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_INSTALL_USERGROUP_DATAFILE.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/usergroup-data
_INSTALL_UNPACK_TMPL.${_spkg_}+=	${_INSTALL_USERGROUP_FILE.${_spkg_}}
_INSTALL_DATA_TMPL.${_spkg_}+=		${_INSTALL_USERGROUP_DATAFILE.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
_INSTALL_USERGROUP_DATAFILE=	${_PKGINSTALL_DIR}/usergroup-data
_INSTALL_UNPACK_TMPL+=		${_INSTALL_USERGROUP_FILE}
_INSTALL_DATA_TMPL+=		${_INSTALL_USERGROUP_DATAFILE}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
.    for _group_ in ${PKG_GROUPS.${_spkg_}}
.      if defined(USERGROUP_PHASE)
# Determine the numeric GID of each group.
USE_TOOLS+=	perl
PKG_GID.${_group_}_cmd=							\
	if ${TEST} ! -x ${PERL5}; then ${ECHO} ""; exit 0; fi;		\
	${PERL5} -le 'print scalar getgrnam shift' ${_group_}
PKG_GID.${_group_}?=	${PKG_GID.${_group_}_cmd:sh:M*}
.      endif
_PKG_GROUPS.${_spkg_}+=	${_group_}:${PKG_GID.${_group_}}
.    endfor
.  endfor
.else	# !SUBPACKAGES
.for _group_ in ${PKG_GROUPS}
.  if defined(USERGROUP_PHASE)
# Determine the numeric GID of each group.
USE_TOOLS+=	perl
PKG_GID.${_group_}_cmd=							\
	if ${TEST} ! -x ${PERL5}; then ${ECHO} ""; exit 0; fi;		\
	${PERL5} -le 'print scalar getgrnam shift' ${_group_}
PKG_GID.${_group_}?=	${PKG_GID.${_group_}_cmd:sh:M*}
.  endif
_PKG_GROUPS+=	${_group_}:${PKG_GID.${_group_}}
.endfor
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
.    for _entry_ in ${PKG_USERS.${_spkg_}}
.      for e in ${_entry_:C/\:.*//}
.        if defined(USERGROUP_PHASE)
# Determine the numeric UID of each user.
USE_TOOLS+=	perl
PKG_UID.${e}_cmd=							\
	if ${TEST} ! -x ${PERL5}; then ${ECHO} ""; exit 0; fi;		\
	${PERL5} -le 'print scalar getpwnam shift' ${e}
PKG_UID.${e}?=	${PKG_UID.${e}_cmd:sh:M*}
.        endif
_PKG_USERS.${_spkg_}+=	${_entry_}:${PKG_UID.${e}}:${PKG_GECOS.${e}:Q}:${PKG_HOME.${e}:Q}:${PKG_SHELL.${e}:Q}
.      endfor
.    endfor
.  endfor
.else	# !SUBPACKAGES
.for _entry_ in ${PKG_USERS}
.  for e in ${_entry_:C/\:.*//}
.    if defined(USERGROUP_PHASE)
# Determine the numeric UID of each user.
USE_TOOLS+=	perl
PKG_UID.${e}_cmd=							\
	if ${TEST} ! -x ${PERL5}; then ${ECHO} ""; exit 0; fi;		\
	${PERL5} -le 'print scalar getpwnam shift' ${e}
PKG_UID.${e}?=	${PKG_UID.${e}_cmd:sh:M*}
.    endif
_PKG_USERS+=	${_entry_}:${PKG_UID.${e}}:${PKG_GECOS.${e}:Q}:${PKG_HOME.${e}:Q}:${PKG_SHELL.${e}:Q}
.  endfor
.endfor
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_USERGROUP_DATAFILE.${_spkg_}}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	set -- dummy ${_PKG_GROUPS.${_spkg_}:C/\:*$//}; shift;		\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		i="$$1"; shift;						\
		${ECHO} "# GROUP: $$i";					\
	done
	${RUN}								\
	set -- dummy ${_PKG_USERS.${_spkg_}:C/\:*$//}; shift;		\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		i="$$1"; shift;						\
		${ECHO} "# USER: $$i";					\
	done
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_USERGROUP_DATAFILE}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	set -- dummy ${_PKG_GROUPS:C/\:*$//}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		i="$$1"; shift;						\
		${ECHO} "# GROUP: $$i";					\
	done
	${RUN}								\
	set -- dummy ${_PKG_USERS:C/\:*$//}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		i="$$1"; shift;						\
		${ECHO} "# USER: $$i";					\
	done
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_USERGROUP_FILE.${_spkg_}}: ${_INSTALL_USERGROUP_DATAFILE.${_spkg_}}
${_INSTALL_USERGROUP_FILE.${_spkg_}}:					\
		../../mk/pkginstall/usergroup				\
		${INSTALL_USERGROUPFUNCS_FILE.${_spkg_}}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED}	-e "/^# platform-specific adduser\/addgroup functions/r${_INSTALL_USERGROUPFUNCS_FILE.${_spkg_}}" ../../mk/pkginstall/usergroup |			\
	${SED} ${FILES_SUBST_SED.${_spkg_}} > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_USERGROUP_DATAFILE.${_spkg_}}; then	\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_USERGROUP_FILE}: ${_INSTALL_USERGROUP_DATAFILE}
${_INSTALL_USERGROUP_FILE}:						\
		../../mk/pkginstall/usergroup				\
		${INSTALL_USERGROUPFUNCS_FILE}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED}	-e "/^# platform-specific adduser\/addgroup functions/r${_INSTALL_USERGROUPFUNCS_FILE}" ../../mk/pkginstall/usergroup |			\
	${SED} ${FILES_SUBST_SED} > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_USERGROUP_DATAFILE}; then	\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_INSTALL_USERGROUP_UNPACKER.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/usergroup-unpack
.  endfor
.else	# !SUBPACKAGES
_INSTALL_USERGROUP_UNPACKER=	${_PKGINSTALL_DIR}/usergroup-unpack
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_USERGROUP_UNPACKER.${_spkg_}}:				\
		${_INSTALL_USERGROUP_FILE.${_spkg_}}			\
		${_INSTALL_USERGROUP_DATAFILE.${_spkg_}}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	exec 1>${.TARGET};						\
	${ECHO} "#!${SH}";						\
	${ECHO} "";							\
	${ECHO} "CAT="${CAT:Q};						\
	${ECHO} "CHMOD="${CHMOD:Q};					\
	${ECHO} "SED="${SED:Q};						\
	${ECHO} "";							\
	${ECHO} "SELF=\$$0";						\
	${ECHO} "STAGE=UNPACK";						\
	${ECHO} "";							\
	${CAT}	${_INSTALL_USERGROUP_FILE.${_spkg_}}			\
		${_INSTALL_USERGROUP_DATAFILE.${_spkg_}}
	${RUN}${CHMOD} +x ${.TARGET}
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_USERGROUP_UNPACKER}:						\
		${_INSTALL_USERGROUP_FILE}				\
		${_INSTALL_USERGROUP_DATAFILE}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	exec 1>${.TARGET};						\
	${ECHO} "#!${SH}";						\
	${ECHO} "";							\
	${ECHO} "CAT="${CAT:Q};						\
	${ECHO} "CHMOD="${CHMOD:Q};					\
	${ECHO} "SED="${SED:Q};						\
	${ECHO} "";							\
	${ECHO} "SELF=\$$0";						\
	${ECHO} "STAGE=UNPACK";						\
	${ECHO} "";							\
	${CAT}	${_INSTALL_USERGROUP_FILE}				\
		${_INSTALL_USERGROUP_DATAFILE}
	${RUN}${CHMOD} +x ${.TARGET}
.endif	# SUBPACKAGES

.if defined(USERGROUP_PHASE)
.  if !empty(USERGROUP_PHASE:M*configure)
pre-configure: create-usergroup
.  elif !empty(USERGROUP_PHASE:M*build)
pre-build: create-usergroup
.  elif !empty(USERGROUP_PHASE:Mpre-install)
pre-install: create-usergroup
.  endif
.endif

_INSTALL_USERGROUP_CHECK=						\
	${PKGSRC_SETENV} PERL5=${PERL5:Q}					\
	${SH} ${PKGSRCDIR}/mk/pkginstall/usergroup-check

.PHONY: create-usergroup
create-usergroup: su-target
	@${STEP_MSG} "Requiring users and groups for ${PKGNAME}"

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
PRE_CMD.su-create-usergroup.${_spkg_}=							\
	if ${_INSTALL_USERGROUP_CHECK} -g ${_PKG_GROUPS.${_spkg_}:C/\:*$//} &&		\
	   ${_INSTALL_USERGROUP_CHECK} -u ${_PKG_USERS.${_spkg_}:C/\:*$//}; then	\
		exit 0;									\
	fi
.  endfor
.else	# !SUBPACKAGES
PRE_CMD.su-create-usergroup=						\
	if ${_INSTALL_USERGROUP_CHECK} -g ${_PKG_GROUPS:C/\:*$//} &&	\
	   ${_INSTALL_USERGROUP_CHECK} -u ${_PKG_USERS:C/\:*$//}; then	\
		exit 0;							\
	fi
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
.PHONY: su-create-usergroup.${_spkg_}
su-create-usergroup.${_spkg_}: ${_INSTALL_USERGROUP_UNPACKER.${_spkg_}}
	${RUN}								\
	cd ${_PKGINSTALL_DIR.${_spkg_}} &&				\
	${SH} ${_INSTALL_USERGROUP_UNPACKER.${_spkg_}};			\
	exitcode=1;							\
	if ${TEST} -f ./+USERGROUP &&					\
	   ./+USERGROUP ADD ${_PKG_DBDIR}/${PKGNAME.${_spkg_}} &&	\
	   ./+USERGROUP CHECK-ADD ${_PKG_DBDIR}/${PKGNAME.${_spkg_}}; then	\
		exitcode=0;						\
	fi;								\
	${RM} -f ${_INSTALL_USERGROUP_FILE.${_spkg_}:Q}			\
		${_INSTALL_USERGROUP_DATAFILE.${_spkg_}:Q}		\
		${_INSTALL_USERGROUP_UNPACKER.${_spkg_}:Q}		\
		./+USERGROUP;						\
	exit $$exitcode
.  endfor
.else	# !SUBPACKAGES
.PHONY: su-create-usergroup
su-create-usergroup: ${_INSTALL_USERGROUP_UNPACKER}
	${RUN}								\
	cd ${_PKGINSTALL_DIR} &&					\
	${SH} ${_INSTALL_USERGROUP_UNPACKER};				\
	exitcode=1;							\
	if ${TEST} -f ./+USERGROUP &&					\
	   ./+USERGROUP ADD ${_PKG_DBDIR}/${PKGNAME} &&			\
	   ./+USERGROUP CHECK-ADD ${_PKG_DBDIR}/${PKGNAME}; then	\
		exitcode=0;						\
	fi;								\
	${RM} -f ${_INSTALL_USERGROUP_FILE:Q}				\
		${_INSTALL_USERGROUP_DATAFILE:Q}			\
		${_INSTALL_USERGROUP_UNPACKER:Q}			\
		./+USERGROUP;						\
	exit $$exitcode
.endif	# SUBPACKAGES

# SPECIAL_PERMS are lists that look like:
#		file user group mode
#	At post-install time, <file> (it may be a directory) is changed
#	to be owned by <user>:<group> with <mode> permissions.  If a file
#	pathname is relative, then it is taken to be relative to ${PREFIX}.
#
#	SPECIAL_PERMS should be used primarily to change permissions of
#	files or directories listed in the PLIST.  This may be used to
#	make certain files set-uid or to change the ownership or a
#	directory.
#
#	The special permissions may not directly recorded (as file
#	attributes) in the binary package file.
#
# For SUBPACKAGES SPECIAL_PERMS are per-subpackage via SPECIAL_PERMS.<spkg>.
#
# SETUID_ROOT_PERMS is a convenience definition to note an executable is
# meant to be setuid-root, and should be used as follows:
#
#	SPECIAL_PERMS+=	/path/to/suidroot ${SETUID_ROOT_PERMS}
#
# SETGID_GAMES_PERMS is a convenience definition to note an executable is
# meant to be setgid games, and should be used as follows:
#
#	SPECIAL_PERMS+=	/path/to/sgidgame ${SETGID_GAMES_PERMS}
#
# GAMEDATA_PERMS and GAMEDIR_PERMS are convenience definitions for files
# that are meant to be accessed by things that are setgid games. Because
# such files should normally be under ${VARBASE}, generally these 
# definitions should be used roughly as follows:
#
#	REQD_DIRS_PERMS+=  /path/to/scoredir ${GAMEDIR_PERMS}
#	REQD_FILES_PERMS+= /dev/null /path/to/scorefile ${GAMEDATA_PERMS}
#
# Note that GAMEDIR_PERMS should only be used when the game requires
# write access to scribble in its directory; many games do not, in which
# case REQD_DIRS instead of REQD_DIRS_PERMS can be used and GAMEDIR_PERMS
# is not needed.
#
# Keywords: setuid setgid st_mode perms
#
SETUID_ROOT_PERMS?=	${REAL_ROOT_USER} ${REAL_ROOT_GROUP} 4511
SETGID_GAMES_PERMS?=	${GAMES_USER} ${GAMES_GROUP} ${GAMEMODE}
GAMEDATA_PERMS?=	${GAMES_USER} ${GAMES_GROUP} ${GAMEDATAMODE}
GAMEDIR_PERMS?=		${GAMES_USER} ${GAMES_GROUP} ${GAMEDIRMODE}
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
SPECIAL_PERMS.${_spkg_}?=	# empty

_INSTALL_PERMS_FILE.${_spkg_}=		${_PKGINSTALL_DIR.${_spkg_}}/perms
_INSTALL_PERMS_DATAFILE.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/perms-data
_INSTALL_UNPACK_TMPL.${_spkg_}+=	${_INSTALL_PERMS_FILE.${_spkg_}}
_INSTALL_DATA_TMPL.${_spkg_}+=		${_INSTALL_PERMS_DATAFILE.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
SPECIAL_PERMS?=		# empty

_INSTALL_PERMS_FILE=		${_PKGINSTALL_DIR}/perms
_INSTALL_PERMS_DATAFILE=	${_PKGINSTALL_DIR}/perms-data
_INSTALL_UNPACK_TMPL+=		${_INSTALL_PERMS_FILE}
_INSTALL_DATA_TMPL+=		${_INSTALL_PERMS_DATAFILE}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_PERMS_DATAFILE.${_spkg_}}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${SPECIAL_PERMS.${_spkg_}}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		file="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# PERMS: $$file $$mode $$owner $$group";	\
	done
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_PERMS_DATAFILE}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${SPECIAL_PERMS}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		file="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# PERMS: $$file $$mode $$owner $$group";	\
	done
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_PERMS_FILE.${_spkg_}}: ${_INSTALL_PERMS_DATAFILE.${_spkg_}}
${_INSTALL_PERMS_FILE.${_spkg_}}: ../../mk/pkginstall/perms
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED} ../../mk/pkginstall/perms > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_PERMS_DATAFILE.${_spkg_}}; then		\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_PERMS_FILE}: ${_INSTALL_PERMS_DATAFILE}
${_INSTALL_PERMS_FILE}: ../../mk/pkginstall/perms
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED} ../../mk/pkginstall/perms > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_PERMS_DATAFILE}; then		\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.endif	# SUBPACKAGES

# CONF_FILES
# REQD_FILES
#	Pairs of example and true config files, used much like MLINKS in
#	the NetBSD base system.  At post-install time, if the true config
#	file doesn't exist, then the example one is copied into place.  At
#	deinstall time, the true one is removed if it doesn't differ from the
#	example one.  REQD_FILES is the same as CONF_FILES but the value
#	of PKG_CONFIG is ignored.
#
#	However, all files listed in REQD_FILES should be under ${PREFIX}.
#	(XXX: Why?)
#
# For SUBPACKAGES these variables are per-subpackage and available as
# CONF_FILES.<spkg> and REQD_FILES.<spkg>.
#
# CONF_FILES_MODE and REQD_FILES_MODE are the file permissions for the
# files in CONF_FILES and REQD_FILES, respectively.
#
# For SUBPACKAGES these variables are per-subpackage and available as
# CONF_FILES_MODE.<spkg> and REQD_FILES_MODE.<spkg>.
#
# CONF_FILES_PERMS
# REQD_FILES_PERMS
#	Lists that look like:
#
#		example_file config_file user group mode
#
#	This works like CONF_FILES and REQD_FILES, except that the config
#	files are owned by user:group and have mode permissions.
#	REQD_FILES_PERMS is the same as CONF_FILES_PERMS but the value of
#	PKG_CONFIG is ignored;
#
#	However, all files listed in REQD_FILES_PERMS should be under
#	${PREFIX}. (XXX: Why?)
#
# For SUBPACKAGES these variables are per-subpackage and available as
# CONF_FILES_PERMS.<spkg> and REQD_FILES_PERMS.<spkg>.
#
# RCD_SCRIPTS lists the basenames of the rc.d scripts.  They are
#	expected to be found in ${PREFIX}/share/examples/rc.d, and
#	the scripts will be copied into ${RCD_SCRIPTS_DIR} with
#	${RCD_SCRIPTS_MODE} permissions.
#
# For SUBPACKAGES RCD_SCRIPTS is per-subpackage and available as
# RCD_SCRIPTS.<spkg>.
#
# If any file pathnames are relative, then they are taken to be relative
# to ${PREFIX}.
#
# Keywords: etc conf configuration
#

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
CONF_FILES.${_spkg_}?=		# empty
CONF_FILES_MODE.${_spkg_}?=	0644
CONF_FILES_PERMS.${_spkg_}?=	# empty
.  endfor
.else	# !SUBPACKAGES
CONF_FILES?=		# empty
CONF_FILES_MODE?=	0644
CONF_FILES_PERMS?=	# empty
.endif	# SUBPACKAGES
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
RCD_SCRIPTS.${_spkg_}?=		# empty
RCD_SCRIPTS_MODE.${_spkg_}?=	0755
RCD_SCRIPTS_SHELL.${_spkg_}?=	${SH}
FILES_SUBST.${_spkg_}+=		RCD_SCRIPTS_SHELL=${RCD_SCRIPTS_SHELL.${_spkg_}:Q}
.  endfor
.else	# !SUBPACKAGES
RCD_SCRIPTS?=		# empty
RCD_SCRIPTS_MODE?=	0755
RCD_SCRIPTS_SHELL?=	${SH}
FILES_SUBST+=		RCD_SCRIPTS_SHELL=${RCD_SCRIPTS_SHELL:Q}
.endif	# SUBPACKAGES
RCD_SCRIPTS_EXAMPLEDIR=	share/examples/rc.d
MESSAGE_SUBST+=		RCD_SCRIPTS_DIR=${RCD_SCRIPTS_DIR}
MESSAGE_SUBST+=		RCD_SCRIPTS_EXAMPLEDIR=${RCD_SCRIPTS_EXAMPLEDIR}

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_INSTALL_FILES_FILE.${_spkg_}=		${_PKGINSTALL_DIR.${_spkg_}}/files
_INSTALL_FILES_DATAFILE.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/files-data
_INSTALL_UNPACK_TMPL.${_spkg_}+=	${_INSTALL_FILES_FILE.${_spkg_}}
_INSTALL_DATA_TMPL.${_spkg_}+=		${_INSTALL_FILES_DATAFILE.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
_INSTALL_FILES_FILE=		${_PKGINSTALL_DIR}/files
_INSTALL_FILES_DATAFILE=	${_PKGINSTALL_DIR}/files-data
_INSTALL_UNPACK_TMPL+=		${_INSTALL_FILES_FILE}
_INSTALL_DATA_TMPL+=		${_INSTALL_FILES_DATAFILE}
.endif	# SUBPACKAGES

# Only generate init scripts if we are using rc.d
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_INSTALL_RCD_SCRIPTS.${_spkg_}=	# empty

.if ${INIT_SYSTEM} == "rc.d"
_INSTALL_RCD_SCRIPTS.${_spkg_}=	${RCD_SCRIPTS.${_spkg_}}
.endif
.  endfor
.else	# !SUBPACKAGES
_INSTALL_RCD_SCRIPTS=	# empty

.if ${INIT_SYSTEM} == "rc.d"
_INSTALL_RCD_SCRIPTS=	${RCD_SCRIPTS}
.endif
.endif	# SUBPACKAGES

privileged-install-hook: _pkginstall-postinstall-check
_pkginstall-postinstall-check: .PHONY
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
	${RUN} p="${DESTDIR}${PREFIX}";					\
	${_FUNC_STRIP_PREFIX};						\
	canon() { f=`strip_prefix "$$1"`; case $$f in [!/]*) f="$$p/$$f"; esac; echo "$$f"; }; \
	needargs() { [ $$3 -ge $$2 ] || ${FAIL_MSG} "[bsd.pkginstall.mk] $$1 must have a multiple of $$2 words. Rest: $$4"; }; \
	set args ${_INSTALL_RCD_SCRIPTS.${_spkg_}}; shift;		\
	while [ $$# -gt 0 ]; do						\
		egfile=`canon "${RCD_SCRIPTS_EXAMPLEDIR}/$$1"`; shift;	\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "RCD_SCRIPT $$egfile does not exist."; \
	done;								\
	set args ${CONF_FILES.${_spkg_}}; shift;			\
	while [ $$# -gt 0 ]; do						\
		needargs CONF_FILES 2 $$# "$$*";			\
		egfile=`canon "$$1"`; shift 2;				\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "CONF_FILE $$egfile does not exist."; \
	done;								\
	set args ${REQD_FILES.${_spkg_}}; shift;			\
	while [ $$# -gt 0 ]; do						\
		needargs REDQ_FILES 2 $$# "$$*";			\
		egfile=`canon "$$1"`; shift 2;				\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "REQD_FILE $$egfile does not exist."; \
	done;								\
	set args ${CONF_FILES_PERMS.${_spkg_}}; shift;			\
	while [ $$# -gt 0 ]; do						\
		needargs CONF_FILES_PERMS 5 $$# "$$*";			\
		egfile=`canon "$$1"`; shift 5;				\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "CONF_FILES_PERMS $$egfile does not exist."; \
	done;								\
	set args ${REQD_FILES_PERMS.${_spkg_}}; shift;			\
	while [ $$# -gt 0 ]; do						\
		needargs REQD_FILES_PERMS 5 $$# "$$*";			\
		egfile=`canon "$$1"`; shift 5;				\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "REQD_FILES_PERMS $$egfile does not exist."; \
	done								
.  endfor
.else	# !SUBPACKAGES
	${RUN} p="${DESTDIR}${PREFIX}";					\
	${_FUNC_STRIP_PREFIX};						\
	canon() { f=`strip_prefix "$$1"`; case $$f in [!/]*) f="$$p/$$f"; esac; echo "$$f"; }; \
	needargs() { [ $$3 -ge $$2 ] || ${FAIL_MSG} "[bsd.pkginstall.mk] $$1 must have a multiple of $$2 words. Rest: $$4"; }; \
	set args ${_INSTALL_RCD_SCRIPTS}; shift;			\
	while [ $$# -gt 0 ]; do						\
		egfile=`canon "${RCD_SCRIPTS_EXAMPLEDIR}/$$1"`; shift;	\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "RCD_SCRIPT $$egfile does not exist."; \
	done;								\
	set args ${CONF_FILES}; shift;					\
	while [ $$# -gt 0 ]; do						\
		needargs CONF_FILES 2 $$# "$$*";			\
		egfile=`canon "$$1"`; shift 2;				\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "CONF_FILE $$egfile does not exist."; \
	done;								\
	set args ${REQD_FILES}; shift;					\
	while [ $$# -gt 0 ]; do						\
		needargs REDQ_FILES 2 $$# "$$*";			\
		egfile=`canon "$$1"`; shift 2;				\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "REQD_FILE $$egfile does not exist."; \
	done;								\
	set args ${CONF_FILES_PERMS}; shift;				\
	while [ $$# -gt 0 ]; do						\
		needargs CONF_FILES_PERMS 5 $$# "$$*";			\
		egfile=`canon "$$1"`; shift 5;				\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "CONF_FILES_PERMS $$egfile does not exist."; \
	done;								\
	set args ${REQD_FILES_PERMS}; shift;				\
	while [ $$# -gt 0 ]; do						\
		needargs REQD_FILES_PERMS 5 $$# "$$*";			\
		egfile=`canon "$$1"`; shift 5;				\
		[ -f "$$egfile" ] || [ -c "$$egfile" ] || ${FAIL_MSG} "REQD_FILES_PERMS $$egfile does not exist."; \
	done
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_FILES_DATAFILE.${_spkg_}}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${_INSTALL_RCD_SCRIPTS.${_spkg_}}; shift;		\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		script="$$1"; shift;					\
		file="${RCD_SCRIPTS_DIR:S/^${PREFIX}\///}/$$script";	\
		egfile="${RCD_SCRIPTS_EXAMPLEDIR}/$$script";		\
		${ECHO} "# FILE: $$file cr $$egfile ${RCD_SCRIPTS_MODE.${_spkg_}}"; \
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${CONF_FILES.${_spkg_}}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		shift; shift;						\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file c $$egfile ${CONF_FILES_MODE.${_spkg_}}"; \
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${REQD_FILES.${_spkg_}}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		shift; shift;						\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file cf $$egfile ${REQD_FILES_MODE.${_spkg_}}"; \
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${CONF_FILES_PERMS.${_spkg_}}; shift;		\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		owner="$$3"; group="$$4"; mode="$$5";			\
		shift; shift; shift; shift; shift;			\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file c $$egfile $$mode $$owner $$group"; \
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${REQD_FILES_PERMS.${_spkg_}}; shift;		\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		owner="$$3"; group="$$4"; mode="$$5";			\
		shift; shift; shift; shift; shift;			\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file cf $$egfile $$mode $$owner $$group"; \
	done
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_FILES_DATAFILE}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${_INSTALL_RCD_SCRIPTS}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		script="$$1"; shift;					\
		file="${RCD_SCRIPTS_DIR:S/^${PREFIX}\///}/$$script";	\
		egfile="${RCD_SCRIPTS_EXAMPLEDIR}/$$script";		\
		${ECHO} "# FILE: $$file cr $$egfile ${RCD_SCRIPTS_MODE}"; \
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${CONF_FILES}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		shift; shift;						\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file c $$egfile ${CONF_FILES_MODE}"; \
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${REQD_FILES}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		shift; shift;						\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file cf $$egfile ${REQD_FILES_MODE}"; \
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${CONF_FILES_PERMS}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		owner="$$3"; group="$$4"; mode="$$5";			\
		shift; shift; shift; shift; shift;			\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file c $$egfile $$mode $$owner $$group"; \
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${REQD_FILES_PERMS}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		egfile="$$1"; file="$$2";				\
		owner="$$3"; group="$$4"; mode="$$5";			\
		shift; shift; shift; shift; shift;			\
		egfile=`strip_prefix "$$egfile"`;			\
		file=`strip_prefix "$$file"`;				\
		${ECHO} "# FILE: $$file cf $$egfile $$mode $$owner $$group"; \
	done
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_FILES_FILE.${_spkg_}}: ${_INSTALL_FILES_DATAFILE.${_spkg_}}
${_INSTALL_FILES_FILE.${_spkg_}}: ../../mk/pkginstall/files
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED.${_spkg_}} ../../mk/pkginstall/files > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_FILES_DATAFILE.${_spkg_}}; then	\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_FILES_FILE}: ${_INSTALL_FILES_DATAFILE}
${_INSTALL_FILES_FILE}: ../../mk/pkginstall/files
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED} ../../mk/pkginstall/files > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_FILES_DATAFILE}; then		\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.endif	# SUBPACKAGES

# OWN_DIRS contains a list of directories for this package that should be
#       created and should attempt to be destroyed by the INSTALL/DEINSTALL
#	scripts.  MAKE_DIRS is used the same way, but the package admin
#	isn't prompted to remove the directory at post-deinstall time if it
#	isn't empty.  REQD_DIRS is like MAKE_DIRS but the value of PKG_CONFIG
#	is ignored; however, all directories listed in REQD_DIRS should
#	be under ${PREFIX}.
#
# For SUBPACKAGES OWN_DIRS, MAKE_DIRS, REQD_DIRS are per-subpackage and
# available as OWN_DIRS.<spkg>, MAKE_DIRS.<spkg>, REQD_DIRS.<spkg>.
#
# OWN_DIRS_PERMS contains a list of "directory owner group mode" sublists
#	representing directories for this package that should be
#	created/destroyed by the INSTALL/DEINSTALL scripts.  MAKE_DIRS_PERMS
#	is used the same way but the package admin isn't prompted to remove
#	the directory at post-deinstall time if it isn't empty.
#	REQD_DIRS_PERMS is like MAKE_DIRS_PERMS but the value of PKG_CONFIG is
#	ignored; however, all directories listed in REQD_DIRS should be
#	under ${PREFIX}.
#
# For SUBPACKAGES OWN_DIRS_PERMS, MAKE_DIRS_PERMS, REQD_DIRS_PERMS are
# per-subpackage and available as OWN_DIRS.<spkg>, MAKE_DIRS.<spkg>,
# REQD_DIRS_PERMS.<spkg>.
#
# PKG_SYSCONFDIR_PERMS contains a list of "owner group mode" for
#	${PKG_SYSCONFDIR}, and only takes effect if PKG_SYSCONFSUBDIR
#	is non-empty.  This is a special case to handle setting
#	special permissions for ${PKG_SYSCONFDIR}, as ${PKG_SYSCONFDIR}
#	is (effectively) automatically added to MAKE_DIRS_PERMS.
#
# For SUBPACKAGES PKG_SYSCONFDIR_PERMS is per-subpackage and available as
# PKG_SYSCONFDIR_PERMS.<spkg>.
#
# If any directory pathnames are relative, then they are taken to be
# relative to ${PREFIX}.
#
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
MAKE_DIRS.${_spkg_}?=		# empty
MAKE_DIRS_PERMS.${_spkg_}?=	# empty
REQD_DIRS.${_spkg_}?=		# empty
REQD_DIRS_PERMS.${_spkg_}?=	# empty
OWN_DIRS.${_spkg_}?=		# empty
OWN_DIRS_PERMS.${_spkg_}?=	# empty
.  endfor
.else	# !SUBPACKAGES
MAKE_DIRS?=		# empty
MAKE_DIRS_PERMS?=	# empty
REQD_DIRS?=		# empty
REQD_DIRS_PERMS?=	# empty
OWN_DIRS?=		# empty
OWN_DIRS_PERMS?=	# empty
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_INSTALL_DIRS_FILE.${_spkg_}=		${_PKGINSTALL_DIR.${_spkg_}}/dirs
_INSTALL_DIRS_DATAFILE.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/dirs-data
_INSTALL_UNPACK_TMPL.${_spkg_}+=	${_INSTALL_DIRS_FILE.${_spkg_}}
_INSTALL_DATA_TMPL.${_spkg_}+=		${_INSTALL_DIRS_DATAFILE.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
_INSTALL_DIRS_FILE=	${_PKGINSTALL_DIR}/dirs
_INSTALL_DIRS_DATAFILE=	${_PKGINSTALL_DIR}/dirs-data
_INSTALL_UNPACK_TMPL+=	${_INSTALL_DIRS_FILE}
_INSTALL_DATA_TMPL+=	${_INSTALL_DIRS_DATAFILE}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_DIRS_DATAFILE.${_spkg_}}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${_FUNC_STRIP_PREFIX};					\
	exec 1>>${.TARGET};						\
	case ${PKG_SYSCONFSUBDIR.${_spkg_}:M*:Q}${CONF_FILES.${_spkg_}:M*:Q}${CONF_FILES_PERMS.${_spkg_}:M*:Q}"" in \
	"")	;;							\
	*)	case ${PKG_SYSCONFSUBDIR.${_spkg_}:M*:Q}"" in			\
		"")	${ECHO} "# DIR: ${PKG_SYSCONFDIR.${_spkg_}:S/${PREFIX}\///} m" ;; \
		*)	set -- dummy ${PKG_SYSCONFDIR.${_spkg_}} ${PKG_SYSCONFDIR_PERMS.${_spkg_}}; shift; \
			while ${TEST} $$# -gt 0; do			\
				dir="$$1"; owner="$$2";			\
				group="$$3"; mode="$$4";		\
				shift; shift; shift; shift;		\
				dir=`strip_prefix "$$dir"`;		\
				${ECHO} "# DIR: $$dir m $$mode $$owner $$group"; \
			done;						\
			;;						\
		esac;							\
		;;							\
	esac
	${RUN}								\
	exec 1>>${.TARGET};						\
	case ${_INSTALL_RCD_SCRIPTS.${_spkg_}:M*:Q}"" in		\
	"")	;;							\
	*)	${ECHO} "# DIR: ${RCD_SCRIPTS_DIR:S/${PREFIX}\///} m" ;; \
	esac
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${MAKE_DIRS.${_spkg_}}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir m";				\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${REQD_DIRS.${_spkg_}}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir fm";				\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${OWN_DIRS.${_spkg_}}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir mo";				\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${MAKE_DIRS_PERMS.${_spkg_}}; shift;		\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir m $$mode $$owner $$group";	\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${REQD_DIRS_PERMS.${_spkg_}}; shift;		\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir fm $$mode $$owner $$group";	\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${OWN_DIRS_PERMS.${_spkg_}}; shift;		\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir mo $$mode $$owner $$group";	\
	done
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_DIRS_DATAFILE}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${_FUNC_STRIP_PREFIX};					\
	exec 1>>${.TARGET};						\
	case ${PKG_SYSCONFSUBDIR:M*:Q}${CONF_FILES:M*:Q}${CONF_FILES_PERMS:M*:Q}"" in \
	"")	;;							\
	*)	case ${PKG_SYSCONFSUBDIR:M*:Q}"" in			\
		"")	${ECHO} "# DIR: ${PKG_SYSCONFDIR:S/${PREFIX}\///} m" ;; \
		*)	set -- dummy ${PKG_SYSCONFDIR} ${PKG_SYSCONFDIR_PERMS}; shift; \
			while ${TEST} $$# -gt 0; do			\
				dir="$$1"; owner="$$2";			\
				group="$$3"; mode="$$4";		\
				shift; shift; shift; shift;		\
				dir=`strip_prefix "$$dir"`;		\
				${ECHO} "# DIR: $$dir m $$mode $$owner $$group"; \
			done;						\
			;;						\
		esac;							\
		;;							\
	esac
	${RUN}								\
	exec 1>>${.TARGET};						\
	case ${_INSTALL_RCD_SCRIPTS:M*:Q}"" in				\
	"")	;;							\
	*)	${ECHO} "# DIR: ${RCD_SCRIPTS_DIR:S/${PREFIX}\///} m" ;; \
	esac
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${MAKE_DIRS}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir m";				\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${REQD_DIRS}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir fm";				\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${OWN_DIRS}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir mo";				\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${MAKE_DIRS_PERMS}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir m $$mode $$owner $$group";	\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${REQD_DIRS_PERMS}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir fm $$mode $$owner $$group";	\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${OWN_DIRS_PERMS}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; owner="$$2"; group="$$3"; mode="$$4";	\
		shift; shift; shift; shift;				\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# DIR: $$dir mo $$mode $$owner $$group";	\
	done
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_DIRS_FILE.${_spkg_}}: ${_INSTALL_DIRS_DATAFILE.${_spkg_}}
${_INSTALL_DIRS_FILE.${_spkg_}}: ../../mk/pkginstall/dirs
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED.${_spkg_}} ../../mk/pkginstall/dirs > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_DIRS_DATAFILE.${_spkg_}}; then	\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_DIRS_FILE}: ${_INSTALL_DIRS_DATAFILE}
${_INSTALL_DIRS_FILE}: ../../mk/pkginstall/dirs
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED} ../../mk/pkginstall/dirs > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_DIRS_DATAFILE}; then		\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.endif	# SUBPACKAGES

# INFO_DIR
#	If defined, specifies the directory path containing the "dir"
#	index file that should be updated.  If the pathname is relative,
#	then it is taken to be relative to ${PREFIX}.  This shouldn't
#	be needed unless "dir" is not in the same directory as the
#	installed info files.
#
# For SUBPACKAGES INFO_DIR is per-subpackage and available as INFO_DIR.<spkg>.
#

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_INSTALL_INFO_FILES_FILE.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/info-files
_INSTALL_INFO_FILES_DATAFILE.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/info-files-data
_INSTALL_UNPACK_TMPL.${_spkg_}+=	${_INSTALL_INFO_FILES_FILE.${_spkg_}}
_INSTALL_DATA_TMPL.${_spkg_}+=		${_INSTALL_INFO_FILES_DATAFILE.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
_INSTALL_INFO_FILES_FILE=	${_PKGINSTALL_DIR}/info-files
_INSTALL_INFO_FILES_DATAFILE=	${_PKGINSTALL_DIR}/info-files-data
_INSTALL_UNPACK_TMPL+=		${_INSTALL_INFO_FILES_FILE}
_INSTALL_DATA_TMPL+=		${_INSTALL_INFO_FILES_DATAFILE}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
.if defined(INFO_FILES.${_spkg_})
USE_TOOLS+=	install-info:run
FILES_SUBST+=	INSTALL_INFO=${INSTALL_INFO:Q}
.endif
.  endfor
.else	# !SUBPACKAGES
.if defined(INFO_FILES)
USE_TOOLS+=	install-info:run
FILES_SUBST+=	INSTALL_INFO=${INSTALL_INFO:Q}
.endif
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_INFO_FILES_DATAFILE.${_spkg_}}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${RM} -f ${.TARGET}
	${RUN}${TOUCH} ${TOUCH_ARGS} ${.TARGET}
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_INFO_FILES_DATAFILE}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${RM} -f ${.TARGET}
	${RUN}${TOUCH} ${TOUCH_ARGS} ${.TARGET}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_INFO_FILES_FILE.${_spkg_}}: ${_INSTALL_INFO_FILES_DATAFILE.${_spkg_}}
${_INSTALL_INFO_FILES_FILE.${_spkg_}}: ../../mk/pkginstall/info-files
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED.${_spkg_}} ../../mk/pkginstall/info-files > ${.TARGET}
.if !defined(INFO_FILES.${_spkg_})
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_INFO_FILES_DATAFILE.${_spkg_}}; then	\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.endif
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_INFO_FILES_FILE}: ${_INSTALL_INFO_FILES_DATAFILE}
${_INSTALL_INFO_FILES_FILE}: ../../mk/pkginstall/info-files
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED} ../../mk/pkginstall/info-files > ${.TARGET}
.if !defined(INFO_FILES)
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_INFO_FILES_DATAFILE}; then	\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi
.endif
.endif	# SUBPACKAGES

.PHONY: install-script-data-info-files
install-script-data: install-script-data-info-files
install-script-data-info-files:
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
.if defined(INFO_FILES.${_spkg_})
	${RUN}${_FUNC_STRIP_PREFIX};					\
	if ${TEST} -x ${INSTALL_FILE}; then				\
		${INFO_FILES_cmd.${_spkg_}} |				\
		while read file; do					\
			infodir=${INFO_DIR.${_spkg_}:Q};		\
			infodir=`strip_prefix "$$infodir"`;		\
			case "$$infodir" in				\
			"")	${ECHO} "# INFO: $$file"		\
					>> ${INSTALL_FILE.${_spkg_}} ;;	\
			*)	${ECHO} "# INFO: $$file $$infodir"	\
					>> ${INSTALL_FILE.${_spkg_}} ;;	\
			esac;						\
		done;							\
		cd ${PKG_DB_TMPDIR} && ${PKGSRC_SETENV} ${INSTALL_SCRIPTS_ENV} \
		${_PKG_DEBUG_SCRIPT} ${INSTALL_FILE.${_spkg_}} ${PKGNAME.${_spkg_}}	\
			UNPACK +INFO_FILES;				\
	fi
.endif
.  endfor
.else	# !SUBPACKAGES
.if defined(INFO_FILES)
	${RUN}${_FUNC_STRIP_PREFIX};					\
	if ${TEST} -x ${INSTALL_FILE}; then				\
		${INFO_FILES_cmd} |					\
		while read file; do					\
			infodir=${INFO_DIR:Q};				\
			infodir=`strip_prefix "$$infodir"`;		\
			case "$$infodir" in				\
			"")	${ECHO} "# INFO: $$file"		\
					>> ${INSTALL_FILE} ;;		\
			*)	${ECHO} "# INFO: $$file $$infodir"	\
					>> ${INSTALL_FILE} ;;		\
			esac;						\
		done;							\
		cd ${PKG_DB_TMPDIR} && ${PKGSRC_SETENV} ${INSTALL_SCRIPTS_ENV} \
		${_PKG_DEBUG_SCRIPT} ${INSTALL_FILE} ${PKGNAME}		\
			UNPACK +INFO_FILES;				\
	fi
.endif
.endif	# SUBPACKAGES

# OCAML_FINDLIB_REGISTER
# XXXleot: Does not support SUBPACKAGES ATM!
_INSTALL_OFR_FILE=	${_PKGINSTALL_DIR}/ocaml-findlib-register
_INSTALL_UNPACK_TMPL+=		${_INSTALL_OFR_FILE}

${_INSTALL_OFR_FILE}: ../../mk/pkginstall/ocaml-findlib-register
	${RUN}${MKDIR} ${.TARGET:H}
.if !empty(OCAML_FINDLIB_REGISTER:M[Yy][Ee][Ss])
	${RUN}${SED} ${FILES_SUBST_SED} \
		../../mk/pkginstall/ocaml-findlib-register > ${.TARGET}
.else
	${RUN}${RM} -f ${.TARGET}; \
	${TOUCH} ${TOUCH_ARGS} ${.TARGET}
.endif

.PHONY: install-script-data-ocaml-findlib-register
install-script-data: install-script-data-ocaml-findlib-register
install-script-data-ocaml-findlib-register:
.if !empty(OCAML_FINDLIB_REGISTER:M[Yy][Ee][Ss])
	${RUN} \
	cd ${PKG_DB_TMPDIR} && ${PKGSRC_SETENV} ${INSTALL_SCRIPTS_ENV} \
	${_PKG_DEBUG_SCRIPT} ${INSTALL_FILE} ${PKGNAME} \
		UNPACK +OCAML_FINDLIB_REGISTER
.endif

# PKG_SHELL contains the pathname of the shell that should be added or
#	removed from the shell database, /etc/shells.  If a pathname
#	is relative, then it is taken to be relative to ${PREFIX}.
#
# XXXleot: This does not support SUBPACKAGES.
#
PKG_SHELL?=		# empty

_INSTALL_SHELL_FILE=		${_PKGINSTALL_DIR}/shell
_INSTALL_SHELL_DATAFILE=	${_PKGINSTALL_DIR}/shell-data
_INSTALL_UNPACK_TMPL+=		${_INSTALL_SHELL_FILE}
_INSTALL_DATA_TMPL+=		${_INSTALL_SHELL_DATAFILE}

${_INSTALL_SHELL_DATAFILE}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${PKG_SHELL}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		shell="$$1"; shift;					\
		shell=`strip_prefix "$$shell"`;				\
		${ECHO} "# SHELL: $$shell";				\
	done

${_INSTALL_SHELL_FILE}: ${_INSTALL_SHELL_DATAFILE}
${_INSTALL_SHELL_FILE}: ../../mk/pkginstall/shell
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED} ../../mk/pkginstall/shell > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_SHELL_DATAFILE}; then		\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi

# LDCONFIG_ADD_CMD
# LDCONFIG_REMOVE_CMD
#	Command-line to be invoked to update the system run-time library
#	search paths database when adding and removing a package.
#
#	Default value: ${LDCONFIG}
#
# XXXleot: This does not support SUBPACKAGES.
#
LDCONFIG_ADD_CMD?=		${_LDCONFIG_ADD_CMD.${OPSYS}}
LDCONFIG_REMOVE_CMD?=		${_LDCONFIG_REMOVE_CMD.${OPSYS}}
_LDCONFIG_ADD_CMD.${OPSYS}?=	${LDCONFIG}
_LDCONFIG_REMOVE_CMD.${OPSYS}?=	${LDCONFIG}
FILES_SUBST+=			LDCONFIG_ADD_CMD=${LDCONFIG_ADD_CMD:Q}
FILES_SUBST+=			LDCONFIG_REMOVE_CMD=${LDCONFIG_REMOVE_CMD:Q}

.if ${SHLIB_TYPE} == "a.out"
RUN_LDCONFIG?=	yes
.else
RUN_LDCONFIG?=	no
.endif

_INSTALL_SHLIBS_FILE=		${_PKGINSTALL_DIR}/shlibs
.if !empty(RUN_LDCONFIG:M[Yy][Ee][Ss])
_INSTALL_UNPACK_TMPL+=		${_INSTALL_SHLIBS_FILE}
.endif

${_INSTALL_SHLIBS_FILE}: ../../mk/pkginstall/shlibs
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED} ../../mk/pkginstall/shlibs > ${.TARGET}

# FONTS_DIRS.<type> are lists of directories in which the font databases
#	are updated.  If this is non-empty, then the appropriate tools are
#	used to update the fonts database for the font type.  The supported
#	types are:
#
#	    ttf		TrueType fonts
#	    type1	Type1 fonts
#	    x11		Generic X fonts, e.g. PCF, SNF, BDF, etc.
#
# XXXleot: This does not support SUBPACKAGES.
#
FONTS_DIRS.ttf?=	# empty
FONTS_DIRS.type1?=	# empty
FONTS_DIRS.x11?=	# empty

_INSTALL_FONTS_FILE=		${_PKGINSTALL_DIR}/fonts
_INSTALL_FONTS_DATAFILE=	${_PKGINSTALL_DIR}/fonts-data
_INSTALL_UNPACK_TMPL+=		${_INSTALL_FONTS_FILE}
_INSTALL_DATA_TMPL+=		${_INSTALL_FONTS_DATAFILE}

# Directories with TTF and Type1 fonts also need to run mkfontdir, so
# list them as "x11" font directories as well.
#
.if !empty(FONTS_DIRS.ttf:M*)
.if ${X11_TYPE} == "modular"
USE_TOOLS+=		mkfontscale:run
FILES_SUBST+=		TTF_INDEX_CMD=${TOOLS_PATH.mkfontscale:Q}
.else
USE_TOOLS+=		ttmkfdir:run
FILES_SUBST+=		TTF_INDEX_CMD=${TOOLS_PATH.ttmkfdir:Q}
.endif
FONTS_DIRS.x11+=	${FONTS_DIRS.ttf}
.endif
.if !empty(FONTS_DIRS.type1:M*)
.if ${X11_TYPE} == "modular"
USE_TOOLS+=		mkfontscale:run
FILES_SUBST+=		TYPE1_INDEX_CMD=${TOOLS_PATH.type1inst:Q}
FILES_SUBST+=		TYPE1_POSTINDEX_CMD=
.else
USE_TOOLS+=		type1inst:run
FILES_SUBST+=		TYPE1_INDEX_CMD=${TOOLS_PATH.type1inst:Q}
FILES_SUBST+=		TYPE1_POSTINDEX_CMD="\$${RM} type1inst.log"
.endif
FONTS_DIRS.x11+=	${FONTS_DIRS.type1}
.endif
.if !empty(FONTS_DIRS.x11:M*)
USE_TOOLS+=		mkfontdir:run
FILES_SUBST+=		MKFONTDIR=${TOOLS_PATH.mkfontdir:Q}

.if ${X11_TYPE} == "modular"
DEPENDS+=		encodings-[0-9]*:../../fonts/encodings
.endif
.endif

FILES_SUBST+=		X11_ENCODINGSDIR=${X11_ENCODINGSDIR:Q}

${_INSTALL_FONTS_DATAFILE}:
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${FONTS_DIRS.ttf}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# FONTS: $$dir ttf";				\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${FONTS_DIRS.type1}; shift;			\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# FONTS: $$dir type1";				\
	done
	${RUN}${_FUNC_STRIP_PREFIX};					\
	set -- dummy ${FONTS_DIRS.x11}; shift;				\
	exec 1>>${.TARGET};						\
	while ${TEST} $$# -gt 0; do					\
		dir="$$1"; shift;					\
		dir=`strip_prefix "$$dir"`;				\
		${ECHO} "# FONTS: $$dir x11";				\
	done

${_INSTALL_FONTS_FILE}: ${_INSTALL_FONTS_DATAFILE}
${_INSTALL_FONTS_FILE}: ../../mk/pkginstall/fonts
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	${SED} ${FILES_SUBST_SED} ../../mk/pkginstall/fonts > ${.TARGET}
	${RUN}								\
	if ${_ZERO_FILESIZE_P} ${_INSTALL_FONTS_DATAFILE}; then		\
		${RM} -f ${.TARGET};					\
		${TOUCH} ${TOUCH_ARGS} ${.TARGET};			\
	fi

# PKG_CREATE_USERGROUP indicates whether the INSTALL script should
#	automatically add any needed users/groups to the system using
#	useradd/groupadd.  It is either YES or NO and defaults to YES.
#
# PKG_CONFIG indicates whether the INSTALL/DEINSTALL scripts should do
#	automatic config file and directory handling, or if it should
#	merely inform the admin of the list of required files and
#	directories needed to use the package.  It is either YES or NO
#	and defaults to YES.
#
# PKG_CONFIG_PERMS indicates whether to automatically correct permissions
#	and ownership on pre-existing files and directories, or if it
#	should merely inform the admin of the list of files and
#	directories whose permissions and ownership need to be fixed.  It
#	is either YES or NO and defaults to NO.
#
# PKG_RCD_SCRIPTS indicates whether to automatically install rc.d scripts
#	to ${RCD_SCRIPTS_DIR}.  It is either YES or NO and defaults to
#	NO.  This variable only takes effect if ${PKG_CONFIG} == "YES".
#
# PKG_REGISTER_SHELLS indicates whether to automatically register shells
#	in /etc/shells.  It is either YES or NO and defaults to YES.
#
# PKG_UPDATE_FONTS_DB indicates whether to automatically update the fonts
#	databases in directories where fonts have been installed or
#	removed.  It is either YES or NO and defaults to YES.
#
# These values merely set the defaults for INSTALL/DEINSTALL scripts, but
# they may be overridden by resetting them in the environment.
#
.if ${PKG_DEVELOPER:Uno} != "no"
FONTS_VERBOSE?=		YES
INFO_FILES_VERBOSE?=	YES
OCAML_FINDLIB_REGISTER_VERBOSE?=	YES
.else
FONTS_VERBOSE?=		NO
INFO_FILES_VERBOSE?=	NO
OCAML_FINDLIB_REGISTER_VERBOSE?=	NO
.endif
PKG_CREATE_USERGROUP?=	YES
PKG_CONFIG?=		YES
PKG_CONFIG_PERMS?=	NO
PKG_RCD_SCRIPTS?=	NO
PKG_REGISTER_SHELLS?=	YES
PKG_UPDATE_FONTS_DB?=	YES
FILES_SUBST+=		PKG_CREATE_USERGROUP=${PKG_CREATE_USERGROUP:Q}
FILES_SUBST+=		PKG_CONFIG=${PKG_CONFIG:Q}
FILES_SUBST+=		PKG_CONFIG_PERMS=${PKG_CONFIG_PERMS:Q}
FILES_SUBST+=		PKG_RCD_SCRIPTS=${PKG_RCD_SCRIPTS:Q}
FILES_SUBST+=		PKG_REGISTER_SHELLS=${PKG_REGISTER_SHELLS:Q}
FILES_SUBST+=		PKG_UPDATE_FONTS_DB=${PKG_UPDATE_FONTS_DB:Q}
FILES_SUBST+=		FONTS_VERBOSE=${FONTS_VERBOSE:Q}
FILES_SUBST+=		INFO_FILES_VERBOSE=${INFO_FILES_VERBOSE:Q}
FILES_SUBST+=		OCAML_FINDLIB_REGISTER_VERBOSE=${OCAML_FINDLIB_REGISTER_VERBOSE:Q}

# Substitute for various programs used in the DEINSTALL/INSTALL scripts and
# in the rc.d scripts.
#
FILES_SUBST+=		AWK=${AWK:Q}
FILES_SUBST+=		BASENAME=${BASENAME:Q}
FILES_SUBST+=		CAT=${CAT:Q}
FILES_SUBST+=		CHGRP=${CHGRP:Q}
FILES_SUBST+=		CHMOD=${CHMOD:Q}
FILES_SUBST+=		CHOWN=${CHOWN:Q}
FILES_SUBST+=		CMP=${CMP:Q}
FILES_SUBST+=		CP=${CP:Q}
FILES_SUBST+=		DIRNAME=${DIRNAME:Q}
FILES_SUBST+=		ECHO=${ECHO:Q}
FILES_SUBST+=		ECHO_N=${ECHO_N:Q}
FILES_SUBST+=		EGREP=${EGREP:Q}
FILES_SUBST+=		EXPR=${EXPR:Q}
FILES_SUBST+=		FALSE=${FALSE:Q}
FILES_SUBST+=		FIND=${FIND:Q}
FILES_SUBST+=		GREP=${GREP:Q}
FILES_SUBST+=		GROUPADD=${GROUPADD:Q}
FILES_SUBST+=		GTAR=${GTAR:Q}
FILES_SUBST+=		HEAD=${HEAD:Q}
FILES_SUBST+=		ID=${ID:Q}
FILES_SUBST+=		INSTALL_INFO=${INSTALL_INFO:Q}
FILES_SUBST+=		LINKFARM=${LINKFARM:Q}
FILES_SUBST+=		LN=${LN:Q}
FILES_SUBST+=		LS=${LS:Q}
FILES_SUBST+=		MKDIR=${MKDIR:Q}
FILES_SUBST+=		MV=${MV:Q}
FILES_SUBST+=		OCAML_FINDLIB_DIRS=${OCAML_FINDLIB_DIRS:Q}
FILES_SUBST+=		OCAML_SITELIBDIR=${OCAML_SITELIBDIR:Q}
FILES_SUBST+=		PERL5=${PERL5:Q}
FILES_SUBST+=		PKG_ADMIN=${PKG_ADMIN_CMD:Q}
FILES_SUBST+=		PKG_INFO=${PKG_INFO_CMD:Q}
FILES_SUBST+=		PW=${PW:Q}
FILES_SUBST+=		PWD_CMD=${PWD_CMD:Q}
FILES_SUBST+=		RM=${RM:Q}
FILES_SUBST+=		RMDIR=${RMDIR:Q}
FILES_SUBST+=		SED=${SED:Q}
FILES_SUBST+=		SETENV=${SETENV:Q}
FILES_SUBST+=		SH=${SH:Q}
FILES_SUBST+=		SORT=${SORT:Q}
FILES_SUBST+=		SU=${SU:Q}
FILES_SUBST+=		TEST=${TEST:Q}
FILES_SUBST+=		TOUCH=${TOUCH:Q}
FILES_SUBST+=		TR=${TR:Q}
FILES_SUBST+=		TRUE=${TRUE:Q}
FILES_SUBST+=		USERADD=${USERADD:Q}
FILES_SUBST+=		XARGS=${XARGS:Q}

FILES_SUBST_SED=	${FILES_SUBST:S/=/@!/:S/$/!g/:S/^/ -e s!@/}

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
FILES_SUBST_SED.${_spkg_}=	${FILES_SUBST_SED} ${FILES_SUBST.${_spkg_}:S/=/@!/:S/$/!g/:S/^/ -e s!@/}
.  endfor
.endif

PKG_REFCOUNT_DBDIR?=	${PKG_DBDIR}.refcount

INSTALL_SCRIPTS_ENV=	PKG_PREFIX=${PREFIX}
INSTALL_SCRIPTS_ENV+=	PKG_REFCOUNT_DBDIR=${PKG_REFCOUNT_DBDIR}

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
INSTALL_SCRIPTS_ENV.${_spkg_}=	${INSTALL_SCRIPTS_ENV}
INSTALL_SCRIPTS_ENV.${_spkg_}+=	PKG_METADATA_DIR=${_PKG_DBDIR}/${PKGNAME.${_spkg_}}
.  endfor
.else	# !SUBPACKAGES
INSTALL_SCRIPTS_ENV+=	PKG_METADATA_DIR=${_PKG_DBDIR}/${PKGNAME}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
DEINSTALL_FILE.${_spkg_}=	${PKG_DB_TMPDIR}/${_spkg_}/+DEINSTALL
INSTALL_FILE.${_spkg_}=		${PKG_DB_TMPDIR}/${_spkg_}/+INSTALL
_DEINSTALL_FILE.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/DEINSTALL
_INSTALL_FILE.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/INSTALL
_DEINSTALL_FILE_DFLT.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/DEINSTALL.default
_INSTALL_FILE_DFLT.${_spkg_}=	${_PKGINSTALL_DIR.${_spkg_}}/INSTALL.default
.  endfor
.else	# !SUBPACKAGES
DEINSTALL_FILE=		${PKG_DB_TMPDIR}/+DEINSTALL
INSTALL_FILE=		${PKG_DB_TMPDIR}/+INSTALL
_DEINSTALL_FILE=	${_PKGINSTALL_DIR}/DEINSTALL
_INSTALL_FILE=		${_PKGINSTALL_DIR}/INSTALL
_DEINSTALL_FILE_DFLT=	${_PKGINSTALL_DIR}/DEINSTALL.default
_INSTALL_FILE_DFLT=	${_PKGINSTALL_DIR}/INSTALL.default
.endif	# SUBPACKAGES

.PHONY: generate-install-scripts
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
generate-install-scripts:						\
		${_DEINSTALL_FILE.${_spkg_}} ${_INSTALL_FILE.${_spkg_}}	\
		${_DEINSTALL_FILE_DFLT.${_spkg_}} ${_INSTALL_FILE_DFLT.${_spkg_}}
.  endfor
generate-install-scripts:
.  for _spkg_ in ${SUBPACKAGES}
.if !exists(${DEINSTALL_FILE.${_spkg_}}) || !exists(${INSTALL_FILE.${_spkg_}})
	${RUN}${MKDIR} ${INSTALL_FILE.${_spkg_}:H}
	${RUN}${MKDIR} ${DEINSTALL_FILE.${_spkg_}:H}
	${RUN}								\
	if ${CMP} -s ${_INSTALL_FILE_DFLT.${_spkg_}:Q} ${_INSTALL_FILE.${_spkg_}:Q}; then	\
		${TRUE};						\
	else								\
		${CP} -f ${_INSTALL_FILE.${_spkg_}} ${INSTALL_FILE.${_spkg_}};		\
		${CP} -f ${_DEINSTALL_FILE.${_spkg_}} ${DEINSTALL_FILE.${_spkg_}};	\
	fi
	${RUN}								\
	if ${CMP} -s ${_DEINSTALL_FILE_DFLT.${_spkg_}:Q} ${_DEINSTALL_FILE.${_spkg_}:Q}; then \
		${TRUE};						\
	else								\
		${CP} -f ${_DEINSTALL_FILE.${_spkg_}} ${DEINSTALL_FILE.${_spkg_}};		\
	fi
.endif
.  endfor
.else	# !SUBPACKAGES
generate-install-scripts:						\
		${_DEINSTALL_FILE} ${_INSTALL_FILE}			\
		${_DEINSTALL_FILE_DFLT} ${_INSTALL_FILE_DFLT}
.if !exists(${DEINSTALL_FILE}) || !exists(${INSTALL_FILE})
	${RUN}${MKDIR} ${INSTALL_FILE:H}
	${RUN}${MKDIR} ${DEINSTALL_FILE:H}
	${RUN}								\
	if ${CMP} -s ${_INSTALL_FILE_DFLT:Q} ${_INSTALL_FILE:Q}; then	\
		${TRUE};						\
	else								\
		${CP} -f ${_INSTALL_FILE} ${INSTALL_FILE};		\
		${CP} -f ${_DEINSTALL_FILE} ${DEINSTALL_FILE};		\
	fi
	${RUN}								\
	if ${CMP} -s ${_DEINSTALL_FILE_DFLT:Q} ${_DEINSTALL_FILE:Q}; then \
		${TRUE};						\
	else								\
		${CP} -f ${_DEINSTALL_FILE} ${DEINSTALL_FILE};		\
	fi
.endif
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_DEINSTALL_FILE_DFLT.${_spkg_}}: ${_DEINSTALL_TEMPLATES_DFLT}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED.${_spkg_}} > ${.TARGET}
	${RUN}${CHMOD} +x ${.TARGET}
.  endfor
.else	# !SUBPACKAGES
${_DEINSTALL_FILE_DFLT}: ${_DEINSTALL_TEMPLATES_DFLT}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED} > ${.TARGET}
	${RUN}${CHMOD} +x ${.TARGET}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_FILE_DFLT.${_spkg_}}: ${_INSTALL_TEMPLATES_DFLT}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED.${_spkg_}} > ${.TARGET}
	${RUN}${CHMOD} +x ${.TARGET}
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_FILE_DFLT}: ${_INSTALL_TEMPLATES_DFLT}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED} > ${.TARGET}
	${RUN}${CHMOD} +x ${.TARGET}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_DEINSTALL_FILE.${_spkg_}}: ${DEINSTALL_SRC.${_spkg_}}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	exec 1>>${.TARGET};						\
	case ${.ALLSRC:Q}"" in						\
	"")	${ECHO} "#!${SH}" ;					\
		${ECHO} "exit 0" ;;					\
	*)	${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED.${_spkg_}} ;;	\
	esac
	${RUN}${CHMOD} +x ${.TARGET}
.  endfor
.else	# !SUBPACKAGES
${_DEINSTALL_FILE}: ${DEINSTALL_SRC}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	exec 1>>${.TARGET};						\
	case ${.ALLSRC:Q}"" in						\
	"")	${ECHO} "#!${SH}" ;					\
		${ECHO} "exit 0" ;;					\
	*)	${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED} ;;	\
	esac
	${RUN}${CHMOD} +x ${.TARGET}
.endif	# SUBPACKAGES

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
${_INSTALL_FILE.${_spkg_}}: ${INSTALL_SRC.${_spkg_}}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	exec 1>>${.TARGET};						\
	case ${.ALLSRC:Q}"" in						\
	"")	${ECHO} "#!${SH}" ;					\
		${ECHO} "exit 0" ;;					\
	*)	${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED.${_spkg_}} ;;	\
	esac
	${RUN}${CHMOD} +x ${.TARGET}
.  endfor
.else	# !SUBPACKAGES
${_INSTALL_FILE}: ${INSTALL_SRC}
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}								\
	exec 1>>${.TARGET};						\
	case ${.ALLSRC:Q}"" in						\
	"")	${ECHO} "#!${SH}" ;					\
		${ECHO} "exit 0" ;;					\
	*)	${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED} ;;	\
	esac
	${RUN}${CHMOD} +x ${.TARGET}
.endif	# SUBPACKAGES

# rc.d scripts are automatically generated and installed into the rc.d
# scripts example directory at the post-install step.  The following
# variables are relevant to this process:
#
# RCD_SCRIPTS			lists the basenames of the rc.d scripts
#
# RCD_SCRIPT_SRC.<script>	the source file for <script>; this will
#				be run through FILES_SUBST to generate
#				the rc.d script (defaults to
#				${FILESDIR}/<script>.sh)
#
# For SUBPACKAGES RCD_SCRIPTS is per-subpackage and available as
# RCD_SCRIPTS.<spkg>.
#
# If the source rc.d script is not present, then the automatic handling
# doesn't occur.
#
# TODOleot: RCD_SCRIPTS should be per-spkg.

.PHONY: generate-rcd-scripts
generate-rcd-scripts:	# do nothing

.PHONY: install-rcd-scripts
post-install: install-rcd-scripts
install-rcd-scripts:	# do nothing

.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
.for _script_ in ${_INSTALL_RCD_SCRIPTS.${_spkg_}}
RCD_SCRIPT_SRC.${_script_}?=	${FILESDIR}/${_script_}.sh
RCD_SCRIPT_WRK.${_script_}?=	${WRKDIR}/.rc.d/${_script_}

.  if !empty(RCD_SCRIPT_SRC.${_script_})
generate-rcd-scripts: ${RCD_SCRIPT_WRK.${_script_}}
${RCD_SCRIPT_WRK.${_script_}}: ${RCD_SCRIPT_SRC.${_script_}}
	@${STEP_MSG} "Creating ${.TARGET}"
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED.${_spkg_}} > ${.TARGET}
	${RUN}${CHMOD} +x ${.TARGET}

install-rcd-scripts: install-rcd-${_script_}
install-rcd-${_script_}: ${RCD_SCRIPT_WRK.${_script_}}
	${RUN}								\
	if [ -f ${RCD_SCRIPT_WRK.${_script_}} ]; then			\
		${MKDIR} ${DESTDIR}${PREFIX}/${RCD_SCRIPTS_EXAMPLEDIR};		\
		${INSTALL_SCRIPT} ${RCD_SCRIPT_WRK.${_script_}}		\
			${DESTDIR}${PREFIX}/${RCD_SCRIPTS_EXAMPLEDIR}/${_script_}; \
	fi
.  endif
GENERATE_PLIST.${_spkg_}+=	${ECHO} ${RCD_SCRIPTS_EXAMPLEDIR}/${_script_};
PRINT_PLIST_AWK+=		/^${RCD_SCRIPTS_EXAMPLEDIR:S|/|\\/|g}\/${_script_}/ { next; }
.endfor
.  endfor
.else	# !SUBPACKAGES
.for _script_ in ${_INSTALL_RCD_SCRIPTS}
RCD_SCRIPT_SRC.${_script_}?=	${FILESDIR}/${_script_}.sh
RCD_SCRIPT_WRK.${_script_}?=	${WRKDIR}/.rc.d/${_script_}

.  if !empty(RCD_SCRIPT_SRC.${_script_})
generate-rcd-scripts: ${RCD_SCRIPT_WRK.${_script_}}
${RCD_SCRIPT_WRK.${_script_}}: ${RCD_SCRIPT_SRC.${_script_}}
	@${STEP_MSG} "Creating ${.TARGET}"
	${RUN}${MKDIR} ${.TARGET:H}
	${RUN}${CAT} ${.ALLSRC} | ${SED} ${FILES_SUBST_SED} > ${.TARGET}
	${RUN}${CHMOD} +x ${.TARGET}

install-rcd-scripts: install-rcd-${_script_}
install-rcd-${_script_}: ${RCD_SCRIPT_WRK.${_script_}}
	${RUN}								\
	if [ -f ${RCD_SCRIPT_WRK.${_script_}} ]; then			\
		${MKDIR} ${DESTDIR}${PREFIX}/${RCD_SCRIPTS_EXAMPLEDIR};		\
		${INSTALL_SCRIPT} ${RCD_SCRIPT_WRK.${_script_}}		\
			${DESTDIR}${PREFIX}/${RCD_SCRIPTS_EXAMPLEDIR}/${_script_}; \
	fi
.  endif
GENERATE_PLIST+=	${ECHO} ${RCD_SCRIPTS_EXAMPLEDIR}/${_script_};
PRINT_PLIST_AWK+=	/^${RCD_SCRIPTS_EXAMPLEDIR:S|/|\\/|g}\/${_script_}/ { next; }
.endfor
.endif	# SUBPACKAGES

_PKGINSTALL_TARGETS+=	acquire-pkginstall-lock
_PKGINSTALL_TARGETS+=	real-pkginstall
_PKGINSTALL_TARGETS+=	release-pkginstall-lock

.PHONY: pkginstall install-script-data
pkginstall: ${_PKGINSTALL_TARGETS}

.PHONY: acquire-pkginstall-lock release-pkginstall-lock
acquire-pkginstall-lock: acquire-lock
release-pkginstall-lock: release-lock

.PHONY: real-pkginstall
real-pkginstall: generate-rcd-scripts generate-install-scripts
