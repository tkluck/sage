
EAPI=5
DECRIPTION="polybori"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/polybori-0.8.2.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/python
legacy-spkg/ipython
legacy-spkg/scons
legacy-spkg/boost_cropped
legacy-spkg/libm4ri
legacy-spkg/gd"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
        mv polybori-0.8.2 src
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

