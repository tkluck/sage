
EAPI=5
DECRIPTION="lapack"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/lapack-20071123.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/sage_root"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv lapack-20071123 src
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

