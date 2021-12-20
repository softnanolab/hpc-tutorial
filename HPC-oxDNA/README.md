# HPC-oxDNA



_Last updated by Shanil Panara on 20/12/2021._

You'll need three files for the simulation!

## 1. PBS file example for an oxDNA simulation at different temperatures

```ruby
#PBS -N exampleScript
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=1:mem=96gb:ngpus=1:gpu_type=P1000
#PBS -J 50-100:5

# 1. Set the name of the job
# 2. Set the max time you expect the job to run (24h)
# 3. Select 1 GPU of type 'P1000'
# 4. Run 3 copies of this job (-J 30-50:10)


# Set up environment
module load cuda/9.2
cd $PBS_O_WORKDIR/


# Set up variable names
JOB_NAME="01_tetrahedron"
T=${PBS_ARRAY_INDEX}
NAME="${JOB_NAME}-${T}C"


# Print the details of the GPU you are using
nvidia-smi


# Minimise
/rds/general/user/sp2017/home/programs/oxDNA/build/bin/oxDNA oxdna.min.in \
    topology=$JOB_NAME.top \
    conf_file=$JOB_NAME.conf \
    lastconf_file=$NAME-min.conf \
    T=${T}C
# Here, we have specified
# - the input: `topology` and `conf`iguration file names for the oxDNA **minimisation**
# - the output: "minimised" configuration file (taken as the last configuration)


# Run
/rds/general/user/sp2017/home/programs/oxDNA/build/bin/oxDNA oxdna.sim.in \
    T=${T}C \
    topology=$JOB_NAME.top \
    conf_file=$NAME-min.conf \
    energy_file=$NAME-energy.dat \
    log_file=$NAME.log \
    trajectory_file=$NAME-traj.conf \
    lastconf_file=$NAME-last.conf
# Here, we have specified:
# - the input: `topology` and `conf`iguration files for the oxDNA **simulation**
# - the output:
#       - energy file - output (Total | Kinetic | Potential) at different timesteps
#       - log file - all terminal output directed to a file
#       - trajectory file - output of the configurations at different timesteps
#       - last configuration file - the configuration at the last timestep
```

## Explanation
### PBS Setup
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
4. Run 3 copies of this job (-J 30-50:10)
    ```ruby
    #PBS -J 50-100:5
    ```

### Environment and files
- Set up environment
    ```ruby
    module load cuda/9.2
    cd $PBS_O_WORKDIR/
    ```

- Set up variable names
    ```ruby
    JOB_NAME="01_tetrahedron"
    T=${PBS_ARRAY_INDEX}
    NAME="${JOB_NAME}-${T}C"
    ```

### Execute
- Run minimisation
    ```ruby
    # Minimise
    /rds/general/user/sp2017/home/programs/oxDNA/build/bin/oxDNA oxdna.min.in \
        topology=$JOB_NAME.top \
        conf_file=$JOB_NAME.conf \
        lastconf_file=$NAME-min.conf \
        T=${T}C
    ```
    Here, we have specified
    - the input: `topology` and `conf`iguration file names for the oxDNA **minimisation**
    - the output: "minimised" configuration file (taken as the last configuration)

- Run simulation
    ```ruby
    /rds/general/user/sp2017/home/programs/oxDNA/build/bin/oxDNA oxdna.sim.in \
        T=${T}C \
        topology=$JOB_NAME.top \
        conf_file=$NAME-min.conf \
        energy_file=$NAME-energy.dat \
        log_file=$NAME.log \
        trajectory_file=$NAME-traj.conf \
        lastconf_file=$NAME-last.conf
    ```
    Here, we have specified:
    - the input: `topology` and `conf`iguration files for the oxDNA **simulation**
    - the output:
          - energy file - output (Total | Kinetic | Potential) at different timesteps
          - log file - all terminal output directed to a file
          - trajectory file - output of the configurations at different timesteps
          - last configuration file - the configuration at the last timestep
```