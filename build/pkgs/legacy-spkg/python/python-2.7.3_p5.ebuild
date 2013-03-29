
EAPI=5
DECRIPTION="python"
HOMEPAGE=""
SRC_URI="http://dev.gentoo.org/~grobian/distfiles/python-2.7.3-patched.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/zlib
legacy-spkg/readline
legacy-spkg/sqlite
legacy-spkg/libpng"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv python-2.7.3 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        ${SAGE_ROOT}/sage -sh -c ./spkg-install || die
}

