
EAPI=5
DECRIPTION="jmol"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/jmol-12.3.27.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/sagenb"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv jmol-12.3.27 src
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

