# $NetBSD: Makefile,v 1.6 2017/03/03 15:44:36 kleink Exp $

DISTNAME=	WeasyPrint-0.36
PKGNAME=	${PYPKGPREFIX}-${DISTNAME:tl}
CATEGORIES=	print python
MASTER_SITES=	${MASTER_SITE_PYPI:=W/WeasyPrint/}

MAINTAINER=	kleink@NetBSD.org
HOMEPAGE=	http://weasyprint.org/
COMMENT=	Converts HTML/CSS documents to PDF
LICENSE=	modified-bsd

USE_LANGUAGES=	# empty

DEPENDS+=	${PYPKGPREFIX}-cairosvg>=1.0.20:../../converters/py-cairosvg
DEPENDS+=	${PYPKGPREFIX}-cairocffi>=0.5:../../graphics/py-cairocffi
DEPENDS+=	${PYPKGPREFIX}-lxml>=3.0:../../textproc/py-lxml
DEPENDS+=	${PYPKGPREFIX}-html5lib>=0.999999999:../../textproc/py-html5lib
DEPENDS+=	${PYPKGPREFIX}-tinycss>=0.4:../../textproc/py-tinycss
DEPENDS+=	${PYPKGPREFIX}-cssselect>=0.6:../../textproc/py-cssselect
DEPENDS+=	${PYPKGPREFIX}-pyphen>=0.8:../../textproc/py-pyphen

.include "../../lang/python/egg.mk"
.include "../../mk/bsd.pkg.mk"
