
EAPI=5
DECRIPTION="make"
HOMEPAGE=""
SRC_URI="http://ftp.gnu.org/gnu/make/make-3.82.tar.gz"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv make-3.82 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c  ./spkg-install || die
}

