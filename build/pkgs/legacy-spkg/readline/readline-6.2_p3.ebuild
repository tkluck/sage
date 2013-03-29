
EAPI=5
DECRIPTION="readline"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/readline-6.2.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/termcap"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv readline-6.2 src
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

