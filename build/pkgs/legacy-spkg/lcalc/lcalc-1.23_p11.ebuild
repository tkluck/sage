
EAPI=5
DECRIPTION="lcalc"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/lcalc-1.23.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/pari
legacy-spkg/mpfr"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv lcalc-1.23 src
        cp -r ${FILESDIR}/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        SAGE_ROOT=$(cd "${EPREFIX}/.." && pwd) sage -sh -c ./spkg-install || die
}

