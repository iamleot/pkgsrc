# $NetBSD: Makefile,v 1.40 2017/02/12 06:24:47 ryoon Exp $

DISTNAME=	clutter-gst-2.0.12
PKGREVISION=	4
CATEGORIES=	multimedia gnome
MASTER_SITES=	${MASTER_SITE_GNOME:=sources/clutter-gst/2.0/}
EXTRACT_SUFX=	.tar.xz

MAINTAINER=	pkgsrc-users@NetBSD.org
HOMEPAGE=	https://wiki.gnome.org/Projects/Clutter
COMMENT=	Clutter GStreamer integration
LICENSE=	gnu-lgpl-v2.1

GNU_CONFIGURE=	yes
USE_LIBTOOL=	yes
USE_TOOLS+=	gmake pkg-config

PKGCONFIG_OVERRIDE+=	clutter-gst.pc.in

.include "options.mk"

BUILDLINK_API_DEPENDS.clutter+=	clutter>=1.6.0
.include "../../graphics/clutter/buildlink3.mk"
.include "../../graphics/cogl/buildlink3.mk"
BUILDLINK_API_DEPENDS.gstreamer1+=	gstreamer1>=1.2.0
.include "../../multimedia/gstreamer1/buildlink3.mk"
.include "../../multimedia/gst-plugins1-base/buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
