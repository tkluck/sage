
EAPI=5
DECRIPTION="ppl"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/ppl-0.11.2.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/mpir
legacy-spkg/sage_root"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv ppl-0.11.2 src
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

