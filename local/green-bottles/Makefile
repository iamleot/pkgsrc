# $NetBSD$

DISTNAME=	green-bottles-0
CATEGORIES=	local
MASTER_SITES=	# empty
DISTFILES=	# empty

MAINTAINER=	leot@NetBSD.org
HOMEPAGE=	http://netbsd.org/~leot/gsoc2016-diary/green-bottles/
COMMENT=	Sing the Ten Green Bottles song
LICENSE=	public-domain

FILESDIR=	${.CURDIR}/../../local/green-bottles/files

WRKSRC=		${WRKDIR}/green-bottles

USE_BSD_MAKEFILE=	yes

INSTALLATION_DIRS=	bin

DEBUGDATA_FILES+=	bin/green-bottles

# XXX: Kludge for the PLIST (this is temporary and should be killed ASAP!)
PLIST_VARS+=	debug
.if !empty(PKG_DEBUGDATA:M[yY][eE][sS])
PLIST.debug=	yes
.endif

do-extract:
	${CP} -r ${FILESDIR}/green-bottles ${WRKDIR}

.include "../../mk/bsd.pkg.mk"
