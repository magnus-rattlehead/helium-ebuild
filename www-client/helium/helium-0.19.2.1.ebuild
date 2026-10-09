# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Update these pins together with helium-linux's helium-chromium gitlink.
CHROMIUM_VERSION="155.0.8059.39"
HELIUM_COMMIT="9aa23f3cd9e5e6bcb91c8c8029b738e8da2de493"
CLANG_VERSION="llvmorg-24-init-7747-g62397f8b-27"
RUST_VERSION="1edd55dcfcd573872c727fa3e086369a71661ee0-1"
ONBOARDING_VERSION="202609160835"
SEARCH_ICONS_VERSION="202609082320"
UBLOCK_VERSION="1.75.0"
SYSROOT_SHA256="52d61d4446ffebfaa3dda2cd02da4ab4876ff237853f46d273e7f9b666652e1d"
# From Chromium's chrome/build/linux.pgo.txt (also used by Helium --pgo).
PGO_PROFILE="chrome-linux-8059-1790654737-fa9f20771987b93494c8463cdfb6cbeddcba961b-6f91861af1ec1349f48a66f3b3580d769242f7bc.profdata"

CHROMIUM_LANGS="af am ar as az be bg bn bs ca cs cy da de el en-GB es es-419 et eu fa fi fil
	fr fr-CA gl gu he hi hr hu hy id is it ja ka kk km kn ko ky lo lt lv mk ml mn mr ms my
	nb ne nl or pa pl pt-BR pt-PT ro ru si sk sl sq sr sr-Latn sv sw ta te th tr uk ur uz
	vi zh-CN zh-HK zh-TW zu"

PYTHON_COMPAT=(python3_{11..14})
PYTHON_REQ_USE="xml(+)"
LLVM_COMPAT=(21 22 23) # system clang-format only; compiler is always bundled
inherit check-reqs chromium-2 desktop llvm-r1 ninja-utils python-any-r1 xdg

