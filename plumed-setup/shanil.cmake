# Preset that turns a specific set of existing packages. Using the combination
# of this preset followed by the nolib.cmake preset should configure
# a LAMMPS binary, with as many packages included, that can be compiled
# with just a working C++ compiler and an MPI library.

set(ALL_PACKAGES
  ASPHERE
  BOCS
  BODY
  BROWNIAN
  CG-DNA
  COLLOID
  COLVARS
  EXTRA-COMPUTE
  EXTRA-DUMP
  EXTRA-FIX
  EXTRA-MOLECULE
  EXTRA-PAIR
  MC
  MOLECULE
  MOLFILE
  MPIIO
  OPENMP
  PLUMED
  RIGID
)

foreach(PKG ${ALL_PACKAGES})
  set(PKG_${PKG} ON CACHE BOOL "" FORCE)
endforeach()

