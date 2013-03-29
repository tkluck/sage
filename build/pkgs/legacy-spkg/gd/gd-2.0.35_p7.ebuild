
EAPI=5
DECRIPTION="gd"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/gd-2.0.35.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/libpng
legacy-spkg/freetype
legacy-spkg/iconv"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv gd-2.0.35 src
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

