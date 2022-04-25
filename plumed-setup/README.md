# Setting up PLUMED to work with LAMMPS

There are many different sources I had to go to, and I spent a day trying to figure this out, so I'm documenting how I did it on my own computer. I hope this helps you.

### Links:

- [PLUMED Installation](https://www.plumed.org/doc-v2.8/user-doc/html/_installation.html#installingonacluster)
- [Building LAMMPS with the PLUMED](https://docs.lammps.org/Build_extras.html#plumed)


### Outline

1. Download PLUMED
2. Compile & Install PLUMED
3. Add stuff to .bashrc
4. Create a _shared_ link from LAMMPS to PLUMED
5. Use CMake to compile and install LAMMPS

## 1. Download PLUMED

Choose the version that suits you, and download the corresponding compressed folder `plumed-<version>.tgz` from [the plumed2 GitHub repository](https://github.com/plumed/plumed2/releases) into your `programs/` folder.

Then uncompress this folder using:

```bash
tar xfz plumed-<version>.tgz
```

## 2. Compile and Install PLUMED

This took me faaaaaaar too long, as there seemed to be many options, but the following should work fine:

```bash
cd plumed-<version>
```
I had to `conda deactivate` in order for the `./configure` command to work with MPI... _Not sure why_
```bash
./configure --prefix=/usr/local
make -j 4
make install
```

_Then you wait like 10 minutes_

## 3. Add stuff to your `.bashrc` file

Using the above flag `--prefix` means that your plumed executable is in `/usr/local/bin/plumed`, plumed installation files should be in `/usr/local/lib` and some other files will be in other files in `/usr/local/`. In order for LAMMPS to be able to locate all the PLUMED files, either you can:

- load the modulefile at `/usr/local/lib/plumed/modulefile` (which you will need to change the first few lines of I think) but I don't know how to do this on my own computer. You might need to move the file somewhere, maybe... idk
- **HACK THE SYSTEM** and just add the relevant information in your `.bashrc` file, which achieves exactly the same as the modulefile, but it will do it every time your terminal is restarted

I added the following to my bashrc file:

```bash
# PLUMED - not sure what the first two lines do though...
_plumed() { eval "$(plumed --no-mpi completion 2>/dev/null)";}
complete -F _plumed -o default plumed
export CPATH=/usr/local/include
export INCLUDE=/usr/local/include
export LIBRARY_PATH=/usr/local/lib
export LD_LIBRARY_PATH=/usr/local/lib
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/
export PLUMED_KERNEL=/usr/local/lib/libplumedKernel.so
```

## 4. Create a _shared_ link from LAMMPS to PLUMED

Here, I made sure to activate my conda environment (allowing me to use python).

```bash
cd path/to/lammps
cd lib/plumed/
python Install.py -p /usr/local -m shared
```

This creates two folders and a Makefile almost instantly, ez.

## 5. Use CMake to compile and install LAMMPS

Finally, I built LAMMPS! I only chose a specific few packages, see my `cmake` file in the folder.

```bash
mkdir build; cd build
cmake ../cmake -C ../cmake/presets/shanil.cmake -D DOWNLOAD_PLUMED=no -D PLUMED_MODE=shared
cmake --build .		# took ~20-30m
```