
EAPI=5
DECRIPTION="gdmodule"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/gdmodule-0.56.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/python
legacy-spkg/gd
legacy-spkg/iconv"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv gdmodule-0.56 src
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

