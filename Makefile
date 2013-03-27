# XXX this should probably have quotes, but then it fails under zsh  ???
SAGE_ROOT=${PWD}
SAGE_LOCAL=${SAGE_ROOT}/local
PORTAGE_DIR=build/portage
PORTAGE_GROUP=$$(groups | cut -d' ' -f1)

# This makefile takes care of the following:
#  1. bootstrap GNU utils and python2.7 (when necessary)
#  2. install Portage Prefix into $SAGE_LOCAL (this is the bootstrap target)
#  3. emerge gcc (when necessary)
#  4. if gcc was emerged, re-emerge its dependencies using the new gcc
#  5. download upstream sources (this is the local_packages target)
#  6. install the dependency tree by emerging legacy-spkg/sage-full
#  7. perform sage -docbuild all html (this is the sage-doc target)
#  8. perform all doctests (this is the check target)

SAGE_VERSION_PREFIX==
SAGE_VERSION_SUFFIX=-`${SAGE_ROOT}/build/portage/checked_out_version`

all: sage sage-starts

bootstrap: local/bin/emerge \
           local/etc/portage/make.profile \
           local/etc/make.conf \
           local/etc/portage/categories \
           local/usr

bootstrap_python: local/bin/python
local/bin/python:
	mkdir -p ${SAGE_ROOT}/upstream
	if ! python --version 2>&1 | grep -q 2.7; then \
            build/portage/bootstrap-legacy-spkg build/pkgs/legacy-spkg/libpng/libpng-1.2.35_p5.ebuild; \
            build/portage/bootstrap-legacy-spkg build/pkgs/legacy-spkg/bzip2/bzip2-1.0.6.ebuild; \
            build/portage/bootstrap-legacy-spkg build/pkgs/legacy-spkg/zlib/zlib-1.2.6_p0.ebuild; \
            build/portage/bootstrap-legacy-spkg build/pkgs/legacy-spkg/readline/readline-6.2_p3.ebuild; \
            build/portage/bootstrap-legacy-spkg build/pkgs/legacy-spkg/sqlite/sqlite-3.7.5_p1.ebuild; \
            build/portage/bootstrap-legacy-spkg build/pkgs/legacy-spkg/python/python-2.7.3_p5.ebuild; \
        else \
            mkdir -p local/bin; \
            ln -sf `which python` local/bin/python; \
        fi

bootstrap_gnu_utils: .bootstrap_gnu_utils.stamp
.bootstrap_gnu_utils.stamp:
	for util in sed find xargs wget grep make install; do \
           if ! $$util --version | grep -q GNU; then \
               if which g$$util; then \
                   ln -sf `which g$$util` local/bin/$$util; \
               else \
                   build/portage/bootstrap-legacy-spkg build/pkgs/legacy-spkg/coreutils/coreutils-8.21.ebuild; \
                   build/portage/bootstrap-legacy-spkg build/pkgs/legacy-spkg/findutils/findutils-4.4.2.ebuild; \
               fi \
           fi \
        done 
	touch .bootstrap_gnu_utils.stamp

local/bin/emerge: build/portage/src/autogen.sh local/bin/python .bootstrap_gnu_utils.stamp
	(cd ${PORTAGE_DIR}/src && ${SAGE_ROOT}/sage -bash -c ./autogen.sh) 
	(cd ${PORTAGE_DIR}/src && ${SAGE_ROOT}/sage -bash -c "./configure --prefix=${SAGE_LOCAL} --with-offset-prefix=${SAGE_LOCAL} --with-portage-user=${USER} --with-portage-group=${PORTAGE_GROUP} --with-extra-path=/usr/local/bin:/usr/bin:/bin" )
	# install fails when it can't make certain symbolic links, so let's delete them if they exist
	rm -f ${SAGE_LOCAL}/etc/make.globals
	(cd ${PORTAGE_DIR}/src && ${SAGE_ROOT}/sage -bash -c make && ${SAGE_ROOT}/sage -bash -c 'make install')

# the make.profile configuration directory contains compiler flags etc that are optimized
# for the host's specific architecture.
local/etc/portage/make.profile:
	mkdir -p ${SAGE_LOCAL}/etc/portage 
	# TODO: find out by what logic lmonade knows which profile to select
	(cd ${SAGE_LOCAL}/etc/portage  && ln -sf ../../../build/portage/profiles/lmnd/linux/amd64 make.profile)
# the portage/categories file should contain a list of all ebuild categories. Those are the
# subdirectories of the local/portage directory
local/etc/portage/categories: build/portage/categories
	mkdir -p ${SAGE_LOCAL}/etc/portage 
	cp ${PORTAGE_DIR}/categories local/etc/portage

local/etc/make.conf: build/portage/make.conf
	# make.conf has no access to variables defined in make.globals. As a workaround, we
	# substitute ${CONFIGURE_EPREFIX} manually.
	# TODO: this only works if the path does not contains the + character!!!
	cat ${PORTAGE_DIR}/make.conf | sed 's+$${CONFIGURE_EPREFIX}'+${SAGE_LOCAL}+g > local/etc/make.conf
    
# this is a workaround: some parts of portage seem to expect ${EPREFIX} as the prefix,
# others expect ${EPREFIX}/usr. I just copied this workaround from lmonade
local/usr:
	(cd ${SAGE_LOCAL} && ln -sf . usr)

gcc: bootstrap
	if ! ${SAGE_ROOT}/sage -bash -c 'gcc --version' | grep -q 4.6; then \
            if ! ${SAGE_ROOT}/sage -bash -c 'gcc --version' | grep -q 4.7; then \
                ${SAGE_ROOT}/sage -bash -c '${SAGE_LOCAL}/bin/emerge --noreplace --oneshot legacy-spkg/gcc'; \
                ${SAGE_ROOT}/sage -bash -c '${SAGE_LOCAL}/bin/emerge --oneshot legacy-spkg/mpir legacy-spkg/mpfr legacy-spkg/mpc legacy-spkg/zlib'; \
            fi; \
        fi

# We use the --oneshot option to make sure emerge does not hold on to this package
# in case of a downgrade (which would make the downgrade fail)
sage: bootstrap gcc
	${SAGE_ROOT}/sage -bash -c '${SAGE_LOCAL}/bin/emerge --noreplace --oneshot --deep --update --keep-going --jobs 4 ${SAGE_VERSION_PREFIX}legacy-spkg/sage-full${SAGE_VERSION_SUFFIX}'

# the sage-docs are necessary for some of the doctests
# it is, however, extremely memory-intensive to build them
sage-doc: sage
	${SAGE_ROOT}/sage -docbuild all html

# this is a script that checks, after an update, whether sage still
# starts, and displays bug-reporting instructions otherwise
sage-starts: local/etc/sage-started.txt
local/etc/sage-started.txt: sage
	${SAGE_LOCAL}/bin/sage-starts

# We do all downloads before emerging
local_packages: .local_packages.stamp
.local_packages.stamp: bootstrap
	${SAGE_ROOT}/sage -bash -c '${SAGE_LOCAL}/bin/emerge --oneshot --fetchonly ${SAGE_VERSION_PREFIX}legacy-spkg/sage-full${SAGE_VERSION_SUFFIX}'
	touch .local_packages.stamp


# a check target that runs the doctests
check: sage sage-starts
	${SAGE_ROOT}/sage -t src/sage

.PHONY: sage bootstrap all sage-doc sage_package_dependencies \
libcsage local_packages sage-starts gcc
