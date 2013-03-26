
EAPI=5
DECRIPTION="rubiks"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/rubiks-20070912.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv rubiks-20070912 src
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

