
EAPI=5
DECRIPTION="scipy"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/scipy-0.11.0.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/lapack
legacy-spkg/blas
legacy-spkg/numpy"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv scipy-0.11.0 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c ./spkg-install || die
}

