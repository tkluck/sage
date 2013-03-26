
EAPI=5
DECRIPTION="pari"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/pari-2.5.3.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/readline
legacy-spkg/mpir"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv pari-2.5.3 src
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

