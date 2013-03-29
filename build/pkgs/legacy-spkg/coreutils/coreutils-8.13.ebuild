
EAPI=5
DECRIPTION="coreutils"
HOMEPAGE=""
SRC_URI="http://ftp.gnu.org/gnu/coreutils/coreutils-8.13.tar.gz"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv coreutils-8.13 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        MAKE=${MAKE} ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c ./spkg-install || die
}

