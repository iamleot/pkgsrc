# $NetBSD: Makefile,v 1.8 2017/05/26 13:23:49 mef Exp $

DISTNAME=	Exporter-Tiny-1.000000
PKGNAME=	p5-${DISTNAME}
CATEGORIES=	devel perl5
MASTER_SITES=	${MASTER_SITE_PERL_CPAN:=../../authors/id/T/TO/TOBYINK/}

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://search.cpan.org/dist/Exporter-Tiny/
COMMENT=	Exporter with the features of Sub::Exporter but only core dependencies
LICENSE=	gnu-gpl-v1 OR artistic

USE_LANGUAGES=		# empty
PERL5_PACKLIST=		auto/Exporter/Tiny/.packlist

.include "../../lang/perl5/module.mk"
.include "../../mk/bsd.pkg.mk"
