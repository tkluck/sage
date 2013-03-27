
EAPI=5
DECRIPTION="wget"
HOMEPAGE=""
SRC_URI="http://ftp.gnu.org/gnu/wget/wget-1.14.tar.gz"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv wget-1.14 src
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

