
EAPI=5
DECRIPTION="portage"
HOMEPAGE=""
SRC_URI=""
LICENSE=""
SLOT="0"
KEYWORDS="amd64-linux"
DEPEND="legacy-spkg/python"
RDEPEND="${DEPEND}"
S="${SAGE_ROOT}/build/portage/src"
src_configure() {
	./configure --prefix=${EPREFIX} --with-offset-prefix=${EPREFIX} --with-portage-user=`id -un` --with-portage-group=`id -gn` --with-extra-path=/usr/local/bin:/usr/bin:/bin
	(cd ${PORTAGE_DIR}/src && ${SAGE_ROOT}/sage -bash -c make && ${SAGE_ROOT}/sage -bash -c 'make install')
}

