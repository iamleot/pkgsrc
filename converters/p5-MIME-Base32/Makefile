# $NetBSD: Makefile,v 1.14 2017/05/23 00:37:03 schmonz Exp $

DISTNAME=	MIME-Base32-1.303
PKGNAME=	p5-${DISTNAME}
CATEGORIES=	converters perl5
MASTER_SITES=	${MASTER_SITE_PERL_CPAN:=MIME/}

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://search.cpan.org/dist/MIME-Base32/
COMMENT=	Perl5 module for Base32 encoding
LICENSE=	${PERL5_LICENSE}

PERL5_PACKLIST=		auto/MIME/Base32/.packlist

.include "../../lang/perl5/module.mk"
.include "../../mk/bsd.pkg.mk"
