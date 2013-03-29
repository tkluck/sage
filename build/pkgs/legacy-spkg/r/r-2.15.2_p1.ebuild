
EAPI=5
DECRIPTION="r"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/r-2.15.2.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/atlas
legacy-spkg/iconv
legacy-spkg/sage_root
legacy-spkg/readline"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv r-2.15.2 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        MAKE="${MAKE}" ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c ./spkg-install || die
}

