
EAPI=5
DECRIPTION="coreutils"
HOMEPAGE=""
SRC_URI="http://ftp.gnu.org/gnu/coreutils/coreutils-8.21.tar.xz"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv coreutils-8.21 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        SAGE_LOCAL="${EPREFIX}" ./spkg-install || die
}

