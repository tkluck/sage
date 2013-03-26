
EAPI=5
DECRIPTION="zlib"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/zlib-1.2.6.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv zlib-1.2.6 src
        cp -r ${FILESDIR}/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        SAGE_LOCAL=${EPREFIX} ./spkg-install || die
}

