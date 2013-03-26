# search library paths in the prefix before those on the system
# LIBRARY_PATH variable is not useful here since those are searched after
# the system library paths known to gcc. The contents of this variable are
# appended to the arguments passed to gcc or ld. Paths given on the command
# line have priority over any system paths.
export COMPILERWRAPPER_LDFLAGS=-L"${LMND_LOCAL}"/lib
# compilerwrapper uses this variable to determine the absolute library path
# for the prefix.
export SAGE_LOCAL="${LMND_LOCAL}"
# disable gen_usr_ldscript function in toolchain-funcs.eclass
# since there is no difference between /usr/lib and /lib in lmonade
export PREFIX_DISABLE_GEN_USR_LDSCRIPT=1
# CPATH is set by baselayout-prefix in lmonade. It is also set here
# to make sure it is available during bootstrap.
: ${CPATH:="${LMND_LOCAL}"/include}
export CPATH
if [[ ${CPATH} != *"${LMND_LOCAL}"/include* ]] ; then
    echo "WARNING: CPATH environment variable does not point to header"
    echo "files installed by lmonade. Please report this error to"
    echo "lmnd-devel@googlegroups.com"
fi
