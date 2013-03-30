
EAPI=5
DECRIPTION="cvxopt"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/cvxopt-1.1.5.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/lapack
legacy-spkg/blas
legacy-spkg/numpy
legacy-spkg/atlas
legacy-spkg/cephes
legacy-spkg/gsl
legacy-spkg/glpk
legacy-spkg/matplotlib"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv cvxopt-1.1.5 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        SAGE_ENV_SOURCED= ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c ./spkg-install || die
}

