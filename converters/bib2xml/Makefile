# $NetBSD: Makefile,v 1.14 2013/04/27 23:05:50 joerg Exp $
#

DISTNAME=	bib2xml-10062002
PKGNAME=	${DISTNAME:C/-(....)(....)/-\2\1/}
PKGREVISION=	1
CATEGORIES=	converters textproc
MASTER_SITES=	http://www-plan.cs.colorado.edu/henkel/stuff/bib2xml/

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://www-plan.cs.colorado.edu/henkel/stuff/bib2xml/
COMMENT=	BibTeX to XML converter

WRKSRC=		${WRKDIR}/bib2xml
GNU_CONFIGURE=	YES
BUILD_DIRS=	progs

INSTALLATION_DIRS=	bin

do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/progs/bib2xml ${DESTDIR}${PREFIX}/bin

.include "../../textproc/btparse/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
