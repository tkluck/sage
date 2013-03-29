
EAPI=5
DECRIPTION="lrcalc"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/lrcalc-1.1.6.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv lrcalc-1.1.6 src
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

