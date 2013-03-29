
EAPI=5
DECRIPTION="libm4ri"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/libm4ri-20120613.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/libpng"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv libm4ri-20120613 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        ${SAGE_ROOT}/sage -sh -c ./spkg-install || die
}

