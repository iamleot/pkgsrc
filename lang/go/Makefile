# $NetBSD: Makefile,v 1.52 2017/05/25 09:06:43 bsiegert Exp $

.include "version.mk"

DISTNAME=	go${GO_VERSION}.src
PKGNAME=	go-${GO_VERSION}
CATEGORIES=	lang
MASTER_SITES=	https://storage.googleapis.com/golang/

MAINTAINER=	bsiegert@NetBSD.org
HOMEPAGE=	http://golang.org/
COMMENT=	The Go programming language
LICENSE=	modified-bsd

WRKSRC=		${WRKDIR}/go
USE_TOOLS+=	bash:run perl:run pax

# uses ulimit -T
# BUILD_DEPENDS+=	bash>=4.2nb3:../../shells/bash

# cgo compiles under TMPDIR
TMPDIR?=	/tmp
BUILDLINK_PASSTHRU_DIRS+= ${TMPDIR}

GOROOT_FINAL=	${PREFIX}/go
INSTALLATION_DIRS= bin

REPLACE_BASH+=	doc/articles/wiki/test.bash
REPLACE_BASH+=	doc/codewalk/run
REPLACE_BASH+=	lib/time/update.bash
REPLACE_BASH+=	misc/arm/a
REPLACE_BASH+=	misc/benchcmp
REPLACE_BASH+=	misc/cgo/errors/test.bash
REPLACE_BASH+=	misc/cgo/fortran/test.bash
REPLACE_BASH+=	misc/cgo/testcarchive/test.bash
REPLACE_BASH+=	misc/cgo/testcshared/test.bash
REPLACE_BASH+=	misc/cgo/testgodefs/test.bash
REPLACE_BASH+=	misc/cgo/testplugin/test.bash
REPLACE_BASH+=	misc/cgo/testsanitizers/test.bash
REPLACE_BASH+=	misc/nacl/go_nacl_386_exec
REPLACE_BASH+=	misc/nacl/go_nacl_amd64p32_exec
REPLACE_BASH+=	misc/nacl/go_nacl_arm_exec
REPLACE_BASH+=	src/all.bash
REPLACE_BASH+=	src/androidtest.bash
REPLACE_BASH+=	src/bootstrap.bash
REPLACE_BASH+=	src/buildall.bash
REPLACE_BASH+=	src/clean.bash
REPLACE_BASH+=	src/cmd/compile/internal/big/vendor.bash
REPLACE_BASH+=	src/cmd/dist/mkdeps.bash
REPLACE_BASH+=	src/cmd/go/mkalldocs.sh
REPLACE_BASH+=	src/internal/trace/mkcanned.bash
REPLACE_BASH+=	src/iostest.bash
REPLACE_BASH+=	src/make.bash
REPLACE_BASH+=	src/naclmake.bash
REPLACE_BASH+=	src/nacltest.bash
REPLACE_BASH+=	src/race.bash
REPLACE_BASH+=	src/run.bash
REPLACE_BASH+=	src/runtime/mknacl.sh
REPLACE_BASH+=	src/syscall/mkall.sh
REPLACE_BASH+=	src/syscall/mkerrors.sh
REPLACE_BASH+=	src/syscall/mksysnum_plan9.sh

REPLACE_PERL+=	src/net/http/cgi/testdata/test.cgi
REPLACE_PERL+=	src/regexp/syntax/make_perl_groups.pl
REPLACE_PERL+=	src/syscall/*.pl
REPLACE_PERL+=	test/errchk

# uses /bin/rc (for Plan 9)
CHECK_INTERPRETER_SKIP+=	go/include/plan9/mklibc.rc
CHECK_INTERPRETER_SKIP+=	go/src/all.rc
CHECK_INTERPRETER_SKIP+=	go/src/clean.rc
CHECK_INTERPRETER_SKIP+=	go/src/make.rc
CHECK_INTERPRETER_SKIP+=	go/src/run.rc

BUILD_DEPENDS+=		go14-1.4*:../../lang/go14
GOROOT_BOOTSTRAP=	${PREFIX}/go14

.include "../../mk/bsd.prefs.mk"

PLIST_VARS+=	route

.if ${OPSYS} != "Linux" && ${OPSYS} != "SunOS"
PLIST.route=	yes
.endif

do-build:
	cd ${WRKSRC}/src && env GOROOT_BOOTSTRAP=${GOROOT_BOOTSTRAP:Q} GOROOT_FINAL=${GOROOT_FINAL:Q} ${BASH} ./make.bash

do-install:
	cd ${WRKSRC} && rm -rf .hgignore .hgtags pkg/obj
	cd ${WRKDIR} && pax -rw go ${DESTDIR}${PREFIX}
	find ${DESTDIR}${PREFIX}/go -name \*.orig -exec rm {} \;
.for cmd in go gofmt
	cd ${DESTDIR}${PREFIX}/bin && ln -sf ../go/bin/${cmd} ${cmd}
.endfor

do-test:
	cd ${WRKSRC}/src && GOROOT=${WRKSRC} PATH=${WRKSRC}/bin:${PATH} ${BASH} run.bash --no-rebuild --banner ""

.include "../../mk/bsd.pkg.mk"
