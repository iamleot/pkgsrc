# $NetBSD: Makefile,v 1.14 2017/03/18 19:06:19 schmonz Exp $
#

DISTNAME=		Text-Markdown-Discount-0.11
PKGNAME=		p5-${DISTNAME}
PKGREVISION=		3
CATEGORIES=		textproc perl5
MASTER_SITES=		${MASTER_SITE_PERL_CPAN:=Text/}

MAINTAINER=		schmonz@NetBSD.org
HOMEPAGE=		http://search.cpan.org/dist/Text-Markdown-Discount/
COMMENT=		Convert Markdown to (X)HTML
LICENSE=		${PERL5_LICENSE}

PERL5_PACKLIST=		auto/Text/Markdown/Discount/.packlist
USE_LANGUAGES=		c

MAKE_JOBS_SAFE=		no

.include "../../mk/bsd.prefs.mk"

.if ${OPSYS} == "Darwin"
PKG_CPP=		/usr/bin/cpp
.endif

post-extract:
	cd ${WRKSRC} && mv discount/VERSION discount/MYVERSION

.include "../../lang/perl5/module.mk"
.include "../../mk/bsd.pkg.mk"
