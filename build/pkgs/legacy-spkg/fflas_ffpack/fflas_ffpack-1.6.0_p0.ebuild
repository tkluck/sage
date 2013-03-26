
EAPI=5
DECRIPTION="fflas_ffpack"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/fflas_ffpack-1.6.0.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/mpir
legacy-spkg/givaro
legacy-spkg/gsl
legacy-spkg/atlas"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv fflas_ffpack-1.6.0 src
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

