# This is required to make executables work in their build locations
# where the relative library paths are broken.
# For example dev-libs/ntl doesn't build without this.
export DYLD_FALLBACK_LIBRARY_PATH=${EPREFIX}/lib
