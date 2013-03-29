
EAPI=5
DECRIPTION="ecl"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/ecl-12.12.1.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/mpir
legacy-spkg/readline
legacy-spkg/boehm_gc"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv ecl-12.12.1 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        MAKE="${MAKE}" ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c  ./spkg-install || die
}