DESCRIPTION="Private, fast, and honest web browser based on Chromium"
HOMEPAGE="https://helium.computer/ https://github.com/imputnet/helium-linux"
SRC_URI="
	https://github.com/chromium-linux-tarballs/chromium-tarballs/releases/download/${CHROMIUM_VERSION}/chromium-${CHROMIUM_VERSION}-linux.tar.xz
	https://github.com/imputnet/helium/archive/${HELIUM_COMMIT}.tar.gz -> helium-${HELIUM_COMMIT}.tar.gz
	https://github.com/imputnet/helium-linux/archive/refs/tags/${PV}.tar.gz -> helium-linux-${PV}.tar.gz
	https://github.com/imputnet/helium-onboarding/releases/download/${ONBOARDING_VERSION}/helium-onboarding-${ONBOARDING_VERSION}.tar.gz
	https://github.com/imputnet/uBlock/releases/download/${UBLOCK_VERSION}/uBlock0_${UBLOCK_VERSION}.chromium.zip -> helium-ublock-${UBLOCK_VERSION}.zip
	https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64/clang-${CLANG_VERSION}.tar.xz -> chromium-clang-${CLANG_VERSION}.tar.xz
	https://commondatastorage.googleapis.com/chromium-browser-clang/Linux_x64/rust-toolchain-${RUST_VERSION}-${CLANG_VERSION%-*}.tar.xz -> chromium-rust-toolchain-${RUST_VERSION:0:10}-${RUST_VERSION##*-}-${CLANG_VERSION%-*}.tar.xz
	https://commondatastorage.googleapis.com/chrome-linux-sysroot/${SYSROOT_SHA256} -> helium-sysroot-${SYSROOT_SHA256:0:16}.tar.xz
	nonfree-search-icons? ( https://github.com/imputnet/helium-nonfree-assets/releases/download/${SEARCH_ICONS_VERSION}/nonfree-search-engines-data-${SEARCH_ICONS_VERSION}.tar.gz )
	pgo? ( https://storage.googleapis.com/chromium-optimization-profiles/pgo_profiles/${PGO_PROFILE} )
"
S="${WORKDIR}/chromium-${CHROMIUM_VERSION}"
HELIUM_WD="${WORKDIR}/helium-${HELIUM_COMMIT}"
HELIUM_LINUX_WD="${WORKDIR}/helium-linux-${PV}"

LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions BSD BSD-2 Base64 Boost-1.0 CC-BY-3.0 CC-BY-4.0 Clear-BSD FFT2D FTL"
LICENSE+=" IJG ISC LGPL-2 LGPL-2.1 MIT MPL-1.1 MPL-2.0 Ms-PL PSF-2 SGI-B-2.0 SSLeay SunSoft Unicode-3.0"
LICENSE+=" Unicode-DFS-2015 Unlicense UoI-NCSA ZLIB libtiff openssl"
LICENSE+=" GPL-3 helium-nonfree-assets"
SLOT="0"
KEYWORDS="~amd64"
IUSE="X +wayland gtk4 cups +pulseaudio +screencast +vaapi qt6 chromedriver pgo nonfree-search-icons"
REQUIRED_USE="|| ( X wayland ) screencast? ( wayland )"
RESTRICT="bindist mirror test"

# Build headers/libraries come from Chromium's pinned sysroot. These packages
# provide the corresponding runtime interfaces on Gentoo.
RDEPEND="
	!www-client/helium-bin
	>=app-accessibility/at-spi2-core-2.46.0:2
	app-misc/ca-certificates
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	>=dev-libs/nss-3.26
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-misc/curl[ssl]
	sys-apps/dbus
	sys-libs/glibc
	sys-libs/libcap
	virtual/udev
	virtual/ttf-fonts
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/libdrm
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
	gtk4? ( gui-libs/gtk:4[X?,wayland?] )
	!gtk4? ( x11-libs/gtk+:3[X?,wayland?] )
	pulseaudio? ( media-libs/libpulse )
	cups? ( net-print/cups )
	qt6? ( dev-qt/qtbase:6[gui,widgets,X?,wayland?] )
	screencast? ( media-video/pipewire sys-apps/xdg-desktop-portal )
	vaapi? ( media-libs/libva )
	wayland? ( dev-libs/wayland )
	X? (
	 x11-libs/libX11 x11-libs/libxcb x11-libs/libXcomposite
	 x11-libs/libXdamage x11-libs/libXext x11-libs/libXfixes
	 x11-libs/libXrandr x11-libs/libxshmfence
	)
"
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_any_dep 'dev-python/setuptools[${PYTHON_USEDEP}] dev-python/pillow[${PYTHON_USEDEP}]')
	$(llvm_gen_dep 'llvm-core/clang:${LLVM_SLOT}')
	>=net-libs/nodejs-24.12.0[inspector]
	>=dev-lang/go-1.26.6
	>=dev-util/gperf-3.2
	app-alternatives/ninja
	app-arch/unzip
	dev-lang/perl
	dev-vcs/git
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"

python_check_deps() {
	python_has_version "dev-python/setuptools[${PYTHON_USEDEP}]" &&
		python_has_version "dev-python/pillow[${PYTHON_USEDEP}]"
}

pkg_pretend() {
	CHECKREQS_MEMORY="9G"
	CHECKREQS_DISK_BUILD="40G"
	check-reqs_pkg_pretend
}

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_unpack() {
	unpack chromium-${CHROMIUM_VERSION}-linux.tar.xz
	unpack helium-${HELIUM_COMMIT}.tar.gz helium-linux-${PV}.tar.gz
	mkdir -p "${WORKDIR}/clang" "${WORKDIR}/rust-toolchain" \
		"${S}/components/helium_onboarding" "${T}/ublock" \
		"${S}/build/linux/debian_bullseye_amd64-sysroot" || die
	tar xf "${DISTDIR}/chromium-clang-${CLANG_VERSION}.tar.xz" -C "${WORKDIR}/clang" || die
	tar xf "${DISTDIR}/chromium-rust-toolchain-${RUST_VERSION:0:10}-${RUST_VERSION##*-}-${CLANG_VERSION%-*}.tar.xz" \
		-C "${WORKDIR}/rust-toolchain" || die
	tar xf "${DISTDIR}/helium-sysroot-${SYSROOT_SHA256:0:16}.tar.xz" \
		-C "${S}/build/linux/debian_bullseye_amd64-sysroot" || die
	tar xf "${DISTDIR}/helium-onboarding-${ONBOARDING_VERSION}.tar.gz" \
		-C "${S}/components/helium_onboarding" || die
	if use nonfree-search-icons; then
		mkdir -p "${S}/third_party/search_engines_data/resources_internal" || die
		tar xf "${DISTDIR}/nonfree-search-engines-data-${SEARCH_ICONS_VERSION}.tar.gz" \
			-C "${S}/third_party/search_engines_data/resources_internal" || die
	fi
	unzip -q "${DISTDIR}/helium-ublock-${UBLOCK_VERSION}.zip" -d "${T}/ublock" || die
	mv "${T}/ublock/uBlock0.chromium" "${S}/third_party/ublock" || die
}

src_prepare() {
	python_setup
	# Apply only Helium's own patch series
	if ! use nonfree-search-icons; then
		sed -i '\|helium/core/search/fix-search-engine-icons.patch|d' "${HELIUM_WD}/patches/series" || die
	fi
	"${EPYTHON}" "${HELIUM_WD}/utils/patches.py" apply . \
		"${HELIUM_WD}/patches" "${HELIUM_LINUX_WD}/patches" || die
	"${EPYTHON}" "${HELIUM_WD}/utils/domain_substitution.py" apply \
		-r "${HELIUM_WD}/domain_regex.list" -f "${HELIUM_WD}/domain_substitution.list" . || die
	"${EPYTHON}" "${HELIUM_WD}/utils/name_substitution.py" --sub \
		-t "${S}" --backup-path "${T}/namesubs.tar" || die
	"${EPYTHON}" "${HELIUM_WD}/utils/i18n_apply.py" -t "${S}" || die
	"${EPYTHON}" "${HELIUM_WD}/utils/helium_version.py" --tree "${HELIUM_WD}" \
		--platform-tree "${HELIUM_LINUX_WD}" --chromium-tree "${S}" || die
	"${EPYTHON}" "${HELIUM_WD}/utils/generate_resources.py" \
		"${HELIUM_WD}/resources/generate_resources.txt" "${HELIUM_WD}/resources" || die
	"${EPYTHON}" "${HELIUM_WD}/utils/replace_resources.py" \
		"${HELIUM_WD}/resources/helium_resources.txt" "${HELIUM_WD}/resources" "${S}" || die
	eapply_user

	# These are the same system-tool substitutions made by upstream setup_toolchain.
	local src dst
	local -A tools=(
		["${BROOT}/usr/bin/node"]="third_party/node/linux/node-linux-x64/bin/node"
		["${BROOT}/usr/bin/gperf"]="third_party/gperf/cipd/bin/gperf"
		["$(get_llvm_prefix -b)/bin/clang-format"]="buildtools/linux64-format/clang-format"
	)
	for src in "${!tools[@]}"; do
		dst=${tools[${src}]}
		[[ -x ${src} ]] || die "Missing build tool ${src}"
		mkdir -p "${dst%/*}" || die
		rm -f "${dst}" || die
		ln -s "${src}" "${dst}" || die
	done
	# The full source tarball omits Dawn's Go SDK. Supply the compatible system SDK
	# at its upstream path, avoids patching Dawn.
	local goroot
	goroot=$(GOTOOLCHAIN=local go env GOROOT) || die
	[[ -x ${goroot}/bin/go ]] || die "Missing system Go SDK"
	mkdir -p third_party/dawn/tools/golang third_party/llvm-build || die
	rm -rf third_party/dawn/tools/golang/linux-amd64 \
		third_party/llvm-build/Release+Asserts third_party/rust-toolchain || die
	ln -s "${goroot}" third_party/dawn/tools/golang/linux-amd64 || die
	ln -s "${WORKDIR}/clang" third_party/llvm-build/Release+Asserts || die
	ln -s "${WORKDIR}/rust-toolchain" third_party/rust-toolchain || die
	cp "${WORKDIR}/rust-toolchain/VERSION" "${WORKDIR}/rust-toolchain/INSTALLED_VERSION" || die
	sed -i -e "s|^script_executable = .*|script_executable = \"${EPYTHON}\"|" .gn || die
}

src_configure() {
	python_setup
	if use pgo; then
		[[ $(<chrome/build/linux.pgo.txt) == "${PGO_PROFILE}" ]] ||
			die "PGO profile pin does not match this Chromium release"
		mkdir -p chrome/build/pgo_profiles || die
		cp "${DISTDIR}/${PGO_PROFILE}" chrome/build/pgo_profiles/ || die
	fi
	mkdir -p out/Release || die
	cat "${HELIUM_WD}/flags.gn" "${HELIUM_LINUX_WD}/flags.linux.gn" >out/Release/args.gn || die
	# overrides
	cat >>out/Release/args.gn <<-EOF
		target_cpu = "x64"
		v8_target_cpu = "x64"
		chrome_pgo_phase = $(usex pgo 2 0)
		use_siso = false
		use_remoteexec = false
		symbol_level = 0
		use_thin_lto = true
		thin_lto_enable_optimizations = true
		optimize_webui = true
		ozone_auto_platforms = false
		ozone_platform = "$(usex wayland wayland x11)"
		ozone_platform_headless = true
		ozone_platform_x11 = $(usex X true false)
		ozone_platform_wayland = $(usex wayland true false)
		use_pulseaudio = $(usex pulseaudio true false)
		rtc_use_pipewire = $(usex screencast true false)
		use_vaapi = $(usex vaapi true false)
		use_cups = $(usex cups true false)
		use_qt5 = false
		use_qt6 = $(usex qt6 true false)
	EOF
	if has ccache ${FEATURES}; then
		echo 'cc_wrapper = "ccache"' >>out/Release/args.gn || die
	fi
	buildtools/linux64/gn gen out/Release --fail-on-unused-args || die
}

src_compile() {
	python_setup
	export GOCACHE="${T}/go-cache" GOPATH="${T}/go" GOPROXY=off GOTOOLCHAIN=local
	local -x PYTHONPATH=
	ulimit -n 4096 || die
	eninja -C out/Release chrome chrome_sandbox $(usex chromedriver chromedriver '')
}

src_install() {
	local home_dir="/usr/$(get_libdir)/helium"
	exeinto "${home_dir}"
	doexe out/Release/helium out/Release/helium_crashpad_handler
	newexe out/Release/chrome_sandbox chrome-sandbox
	fperms 4755 "${home_dir}/chrome-sandbox"
	dosym helium "${home_dir}/chrome"
	if use chromedriver; then
		doexe out/Release/chromedriver
		dosym "${home_dir}/chromedriver" /usr/bin/helium-chromedriver
	fi
	# Upstream builds with GTK3 headers and dynamically loads either GTK ABI.
	sed -e "s|@HELIUM_HOME@|${EPREFIX}${home_dir}|g" \
		-e "s|@GTK_VERSION@|$(usex gtk4 4 3)|g" "${FILESDIR}/helium" >"${T}/helium" || die
	dobin "${T}/helium"
	pushd out/Release/locales >/dev/null || die
	chromium_remove_language_paks
	popd >/dev/null || die
	insinto "${home_dir}"
	doins out/Release/*.bin out/Release/*.pak out/Release/icudtl.dat
	doins -r out/Release/locales
	local f
	for f in out/Release/*.so out/Release/*.so.[0-9] out/Release/vk_swiftshader_icd.json; do
		[[ -e ${f} ]] && doins "${f}"
	done
	[[ -d out/Release/hyphen-data ]] && doins -r out/Release/hyphen-data
	# Managed-storage schemas are read from disk
	insinto "${home_dir}/resources/ublock"
	doins third_party/ublock/managed_storage.json
	newicon -s 256 chrome/app/theme/chromium/product_logo_256.png helium.png
	domenu "${FILESDIR}/helium.desktop"
	insinto /etc/helium
	newins "${FILESDIR}/helium.default" default
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Extra arguments: /etc/helium/default or ~/.config/helium-flags.conf"
}
