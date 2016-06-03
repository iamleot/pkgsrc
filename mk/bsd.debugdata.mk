#	$NetBSD$
#
# This Makefile fragment is included by bsd.pkg.mk and implements the
# logic needed to strip debug symbols off the program/libraries.
#
# User-settable variables:
#
# PKG_DEBUGDATA
#	If "yes", install stripped debug symbols for all programs and shared
#	libraries.
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
# TODO
#

.endif	# BSD_DEBUGDATA_MK
