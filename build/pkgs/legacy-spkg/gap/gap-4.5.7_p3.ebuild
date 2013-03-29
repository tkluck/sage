
EAPI=5
DECRIPTION="gap"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/gap-4.5.7.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/termcap
legacy-spkg/readline
legacy-spkg/mpir"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv gap-4.5.7 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        MAKE="${MAKE}" ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c ./spkg-install || die
}

