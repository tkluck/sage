
EAPI=5
DECRIPTION="singular"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/singular-3-1-5.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/mpir
legacy-spkg/ntl
legacy-spkg/readline
legacy-spkg/mpfr"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv singular-3-1-5 src
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

