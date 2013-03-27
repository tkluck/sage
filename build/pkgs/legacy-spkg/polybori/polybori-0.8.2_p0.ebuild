EAPI=5
DECRIPTION="polybori"
HOMEPAGE=""
SRC_URI="http://boxen.math.washington.edu/home/ohanar/sage-git/upstream/polybori-0.8.2.tar.bz2"
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/python
legacy-spkg/scons
legacy-spkg/boost_cropped
legacy-spkg/libm4ri
legacy-spkg/gd"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_prepare() {
    mv polybori-0.8.2 src
    cp -r "${FILESDIR}"/* . || die

    cd src || die
    cp ../custom.py . || die
    for patch in ../patches/*.patch; do
        patch -p1 < "$patch" || die
    done
}

src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
        cd src
        scons BOOST_TEST=no prepare-devel || die
        # we should use ${SAGE_LOCAL} instead of ${EPREFIX}, but that
        # can't be used until we're inside sage -sh
        scons BOOST_TEST=no devel-install install "PREFIX=${EPREFIX}" \
           "INSTALLDIR=${EPREFIX}/share/polybori" \
           "CONFFILE=${EPREFIX}/share/polybori/flags.conf" || die
}

