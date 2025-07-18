# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DIST_AUTHOR=XAOC
DIST_VERSION=0.038
inherit perl-module virtualx

DESCRIPTION="Perl interface to the 3.x series of the gtk+ toolkit"
LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~hppa ppc ppc64 ~riscv x86"

RDEPEND="
	x11-libs/gtk+:3[introspection]
	>=dev-perl/Cairo-GObject-1.0.0
	>=dev-perl/Glib-Object-Introspection-0.43.0

"
DEPEND="${RDEPEND}
"
BDEPEND="${RDEPEND}
	>=virtual/perl-ExtUtils-MakeMaker-6.30
	test? (
		>=virtual/perl-Test-Simple-0.960.0
	)
"

src_test() {
	virtx perl-module_src_test
}
