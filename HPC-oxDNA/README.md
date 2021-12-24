# HPC-oxDNA

_Last updated by Shanil Panara on 24/12/2021._

## How do I simulate a design?

You'll first need two files: topology (`.top`) and configuration (`.conf`) files which describe the structure that you would like to simulate.

Next, you should _always_ look to run a minimisation simulation first (which requires an input file **[1a]**), before running the full oxDNA simulation (which also requires it's own input file **[1b]**).

1a. [oxDNA minimisation input file](/HPC-oxDNA/oxdna.min.in)

1b. [oxDNA simulation input file](/HPC-oxDNA/oxdna.sim.in)

To run these input files, you can run either:

```
path/to/oxDNA oxdna.sim.in <options>
```
or if the alias has been set
```
oxDNA oxdna.sim.in <options>
```
- We do this by adding a line to our `.bashrc` file, e.g. `alias oxDNA=/home/shanil/programs/oxDNA/build/bin/oxDNA`, where you must customise the path to point to your oxDNA executable. Ensure, the terminal is restarted or `source ~/.bashrc` is run before trying to use this command.

## How do I run these functions on the HPC

In order to run these on the HPC, you'll need a PBS input file, describing the resource requirements, appropriately managing files/folders and more (details of this are in the [HPC introduction](/HPC-intro/README.md))

2 . [PBS input file](/HPC-oxDNA/pbs_input_file)

Below are their explanations.

## oxDNA input files

The input files for minimisation and simulation are relatively similar, and contain many of the same parameters.

- You can find a description of all input file parameters
    - here: [online documentation](https://dna.physics.ox.ac.uk/index.php/Documentation#input_files) - though it is rather brief of the details
    - and here: [documentation from src](/HPC-oxDNA/input_options.md) - a much more in-depth source of information, copied from the oxDNA source code and put here for accessibility
- Below, I have tried to give a slightly expanded explanation for the input parameters where I felt it was necessary.

## 1a. oxDNA minimisation file

The oxDNA energy minimisation process is not very well documented. However:
- this is a steepest descent energy minimisation, which moves the atoms to reduce the overall energy of the configuration
- for this, the oxDNA potential function is modified

- We carry out this process in order to ensure that we don't have "extremely high energy" points in the starting configuration
- If we didn't, the existence of these points could make our simulations effectively "explode", hence fail...!

The below example shows all the options you should need to use for straightforward minimisations, with explanations as to what they are doing.

```python
##############################
####  PROGRAM PARAMETERS  ####
##############################

interaction_type = DNA2 # use oxDNA2 interaction potential
backend = CPU           # minimisation can't be run on a GPU

##############################
####    SIM PARAMETERS    ####
##############################

# Minimisation parameters
sim_type = min          # minimisation simulation

max_backbone_force = 5. # related to the maximum distance allowed
                        # between two backbone sites, changes the
                        # potential energy function

# Others
steps = 3000            # a few thousand steps should be sufficient
                        # but you might want to check first

T = ...                 # temperature is specified when running the
                        # simulation - given in the form: `<float> C`

salt_concentration=0.5  # can only be specified if using the DNA2
                        # interaction potential (units are in M)


verlet_skin = 0.15      # maximum displacement (in simulation units)
                        # before Verlet lists need to be updated
                        # (all bases within a given cut-off distance)

dt = 0.003              # time step should be between 0.001 and 0.003
                        # time conversion is not straight forward, but
                        # with direct time conversion, 1 dt = 3.03 us

##############################
####    INPUT / OUTPUT    ####
##############################

                        # These 6 are specified in the PBS file.
topology = ...          # input:    topology file
conf_file = ...         # input:    configuration file
lastconf_file = ...     # output:   last configuration file
trajectory_file = ...   # output:   system configurations through
                        #           the simulation
energy_file = ...       # output:   energy (per nucleotide),
log_file = ...          # output:   collects all log statements:
                        #           info, debug, warnings, errors...

                         # number of timesteps after which to output
                         # a snapshot of the system's:
print_energy_every=1000  # energies (for energy file)
print_conf_interval=1000 # configuration (for trajectory file)
time_scale = linear      # linearly spaced configurations outputed

no_stdout_energy = 0    # (0 = false) print energy to output stream
restart_step_counter=1  # step counter begins at 0
refresh_vel = 1         # initialises random velocities for each nt
                        # from a Maxwell-Boltzmann prob. distribution

```

## 1b. oxDNA relaxation file

- This is for slowly bring together neighbours that start far away (more than a couple of length units) from each other.
- Exotic cadnano files will inevitably have this problem.
- The nice thing about this interaction is that it also works on CUDA, and works in the same way for both oxDNA and oxDNA2.
- Set `sim_type = relax`, with the same input parameters as the minimisation file

## 1c. oxDNA simulation file

The below example shows all the options you should need to use for GPU enabled simulations, with explanations as to what they are doing. It is highly recommended to use GPUs for the simulation as they provide a substantial performance increase.

```python
##############################
####  PROGRAM PARAMETERS  ####
##############################

interaction_type = DNA2 # use oxDNA2 interaction potential
backend = CUDA          # run on a GPU (much faster)

# CUDA options:
CUDA_list = verlet      # type of lists to use (see Verlet Lists)
CUDA_sort_every = 0     # no. of timesteps between sorting nucleotides
                        # in order to store them in a more efficient way,
                        # hence, this can speed up access to data in
                        # the memory (see Hilbert Sort), 0 means don't sort
use_edge = 1            # a type of parallelisation to do force calcs
                        # over interacting pairs of particles, speeds it up
max_density_multiplier=5

##############################
####    SIM PARAMETERS    ####
##############################

# MD specific parameters
sim_type = MD           # molecular dynamics simulation

thermostat = langevin   # other types include an Andersen-like
                        # thermostat, with parameters designed to lead
                        # to efficient diffusion of strands

# Others
T = ...                 # temperature is specified when running the
                        # simulation - given in the form: `<float> C`

steps = 5e6             # specify the number of timesteps to simulate
                        # 1e5 steps * dt (0.003) ~ 300 dt = 0.909ms

dt = 0.003              # time step should be between 0.001 and 0.003
                        # time conversion is not straight forward, but
                        # with direct time conversion, 1 dt = 3.03 us

salt_concentration=0.5  # can only be specified if using the DNA2
                        # interaction potential (units are in M)

verlet_skin = 0.15      # maximum displacement (in simulation units)
                        # before Verlet lists need to be updated
                        # (all bases within a given cut-off distance)

seed = 5                # TODO: write about this

diff_coeff = 2.5        # TODO: write about this

# Sequence Dependence - copy seq dep file from programs/oxDNA/ to cwd
use_average_seq = no    # by default average sequence parameters are used
                        # comment out both lines for default behaviour
seq_dep_file = oxDNA2_seq_dep_params.txt

##############################
####    INPUT / OUTPUT    ####
##############################

                        # These 6 are specified in the PBS file.
topology = ...          # input:    topology file
conf_file = ...         # input:    configuration file
lastconf_file = ...     # output:   last configuration file
trajectory_file = ...   # output:   system configurations through
                        #           the simulation
energy_file = ...       # output:   energy (per nucleotide),
log_file = ...          # output:   collects all log statements:
                        #           info, debug, warnings, errors...

                         # number of timesteps after which to output
                         # a snapshot of the system's:
print_energy_every=1000  # energies (for energy file)
print_conf_interval=1000 # configuration (for trajectory file)
time_scale = linear      # linearly spaced configurations outputed

no_stdout_energy = 0    # (0 = false) print energy to output stream
restart_step_counter=1  # step counter begins at 0
refresh_vel = 1         # initialises random velocities for each nt
                        # from a Maxwell-Boltzmann prob. distribution

```

## 2. [PBS input file](/HPC-oxDNA/pbs_input_file) example for an oxDNA simulation at different temperatures

### PBS instructions
1. Set the name of the job
    ```ruby
    #PBS -N exampleScript
    ```
2. Set the max time you expect the job to run (24h)
    ```ruby
    #PBS -l walltime=24:00:00
    ```
3. Select 1 GPU of type 'P1000'
    ```ruby
    #PBS -l select=1:ncpus=1:mem=96gb:ngpus=1:gpu_type=P1000
    ```
4. Run 6 copies of this job (-J 30-55:5)
    ```ruby
    #PBS -J 30-55:5
    ```
    where below the `${PBS_ARRAY_INDEX}` variable will change for each subjob, i.e. it's value will be either: 30 35 40 45 50 or 55, where we use this to dictate the temperature we want to run the simulation at

### The rest of the file
```python
# Environment setup
module load cuda/9.2

# File naming
T=${PBS_ARRAY_INDEX}
FOLDER="01_${T}C"
NAME="01_tetrahedron_5nt"
MIN_NAME="${NAME}.min"
SIM_NAME="${NAME}.sim"

# File management
mkdir $FOLDER
cp "${NAME}.top" "${FOLDER}/"
cp "${NAME}.conf" "${FOLDER}/"

cp oxdna.min.in "${FOLDER}/"
cp oxdna.sim.in "${FOLDER}/"
cp oxDNA2_seq_dep_params.txt "${FOLDER}/"
cp input.pbs "${FOLDER}/"

# Directory Setup
cd $PBS_O_WORKDIR
cd $FOLDER

# Print the details of the GPU you are using
nvidia-smi

# Minimise
/rds/general/user/sp2017/home/programs/oxDNA/build/bin/oxDNA oxdna.min.in \
    topology=${NAME}.top conf_file=${NAME}.conf \
    lastconf_file=${MIN_NAME}.conf \
    trajectory_file=${MIN_NAME}.traj.conf \
    energy_file=${MIN_NAME}.energy \
    log_file=${MIN_NAME}.log \
    T=${T}C
# Here, we have specified
# - the input: topology and configuration file names for the oxDNA **minimisation**
# - the output: "minimised" configuration file (taken as the last configuration)

# Copy toplogy
cp "${NAME}.top" "${NAME}.min.top"

# Run
/rds/general/user/sp2017/home/programs/oxDNA/build/bin/oxDNA oxdna.sim.in \
    topology=${MIN_NAME}.top conf_file=${MIN_NAME}.conf \
    lastconf_file=${SIM_NAME}.conf \
    trajectory_file=${SIM_NAME}.traj.conf \
    energy_file=${SIM_NAME}.energy \
    log_file=${SIM_NAME}.log \
    T=${T}C
# Here, we have specified:
# - the input: topology and configuration files for the oxDNA **simulation**
# - the output:
#       - energy file - output (Total | Kinetic | Potential) at different timesteps
#       - log file - all terminal output directed to a file
#       - trajectory file - output of the configurations at different timesteps
#       - last configuration file - the configuration at the last timestep

# Enter parent directory
cd .. 
```
