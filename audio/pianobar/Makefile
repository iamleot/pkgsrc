# $NetBSD: Makefile,v 1.7 2017/04/30 01:21:28 ryoon Exp $

DISTNAME=	pianobar-2015.11.22
PKGREVISION=	6
CATEGORIES=	audio net
MASTER_SITES=	https://6xq.net/pianobar/
EXTRACT_SUFX=	.tar.bz2

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	https://6xq.net/pianobar/
COMMENT=	Console client for Pandora
LICENSE=	mit

USE_TOOLS+=	gmake pkg-config
USE_LANGUAGES=	c99
MAKE_FLAGS+=	PREFIX=${PREFIX}
MAKE_FLAGS+=	MANDIR=${PREFIX}/${PKGMANDIR}

.include "../../audio/libao/buildlink3.mk"
.include "../../security/libgcrypt/buildlink3.mk"
.include "../../www/curl/buildlink3.mk"
.include "../../textproc/json-c/buildlink3.mk"
.include "../../multimedia/ffmpeg2/buildlink3.mk"
.include "../../mk/pthread.buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
