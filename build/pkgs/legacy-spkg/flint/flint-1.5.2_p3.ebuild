
EAPI=5
DECRIPTION="flint"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/flint-1.5.2.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/mpir
legacy-spkg/ntl"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv flint-1.5.2 src
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

