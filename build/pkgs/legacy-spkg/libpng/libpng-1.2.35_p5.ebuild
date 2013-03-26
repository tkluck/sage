
EAPI=5
DECRIPTION="libpng"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/libpng-1.2.35.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/zlib"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv libpng-1.2.35 src
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

