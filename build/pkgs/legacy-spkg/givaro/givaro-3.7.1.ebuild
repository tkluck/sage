
EAPI=5
DECRIPTION="givaro"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/givaro-3.7.1.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/mpir"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv givaro-3.7.1 src
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

