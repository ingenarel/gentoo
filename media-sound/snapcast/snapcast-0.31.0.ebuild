# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit edo cmake

DESCRIPTION="Synchronous multi-room audio player"
HOMEPAGE="https://github.com/badaix/snapcast"
SRC_URI="https://github.com/badaix/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64 ~arm ppc ppc64 ~riscv x86"
IUSE="+client +expat +flac jack +opus +server test tremor +vorbis +zeroconf"
REQUIRED_USE="|| ( server client )"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/boost:=
	dev-libs/openssl:=
	media-libs/alsa-lib
	client? ( acct-user/snapclient )
	expat? ( dev-libs/expat )
	flac? ( media-libs/flac:= )
	jack? ( virtual/jack )
	opus? ( media-libs/opus )
	server? (
		acct-group/snapserver
		acct-user/snapserver
	)
	tremor? ( media-libs/tremor )
	vorbis? ( media-libs/libvorbis )
	zeroconf? ( net-dns/avahi[dbus] )
"
DEPEND="
	${RDEPEND}
	>=dev-cpp/aixlog-1.2.1
	>=dev-cpp/asio-1.12.1
	>=dev-cpp/popl-1.2.0
	test? ( >=dev-cpp/catch-3:0 )
"

PATCHES=(
	"${FILESDIR}"/${PN}-0.31.0-boost-1.88.patch
	"${FILESDIR}"/${PN}-0.31.0-drop-lint.patch
	"${FILESDIR}"/${PN}-0.31.0-boost-1.88-fixup.patch
)

src_configure() {
	local mycmakeargs=(
		-DBUILD_CLIENT=$(usex client)
		-DBUILD_WITH_EXPAT=$(usex expat)
		-DBUILD_WITH_FLAC=$(usex flac)
		-DBUILD_WITH_JACK=$(usex jack)
		-DBUILD_WITH_OPUS=$(usex opus)
		-DBUILD_SERVER=$(usex server)
		-DBUILD_STATIC_LIBS=no
		-DBUILD_TESTS=$(usex test)
		-DBUILD_WITH_TREMOR=$(usex tremor)
		-DBUILD_WITH_VORBIS=$(usex vorbis)
		-DBUILD_WITH_AVAHI=$(usex zeroconf)
		-DCMAKE_INSTALL_SYSCONFDIR="${EPREFIX}/etc"
	)

	cmake_src_configure
}

src_test() {
	cmake_src_test
	edo "${S}"/bin/snapcast_test
}

src_install() {
	cmake_src_install

	for bin in server client ; do
		if use ${bin} ; then
			doman "${bin}/snap${bin}.1"

			newconfd "${FILESDIR}/snap${bin}.confd" "snap${bin}"
			newinitd "${FILESDIR}/snap${bin}.initd" "snap${bin}"
		fi
	done
}
