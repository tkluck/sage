
EAPI=5
DECRIPTION="boehm_gc"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/boehm_gc-7.2.alpha6.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND=""
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv boehm_gc-7.2.alpha6 src
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

