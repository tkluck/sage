
EAPI=5
DECRIPTION="grep"
HOMEPAGE=""
SRC_URI="http://ftp.gnu.org/gnu/grep/grep-2.9.tar.gz"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv grep-2.9 src
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

