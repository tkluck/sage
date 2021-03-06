
EAPI=5
DECRIPTION="cddlib"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/cddlib-094f.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/mpir"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv cddlib-094f src
        cp -r "${FILESDIR}"/* . || die
        mv patches/autogenerated/m4/ltobsolete.m4 patches/autogenerated/m4/lt~obsolete.m4 || die
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        SAGE_ENV_SOURCED= ABI= CFLAGS= CXXFLAGS= LDFLAGS= ABI= CFLAGS= CXXFLAGS= LDFLAGS= ${SAGE_ROOT}/sage -sh -c  ./spkg-install || die
}

