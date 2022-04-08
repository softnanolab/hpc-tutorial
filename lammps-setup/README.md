# Setting up lammps

Last updated by Shanil Panara on 08/04/2021.

So this took me faar too long to figure out, mainly because this method is so flexible and there are a lot of extra modifications you can make, and a lot more to it than what I'm presenting below... but this should do the job for running simulations with LAMMPS, and using oxDNA and many other packages. 

_I'm going to write this guide whilst my "build" step is occuring on the HPC (this takes a while ~20mins) - challenge accepted. EDIT: I failed, but hopefully I've saved the next person some time xD!_

I believe that there are two general options you can do w.r.t installing LAMMPS:

1. Download a pre-built executable for your system: [see here](https://docs.lammps.org/Install.html).
2. Download the LAMMPS source code from github and compile it yourself, which is what I will describe below. For completeness, [see here](https://docs.lammps.org/Install_git.html).

## 1. Downloading

First, log in to the HPC. See [HPC-introduction](https://github.com/softnanolab/hpc-tutorial/tree/main/HPC-intro) where I've written how to do this.

Then, you can download the source code into your `programs` directory. (it's good practice to store all your programs in one place like this).

```bash
mkdir programs		# make a directory if you haven't already (good practice to store things in one place)
cd programs		# enter that directory
git clone -b release --depth 1000 https://github.com/lammps/lammps.git lammps 
```
Here, we are downloading all the source code of the "release" branch of the repository, and this is being saved in a folder called `lammps`. Read more about the "depth" command at the link above (2nd list item). This takes a few minutes.

## 2. Building

_Okay, so this is the thing which took me forever to understand. So here goes..._

We are going to use a tool called `CMake` to build the LAMMPS software. You can read about this in more detail [here](https://docs.lammps.org/Build_cmake.html). In summary, it is a very powerful tool which makes life very easy for people with limited experience in compiling software.

To use it, you first have to load it. It came pre-loaded on the HPC for me, but if it is not:

```bash
module list            # check if a cmake module is already loaded
module avail cmake     # see the versions of cmake available on the HPC
module load cmake      # load default cmake module
                       # or load a specific version by replacing `cmake` with, e.g., `cmake/3.9.0`
```

_Ahhh I'm at 90% built now. Not going to finish in time but all is well, there isn't much left to do._

So now, we must do the following:

```bash
cd lammps		# enter the directory with the LAMMPS distribution
mkdir build; cd build	# create and use a build directory
cmake ../cmake -C ../cmake/presets/most.cmake 
cmake --build .		# compilation step (the ~20-30m long step)
```

Once this is done, we will have an executable in this `build` folder called `lmp`.

You might ask, why am I even bothering to do this if it takes 30 mins? Well the main thing difference between downloading an executable and building it ourselves, is that we got to specific exactly which packages were installed, and hence are usable with (or purposefully omitted from) our LAMMPS executable.

- `../cmake` specifies the location of a file called `CMakeLists.txt` which is the only mandatory argument for the `cmake` command.
- `-C ../cmake/presets/most.cmake` specifies a list of packages which should be installed in our executable. If you take a deep dive into the `most.cmake` file and any other files in the `presets/` folder then it should give you a pretty good idea of what is being installed. You can of course make your own `.cmake` file and add/delete the packages as you wish. Fewer packages = shorter compile time, but in my opinion, doing this once and forgeting about it is probably the best way forward. Of course, that is not possible if you are editing the LAMMPS distribution, in which case you'd naturally be building frequently to test your code. Anyways... I digress...

## 3. Running your simulations!

So now you have your executable, you're done! Woop!

But... how do I call the LAMMPS executable from your command line you ask? Well, you have a few options:

1. Install the executable onto your system by typing the following. It should be done in < 1 min.

	```bash
	make install		# optional, copy compiled files into installation location
	
	```
	
	This will install the LAMMPS executable, LAMMPS library, any tools, and additional files to `~/.local` i.e. our home directory.

	You should be able to call it on the command line now using `lmp -in <input file>` but the `lmp` command doesn't seem to be found, so... some alternatives.

2. Call the file using it's full path, every time.
	
	For me, this syntax is:

	```bash
	/rds/general/user/sp2017/home/programs/lammps/build/lmp -in <input file>
	```

3. Create an alias for your file.

	Programmers hate typing long things out again and again, so they created a way of saving themselves from this pain by doing the following:

	```bash
	cd ~			# go back your home directory
	nano .bashrc		# open the `.bashrc` file with your favourite editor
	alias lmp="/rds/general/user/sp2017/home/programs/lammps/build/lmp"
				# add the above line to the end of the file, save and exit (Ctrl+S, Ctrl+X)
	source ~/.bashrc	# re-run the file (or open and close the terminal)
	```
	
	Voila, that's it.

**Happy LAMMPS-ing**
