
EAPI=5
DECRIPTION="matplotlib"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/matplotlib-1.1.0.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/python
legacy-spkg/numpy
legacy-spkg/freetype
legacy-spkg/libpng
legacy-spkg/gdmodule"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv matplotlib-1.1.0 src
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

