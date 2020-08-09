# $NetBSD$

EMACSVERSION=	18.59
SNAPSHOTDATE=	20181104
DISTNAME=	${GITHUB_PROJECT}
PKGNAME=	emacs-${EMACSVERSION}pl${SNAPSHOTDATE}
CATEGORIES=	editors
MASTER_SITES=	${MASTER_SITE_GITHUB:=tsutsui/}
GITHUB_PROJECT=	emacs-${EMACSVERSION}-netbsd
GITHUB_TAG=	${SNAPSHOTDATE}

MAINTAINER=	tsutsui@NetBSD.org
HOMEPAGE=	http://www.gnu.org/software/emacs/emacs.html
COMMENT=	GNU editing macros (editor)
LICENSE=	gnu-gpl-v1 AND gnu-gpl-v2 # unexelf.c is pulled from emacs22

CONFLICTS=	emacs19-[0-9]* emacs2[0-9]-[0-9]*
CONFLICTS+=	mule-[0-9]*

WRKSRC=		${WRKDIR}/${GITHUB_PROJECT}-${SNAPSHOTDATE}

USE_TOOLS=	pax
MAKE_JOBS_SAFE=	no

SUBST_CLASSES+=		path
SUBST_MESSAGE.path=	Convert emacs LIBDIR path
SUBST_STAGE.path=	pre-configure
SUBST_VARS.path=	PREFIX VARBASE EMACSVERSION
SUBST_FILES.path=	Makefile src/paths.h-dist

SUBST_CLASSES+=		pref
SUBST_MESSAGE.pref=	Convert /usr/local to ${PREFIX}
SUBST_STAGE.pref=	pre-configure
SUBST_SED.pref=		-e 's,/usr/local,${PREFIX},g'
SUBST_FILES.pref=	Makefile build-install \
			etc/FAQ \
			etc/emacs.1 \
			info/emacs-11 \
			info/emacs-13 \
			lisp/paths.el \
			man/emacs.texi

SUBST_CLASSES+=		x11
SUBST_MESSAGE.x11=	Convert /usr/X11R7 to ${X11BASE}
SUBST_STAGE.x11=	pre-configure
SUBST_SED.x11=		-e 's,/usr/X11R7,${X11BASE},g'
SUBST_FILES.x11=	src/s-netbsd.h

REPLACE_PERL=		etc/faq2texi.perl

# build PATH in the dumped emacs is not a problem
CHECK_WRKREF_SKIP+=	bin/emacs

INSTALLATION_DIRS+=	bin ${PKGMANDIR}/man1 share/emacs/${EMACSVERSION}
MAKE_DIRS+=		${VARBASE}/lock ${VARBASE}/lock/emacs
MAKE_DIRS_PERMS+=	${VARBASE}/lock/emacs \
			${REAL_ROOT_USER} ${REAL_ROOT_GROUP} 1777
BUILD_DEFS+=		VARBASE

do-configure:
	cd ${WRKSRC} && \
	${CP} src/config.h-${LOWER_OPSYS} src/config.h

do-install:
	cd ${WRKSRC} && \
	pax -rwpp -s '/.*\.orig//' etc info lisp \
		${DESTDIR}${PREFIX}/share/emacs/${EMACSVERSION}
	${INSTALL_PROGRAM} ${WRKSRC}/etc/ctags ${DESTDIR}${PREFIX}/bin
	${INSTALL_PROGRAM} ${WRKSRC}/etc/emacsclient ${DESTDIR}${PREFIX}/bin
	${INSTALL_PROGRAM} ${WRKSRC}/etc/etags ${DESTDIR}${PREFIX}/bin
	${INSTALL_PROGRAM} ${WRKSRC}/src/xemacs ${DESTDIR}${PREFIX}/bin/emacs
	${INSTALL_MAN} ${WRKSRC}/etc/emacs.1 ${DESTDIR}${PREFIX}/${PKGMANDIR}/man1

.include "../../mk/x11.buildlink3.mk"
.include "../../mk/bsd.pkg.mk"
