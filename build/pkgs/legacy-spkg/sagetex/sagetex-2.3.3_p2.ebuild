
EAPI=5
DECRIPTION="sagetex"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/sagetex-2.3.3.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/python
legacy-spkg/maxima
legacy-spkg/scipy
legacy-spkg/matplotlib
legacy-spkg/pil
legacy-spkg/tachyon"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv sagetex-2.3.3 src
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

