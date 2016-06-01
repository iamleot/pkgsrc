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
