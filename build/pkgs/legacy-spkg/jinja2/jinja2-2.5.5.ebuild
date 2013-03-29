
EAPI=5
DECRIPTION="jinja2"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/jinja2-2.5.5.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/pygments"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv jinja2-2.5.5 src
        cp -r "${FILESDIR}"/* . || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        MAKE=${MAKE} ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c ./spkg-install || die
}

