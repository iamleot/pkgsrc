# $NetBSD: Makefile,v 1.15 2016/12/02 23:22:38 wiedi Exp $

DISTNAME=	goaccess-1.1.1
CATEGORIES=	www
MASTER_SITES=	http://tar.goaccess.io/

MAINTAINER=	wiedi@frubar.net
HOMEPAGE=	http://goaccess.prosoftcorp.com/
COMMENT=	Real-time web log analyzer
LICENSE=	gnu-gpl-v2

GNU_CONFIGURE=	yes

USE_TOOLS+=     pkg-config aclocal autoconf automake
USE_NCURSES=	yes

EGDIR=		${PREFIX}/share/examples/${PKGBASE}
CONF_FILES=	${EGDIR}/goaccess.conf ${PKG_SYSCONFDIR}/goaccess.conf

LIBS.SunOS+=	-lsocket -lnsl
CPPFLAGS.SunOS+=	-D__EXTENSIONS__

.include "options.mk"

pre-configure:
	cd ${WRKSRC} && autoreconf -fiv

.include "../../devel/glib2/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
