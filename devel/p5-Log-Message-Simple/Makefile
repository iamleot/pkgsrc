# $NetBSD: Makefile,v 1.4 2016/09/20 12:59:24 wiz Exp $

DISTNAME=	Log-Message-Simple-0.10
PKGNAME=	p5-${DISTNAME}
PKGREVISION=	2
CATEGORIES=	devel
MASTER_SITES=	${MASTER_SITE_PERL_CPAN:=Log/}

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	http://search.cpan.org/CPAN/authors/id/B/BI/BINGOS/
COMMENT=	Simple - Simplified interface to Log::Message
LICENSE=	${PERL5_LICENSE}

BUILD_DEPENDS+=	p5-Log-Message-[0-9]*:../../devel/p5-Log-Message

PERL5_PACKLIST=	auto/Log/Message/Simple/.packlist

.include "../../lang/perl5/module.mk"
.include "../../mk/bsd.pkg.mk"
