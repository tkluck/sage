
EAPI=5
DECRIPTION="elliptic_curves"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/elliptic_curves-0.7.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/python
legacy-spkg/sqlite
legacy-spkg/sage_root"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv elliptic_curves-0.7 src
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

