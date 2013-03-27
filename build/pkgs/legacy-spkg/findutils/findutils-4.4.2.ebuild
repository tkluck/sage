
EAPI=5
DECRIPTION="findutils"
HOMEPAGE=""
SRC_URI="http://ftp.gnu.org/pub/gnu/findutils/findutils-4.4.2.tar.gz"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv findutils-4.4.2 src
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

