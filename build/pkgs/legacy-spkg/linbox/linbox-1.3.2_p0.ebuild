
EAPI=5
DECRIPTION="linbox"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/linbox-1.3.2.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/mpir
legacy-spkg/ntl
legacy-spkg/givaro
legacy-spkg/mpfr
legacy-spkg/libfplll
legacy-spkg/iml
legacy-spkg/libm4ri
legacy-spkg/libm4rie
legacy-spkg/fflas_ffpack"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv linbox-1.3.2 src
        cp -r ${FILESDIR}/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        SAGE_ROOT="${EPREFIX}/.." sage -sh -c ./spkg-install || die
}

