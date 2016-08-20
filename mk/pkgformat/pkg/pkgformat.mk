# $NetBSD: pkgformat.mk,v 1.3 2016/04/10 15:58:03 joerg Exp $
#
# This Makefile fragment provides variable and target overrides that are
# specific to the pkgsrc native package format.
#

# PKG_FILELIST_CMD outputs the list of files in the package based on
# _DEPENDS_PLIST.
#
.if !empty(SUBPACKAGES)
.  for _spkg_ in ${SUBPACKAGES}
_DEPENDS_PLISTS+=	${_DEPENDS_PLIST.${_spkg_}}
.  endfor
PKG_FILELIST_CMD=	${SED} -e "/^@/d" -e "s|^|${PREFIX}/|" ${_DEPENDS_PLISTS}
.else	# !SUBPACKAGES
PKG_FILELIST_CMD=	${SED} -e "/^@/d" -e "s|^|${PREFIX}/|" ${_DEPENDS_PLIST}
.endif	# SUBPACKAGES

.include "depends.mk"
.include "check.mk"
.include "metadata.mk"
.include "install.mk"
.include "deinstall.mk"
.include "replace.mk"
.include "package.mk"

.include "utility.mk"
