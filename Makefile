# XXX this should probably have quotes, but then it fails under zsh  ???
SAGE_ROOT=${PWD}
SAGE_LOCAL=${SAGE_ROOT}/local
PORTAGE_DIR=build/portage
PORTAGE_GROUP=$(shell groups | cut -d' ' -f1)

# This makefile takes care of the following:
#  1. install Portage Prefix into $SAGE_LOCAL (this is the bootstrap target)
#  2. copy any available spkg files to where portage can find them (this is the local_packages target)
#  3. install all spkg files that are needed for sage -b (this is the sage_package_dependencies target)
#  4. install libcsage (this is the libcsage target)
#  5. perform sage -b (this is the sage target)
#  6. install all other packages (also the sage target)
#  7. perform sage -docbuild all html (this is the sage-doc target)

SAGE_VERSION_PREFIX==
SAGE_VERSION_SUFFIX=-`${SAGE_ROOT}/build/portage/checked_out_version`

all: sage sage-starts

bootstrap: local/bin/emerge \
           local/bin/sage \
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
               fi \
           fi \
        done 
	touch .bootstrap_gnu_utils.stamp


#
# installing emerge is just ./configure; make; make install. Here, we have
# split that into several steps/targets, but maybe that's unnecessary
build/portage/src/config.log: build/portage/src/autogen.sh local/bin/python .bootstrap_gnu_utils.stamp
	(cd ${PORTAGE_DIR}/src && ./autogen.sh) 
	(cd ${PORTAGE_DIR}/src && ${SAGE_ROOT}/sage -bash -c './configure --prefix=${SAGE_LOCAL} --with-offset-prefix=${SAGE_LOCAL} --with-portage-user=${USER} --with-portage-group=${PORTAGE_GROUP} --with-extra-path=/usr/local/bin:/usr/bin:/bin' )
local/bin/emerge: build/portage/src/config.log
	# install fails when it can't make certain symbolic links, so let's delete them if they exist
	rm -f ${SAGE_LOCAL}/etc/make.globals
	(cd ${PORTAGE_DIR}/src && ${SAGE_ROOT}/sage -bash -c make && ${SAGE_ROOT}/sage -bash -c 'make install')

# make sure sage is in our path when we need it
local/bin/sage:
	(cd ${SAGE_LOCAL}/bin && ln -sf ../../sage) 

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

# install the extcode to local/share/sage/ext by just copying them
# Sage also expects the symlink devel/ext -> devel/ext-main
extcode: local/share/sage/ext
local/share/sage/ext:
	rm -rf local/share/sage/ext
	mkdir -p ${SAGE_LOCAL}/share/sage
	cp -r ${SAGE_ROOT}/src/ext local/share/sage/ext

# install the scripts to local/bin by just copying them
scripts: local/bin/sage_fortran
	cp ${SAGE_ROOT}/src/bin/* ${SAGE_LOCAL}/bin
	for name in `ls ${SAGE_ROOT}/src/bin`; do chmod a+x ${SAGE_LOCAL}/bin/$$name; done

# the old makefile does some magic to find fortran. Here, we just wrap
# the system version
local/bin/sage_fortran:
	mkdir -p ${SAGE_LOCAL}/bin
	(echo '#!/bin/sh'; echo 'gfortran "$$@"') > ${SAGE_LOCAL}/bin/sage_fortran
	chmod a+x ${SAGE_LOCAL}/bin/sage_fortran

libcsage: local/lib/libcsage.so
local/lib/libcsage.so: sage_package_dependencies
	(cd ${SAGE_ROOT}/src/c_lib && ${SAGE_ROOT}/sage -bash -c scons -Q install)
	(cd ${SAGE_ROOT}/local/include && ln -sf ../../src/c_lib/include csage)
	(cd ${SAGE_ROOT}/local/lib && ln -sf ../../src/c_lib/libcsage.so)

# the sage ebuild depends exactly on all things that are needed for libcsage and for
# sage -b to work
# We use the --oneshot option to make sure emerge does not hold on to this package
# in case of a downgrade (which would make the downgrade fail)
sage_package_dependencies: local_packages extcode scripts bootstrap 
	${SAGE_ROOT}/sage -bash -c '${SAGE_LOCAL}/bin/emerge --noreplace --oneshot --deep --update --keep-going --jobs 4 ${SAGE_VERSION_PREFIX}legacy-spkg/sage${SAGE_VERSION_SUFFIX}'

# after building sage, we install all other packages by emerging the sage-full
# ebuild. Some of those packages actually depend on sage, and conversely sage
# depends on some of them at runtime. So we keep this in a single target.
# We use the --oneshot option to make sure emerge does not hold on to this package
# in case of a downgrade (which would make the downgrade fail)
sage: extcode scripts sage_package_dependencies libcsage
	${SAGE_ROOT}/sage -b
	${SAGE_LOCAL}/bin/emerge --noreplace --oneshot --deep --update --keep-going --jobs 4 ${SAGE_VERSION_PREFIX}legacy-spkg/sage-full${SAGE_VERSION_SUFFIX}

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
local_packages: bootstrap
	${SAGE_ROOT}/sage -bash -c '${SAGE_LOCAL}/bin/emerge --oneshot --fetchonly ${SAGE_VERSION_PREFIX}legacy-spkg/sage-full${SAGE_VERSION_SUFFIX}'


# a check target that runs the doctests
check: sage sage-starts
	${SAGE_ROOT}/sage -t devel/sage-main/sage

.PHONY: sage bootstrap scripts extcode all sage-doc sage_package_dependencies \
libcsage local_packages sage-starts
