
EAPI=5
DECRIPTION="polytopes_db"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/polytopes_db-20100210.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/sage_root"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv polytopes_db-20100210 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        SAGE_LOCAL="${EPREFIX}" ./spkg-install || die
}

