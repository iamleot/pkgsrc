# $NetBSD: Makefile,v 1.71 2017/05/03 08:38:43 jperkin Exp $

DISTNAME=	opencv-3.2.0
CATEGORIES=	graphics devel
MASTER_SITES=	${MASTER_SITE_GITHUB:=opencv/}
EXTRACT_SUFX=	.zip

MAINTAINER=	anthony.mallet@laas.fr
HOMEPAGE=	http://opencv.org/
COMMENT=	Library for computer vision problems
LICENSE=	modified-bsd

USE_CMAKE=		yes
USE_LANGUAGES=		c c++11
USE_PKGLOCALEDIR=	yes
USE_TOOLS+=		gmake pkg-config

INSTALLATION_DIRS+=	share/doc/opencv/papers
INSTALLATION_DIRS+=	share/doc/opencv/ref/pics
INSTALLATION_DIRS+=	share/OpenCV/haarcascades

PKGCONFIG_OVERRIDE+=		unix-install/opencv.pc
PKGCONFIG_OVERRIDE_STAGE=	post-configure

PY_PATCHPLIST=		yes
REPLACE_PYTHON+=	samples/python/*.py

# includes configure output and paths to gmake etc.
CHECK_WRKREF_SKIP=	${PREFIX}/lib/libopencv_core.*

.include "options.mk"

CMAKE_ARGS+=		-DPYTHON_EXECUTABLE:FILEPATH=${PYTHONBIN}
CMAKE_ARGS+=		-DZLIB_ROOT=${BUILDLINK_PREFIX.zlib}
CMAKE_ARGS.SunOS+=	-DENABLE_PRECOMPILED_HEADERS=NO
CMAKE_ARGS+=		-DWITH_EIGEN=NO

CONFIGURE_ENV+=		MACHINE_ARCH=${MACHINE_ARCH}

# jasper uses SIZE_MAX and friends in its headers.
CXXFLAGS+=		-D__STDC_LIMIT_MACROS

.include "../../devel/zlib/buildlink3.mk"
.include "../../graphics/jasper/buildlink3.mk"
.include "../../graphics/libwebp/buildlink3.mk"
.include "../../graphics/openexr/buildlink3.mk"
.include "../../graphics/png/buildlink3.mk"
.include "../../graphics/tiff/buildlink3.mk"
.include "../../lang/python/extension.mk"
.include "../../math/py-numpy/buildlink3.mk"
.include "../../mk/jpeg.buildlink3.mk"
.include "../../x11/gtk2/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
