
EAPI=5
DECRIPTION="sage_scripts"
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
        # the old makefile does some magic to find fortran. Here, we just wrap
        # the system version
	mkdir -p ${EPREFIX}/bin
        cat > ${EPREFIX}/bin/sage_fortran <<EOF
#!/bin/sh
gfortran "\$@"
EOF
	chmod a+x ${EPREFIX}/bin/sage_fortran

        # next, we copy the scripts to local/bin
	cp ${SAGE_ROOT}/src/bin/* ${EPREFIX}/bin && \
	for name in `ls ${SAGE_ROOT}/src/bin`; do chmod a+x ${EPREFIX}/bin/$name; done
}

