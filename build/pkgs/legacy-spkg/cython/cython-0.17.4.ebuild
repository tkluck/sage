
EAPI=5
DECRIPTION="cython"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/cython-0.17.4.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/python"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv cython-0.17.4 src
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

