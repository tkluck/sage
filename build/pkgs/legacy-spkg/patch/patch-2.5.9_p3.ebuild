
EAPI=5
DECRIPTION="patch"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/patch-2.5.9.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/bzip2"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv patch-2.5.9 src
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

