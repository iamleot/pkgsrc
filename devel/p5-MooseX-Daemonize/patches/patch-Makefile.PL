$NetBSD: patch-Makefile.PL,v 1.3 2016/05/15 09:05:37 wen Exp $

We are not MSWin32, remove this line to avoid import another package.

--- Makefile.PL.orig	2016-05-15 09:00:00.000000000 +0000
+++ Makefile.PL
@@ -1,4 +1,3 @@
-use Devel::AssertOS qw[-MSWin32];
 # This Makefile.PL for MooseX-Daemonize was generated by
 # Dist::Zilla::Plugin::MakeMaker::Fallback 0.021
 # and Dist::Zilla::Plugin::MakeMaker::Awesome 0.35.
