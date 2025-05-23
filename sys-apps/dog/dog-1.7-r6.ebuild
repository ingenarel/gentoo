# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Dog is better than cat"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm64 ~mips ppc ppc64 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos"

PATCHES=(
	"${FILESDIR}"/${P}-check-ctime.diff
	"${FILESDIR}"/${PV}-manpage-touchup.patch
	"${FILESDIR}"/${P}-64bit-goodness.patch
	"${FILESDIR}"/${P}-strfry.patch
	"${FILESDIR}"/${P}-musl-strfry-fix.patch
)

src_prepare() {
	default

	if [[ "${CHOST}" == *-solaris* ]]; then
		sed -i '/gcc.*-o dog/s/$/ -lsocket -lnsl/' \
			Makefile || die "sed Makefile failed"
	fi

	sed -i \
		-e 's,^CFLAGS,#CFLAGS,' \
		-e "s,gcc,$(tc-getCC)," \
		-e 's:-o dog:$(LDFLAGS) -o dog:g' \
		Makefile || die "sed Makefile failed"
}

src_install() {
	dobin "${PN}"
	doman "${PN}.1"
	einstalldocs
}
