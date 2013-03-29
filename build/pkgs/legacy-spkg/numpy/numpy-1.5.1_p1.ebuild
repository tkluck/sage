
EAPI=5
DECRIPTION="numpy"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/numpy-1.5.1.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/python
legacy-spkg/lapack
legacy-spkg/sage_scripts
legacy-spkg/blas
legacy-spkg/atlas"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv numpy-1.5.1 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        MAKE=${MAKE} ABI= CFLAGS= CXXFLAGS= LDFLAGS= MAKE=${MAKE} ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c  ./spkg-install || die
}

