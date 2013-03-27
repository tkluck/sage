
EAPI=5
DECRIPTION="extcode"
HOMEPAGE=""
SRC_URI=""
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="=legacy-spkg/sage_root-5.9_beta1"
RDEPEND="${DEPEND}"
S="${WORKDIR}"
src_unpack() {
	return 0
}
src_configure() {
        return 0
}
src_compile() {
        return 0
}
src_install() {
	rm -rf ${EPREFIX}/share/sage/ext && \
	mkdir -p ${EPREFIX}/share/sage && \
	cp -r ${SAGE_ROOT}/src/ext ${EPREFIX}/share/sage/ext
}

