
EAPI=5
DECRIPTION="conway_polynomials"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/conway_polynomials-0.4.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/sagenb
legacy-spkg/sage"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv conway_polynomials-0.4 src
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

