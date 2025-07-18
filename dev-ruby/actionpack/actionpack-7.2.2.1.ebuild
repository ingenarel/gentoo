# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby32 ruby33 ruby34"

RUBY_FAKEGEM_RECIPE_DOC="none"
RUBY_FAKEGEM_DOCDIR="doc"
RUBY_FAKEGEM_EXTRADOC="CHANGELOG.md README.rdoc"

RUBY_FAKEGEM_GEMSPEC="actionpack.gemspec"

RUBY_FAKEGEM_BINWRAP=""

inherit ruby-fakegem

DESCRIPTION="Eases web-request routing, handling, and response"
HOMEPAGE="https://github.com/rails/rails"
SRC_URI="https://github.com/rails/rails/archive/v${PV}.tar.gz -> rails-${PV}.tgz"

LICENSE="MIT"
SLOT="$(ver_cut 1-2)"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~riscv ~sparc ~x86"
IUSE="test"

RUBY_S="rails-${PV}/${PN}"

ruby_add_rdepend "
	~dev-ruby/actionview-${PV}
	~dev-ruby/activesupport-${PV}
	>=dev-ruby/nokogiri-1.8.5
	dev-ruby/racc
	|| ( dev-ruby/rack:3.1 dev-ruby/rack:3.0 >=dev-ruby/rack-2.2.4:2.2 )
	>=dev-ruby/rack-session-1.0.1
	>=dev-ruby/rack-test-0.6.3:*
	>=dev-ruby/rails-dom-testing-2.2:2
	>=dev-ruby/rails-html-sanitizer-1.6:1
	>=dev-ruby/useragent-0.16:0
"

ruby_add_bdepend "
	test? (
		dev-ruby/mocha
		dev-ruby/bundler
		>=dev-ruby/capybara-3.26
		~dev-ruby/activemodel-${PV}
		~dev-ruby/railties-${PV}
		>=dev-ruby/rack-cache-1.2:1.2
		dev-ruby/selenium-webdriver:4
		www-servers/puma
		dev-ruby/minitest:5
	)"

all_ruby_prepare() {
	# Remove items from the common Gemfile that we don't need for this
	# test run. This also requires handling some gemspecs.
	sed -i -e "/\(system_timer\|sdoc\|w3c_validators\|pg\|execjs\|jquery-rails\|'mysql'\|journey\|ruby-prof\|stackprof\|benchmark-ips\|kindlerb\|turbolinks\|coffee-rails\|debugger\|sprockets-rails\|redcarpet\|bcrypt\|uglifier\|sprockets\|stackprof\)/ s:^:#:" \
		-e '/:job/,/end/ s:^:#:' \
		-e '/group :doc/,/^end/ s:^:#:' ../Gemfile || die
	rm ../Gemfile.lock || die

	# Fix errors loading rack/session with rack 3.0 and use correct rails version.
	sed -e '2igem "rack-session"; gem "railties", "~> 7.2.0"; gem "activemodel", "~> 7.2.0"' \
		-i test/abstract_unit.rb || die

	# Use different timezone notation, this changed at some point due to an external dependency changing.
	sed -e 's/-0000/GMT/' \
		-i test/dispatch/response_test.rb test/dispatch/cookies_test.rb test/dispatch/session/cookie_store_test.rb || die

	# Avoid tests that fail with a fixed cgi.rb version
	sed -e '/test_session_store_with_all_domains/askip "Fails with fixed cgi.rb"' \
		-i test/dispatch/session/cookie_store_test.rb || die

	# Avoid tests failing with rails-dom-testing 2.3 (fixed upstream)
	sed -e '/test_preserves_order_when_reading_from_cache_plus_rendering/askip "Fails with rails-dom-testing 2.3"' \
		-i test/controller/caching_test.rb || die

	# Avoid tests requiring chrome
	sed -e '/DrivenBySeleniumWith/,/^end/ s:^:#:' \
		-i test/abstract_unit.rb || die
	rm -f test/dispatch/system_testing/{driver,screenshot_helper,system_test_case}_test.rb || die
}
