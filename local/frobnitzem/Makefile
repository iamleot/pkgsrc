# $NetBSD$

SUBPACKAGES=	foo bar baz

DISTNAME=	frobnitzem-0
CATEGORIES=	local
MASTER_SITES=	# empty
DISTFILES=	# empty

PKGNAME.foo=	frobnitzem-foo-0
PKGNAME.bar=	frobnitzem-bar-0
PKGNAME.baz=	frobnitzem-baz-0

MAINTAINER=	leot@NetBSD.org
HOMEPAGE=	http://netbsd.org/~leot/gsoc2017-diary/
COMMENT.foo=	Simple subpackages example (foo)
COMMENT.bar=	Simple subpackages example (bar)
COMMENT.baz=	Simple subpackages example (baz)
LICENSE=	public-domain

FILESDIR=	${.CURDIR}/../../local/frobnitzem/files

WRKSRC=		${WRKDIR}/frobnitzem

NO_BUILD=	yes

PKG_USERS.foo=	foo:foo
PKG_GROUPS.foo=	foo

EGDIR.bar=		${PREFIX}/share/examples/${PKGBASE.bar}
CONF_FILES.bar=		${EGDIR.bar}/bar.conf ${PKG_SYSCONFDIR}/bar.conf

do-extract:
	${CP} -r ${FILESDIR}/frobnitzem ${WRKDIR}

do-install:
	${INSTALL_SCRIPT_DIR} ${DESTDIR}${PREFIX}/bin
	${INSTALL_SCRIPT} ${WRKSRC}/frobnitzem-foo ${DESTDIR}${PREFIX}/bin
	${INSTALL_SCRIPT} ${WRKSRC}/frobnitzem-bar ${DESTDIR}${PREFIX}/bin
	${INSTALL_SCRIPT} ${WRKSRC}/frobnitzem-baz ${DESTDIR}${PREFIX}/bin

post-install:
	${INSTALL_DATA_DIR} ${DESTDIR}${EGDIR.bar}
	${INSTALL_DATA} ${.CURDIR}/files/bar.conf ${DESTDIR}${EGDIR.bar}

.include "../../mk/bsd.pkg.mk"
