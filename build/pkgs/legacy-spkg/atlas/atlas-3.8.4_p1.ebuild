
EAPI=5
DECRIPTION="atlas"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/atlas-3.8.4.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/lapack
legacy-spkg/python
legacy-spkg/sage_scripts"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv atlas-3.8.4 src
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

