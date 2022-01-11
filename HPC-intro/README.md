# HPC-intro

This is a summary, (with small tips and tricks) of a more [detailed presentation](https://imperialcollegelondon.app.box.com/s/kwjxbd5bc87w296wo0m7fdwo9jct5vvs) given by the Graduate School and the Research Computing Service at Imperial College London. Any feedback is welcome.

_Last updated by Shanil Panara on 15/12/2021._

## 🔐 Step 0: Authorisation

You must first be granted access to the HPC before you can use it, your supervisor will need to contact the HPC on your behalf.

## 🌐 Step 1: Internet

Before logging in on the HPC, you will need to either be using [**VPN**](https://www.imperial.ac.uk/admin-services/ict/self-service/connect-communicate/remote-access/virtual-private-network-vpn/) (off-campus) or the **Imperial-WPA wifi** (on-campus)

## 🪵 Step 2: Logging in/out

To login, you can use a Linux/Mac or Windows terminal (or the [interactive rcs terminal online](https://login.rcs.ic.ac.uk)) and type the command:

```
ssh your_username@login.hpc.ic.ac.uk
```

It should prompt you for a password, which is the same as your normal password.

To logout, use the `exit` command.

---

**(optional) Log-in shortcut**

We can log in with fewer keystrokes, something along the lines of, ```ssh $HPC```, if we add the username to a variable `HPC` in our environment. If using Linux/Mac shell, we can edit the `.bashrc` file to achieve this.

- Go to your root directory `cd`

- Open file in terminal (using the nano editor):  `nano .bashrc`

- Add the line `export HPC=your_username@login.hpc.ic.ac.uk`.
- Save by using `Ctrl` + `S`
- Exit by using `Ctrl` + `X`
- Close & re-open your terminal, or manually run the `.bashrc` file  using `source ~/.bashrc`

You can now log in using ```ssh $HPC```

_(Note: the .bashrc file is always executed on the start-up of your terminal)_

## 📂 Step 3: The Environment & Files
Once you've logged in, if you've never seen Linux or bash before, it may seem like a very foreign environment to you. But don't be alarmed, it's not that bad...

- here is a quick list of [common bash commands](/HPC-intro/BASH_COMMANDS.md)

**IMPORTANT:**

- When you log in, you're on what is called a _login node_, this is a shared computing space.
- DO NOT execute any simulations or computations here.
- This is done using the _cluster resource manager_. (step 4)

---

### (a) File Structure

All computers in the HPC are connected to one parallel filesystem - the **Research Data Store (RDS)**. When you log in, you'll likely be in the home directory, if not then you'll see two, maybe 3 folders:

- `home` (your home directory) - `cd ~`
    - 1 TB allocation
    - personal working space
- `ephemeral` (temporary storage) - `cd ../ephemeral`
    - _unlimited_ allocation (**files deleted after 30 days**)
    - additional personal working space
- `projects` (allocated project space) - `cd ../projects`
    - if your supervisor has an extra allocation, you will see it

Check your usage and allocation using the `quota -s` command.

---

### (b) Transferring files to and from the RDS

1. Without using the terminal (windows)

    When transferring files, it may be easier to simply drag and drop, rather than using the terminal. For Windows systems, you can add the HPC data store as a network drive - see this [video](https://vimeo.com/302461989). Though, this doesn't always work... for those cases, and otherwise, we can use the `scp` command.

2. Using the terminal

    First ensure you are in your local terminal. Then we can use `scp <SourceFile(s)> <TargetFolder>`

    - Copying from local to remote, e.g.

    ```bash
    cd my_files             # move to folder with files to copy
    scp file.txt $HPC:~     # copy to home directory on the HPC
    ```
    - Copying from remote to local, e.g.

    ```bash
    cd my_results           # move to local folder where you want to store the
                            # files from the HPC

    scp $HPC:~/results/* .  # copy all files in the results folder on the HPC
                            # to the local folder (don't forget the dot)
    ```
---

### (c) Downloading files from the internet

This is actually really simple:

- from your browser, copy the URL for a file you'd like to download
- in the terminal type: `wget <pasted_link>`

## 👩🏾‍💼 Step 4: The Resource Manager

The resource manager takes care of:

- *sorting* your requests into **job** classes
- *scheduling* your requests
- *starting* jobs when compute resources become available
- *monitoring* jobs
- *producing* logs
- *tracking* all available hardware resources & how busy they are

We communicate with the resource manager using a **shell script** (aka job script, or PBS script).

- On the HPC, the resource manager is PBS, i.e. the Portable Batch System.
- All users of the HPC submit jobs in the form of a PBS script
- This tells the cluster what you want to run, and how to run it.

---

### (a) `example_script.pbs`

```ruby
                                # --- setup --- #
#PBS -N exampleScript
#PBS -l walltime=24:00:00
#PBS -l select=1:ncpus=1:mem=96gb:ngpus=1:gpu_type=P1000
#PBS -J 50-100:5

# load cuda module into environment
# and any other modules you require
module load cuda/9.2

# Change into the directory where script is submitted from
cd $PBS_O_WORKDIR

                               # --- execute tasks --- #

# Print name of compute node job was started on
echo "Started on `/bin/hostname`"

# Print index of the array for this job
echo "${PBS_ARRAY_INDEX}"

# outputs the array of the job into a file
FILENAME="index_${PBS_ARRAY_INDEX}.out"
echo "this is the array index ${PBS_ARRAY_INDEX}" > $FILENAME

```
- The `#PBS` is a special command which is recognised by the resource manager

    - Many different **flags** (e.g. `-N`, `-l`, `-J`,...) can be used to specify different options for the jobs you run.
    - The ones above are sufficient for a GPU job.
    - **\# Setup explanation:**

        1. Set the name of the job

        2. Set the max time you expect the job to run (24h)

        3. Select 1 GPU of type 'P1000'

        4. Run 11 copies of this job (-J 50-100:5)

    - Further documentation can be found online

- `#PBS -l select:...` - using a GPU (and choosing job resources)

    - There are a range of different GPU's (and other types of processors) on the HPC which you can specify to be used to run your job.
    - Here, we have used the P1000 GPU, which is recommended for tasks such as MD simulations.
    - [This link](https://www.imperial.ac.uk/admin-services/ict/self-service/research-support/rcs/computing/job-sizing-guidance/) provides guidance on the different processors, different types of jobs, and how to specify them in the PBS script.


- `-J 50-100:5` - Array jobs & `$PBS_ARRAY_INDEX`
    - The environment variable `$PBS_ARRAY_INDEX` gives each subjob an index from the array. Here, they are each separated by a value of 5.
    - All the subjobs are run independently of one another
    - This is a powerful way of running multiple jobs using the same script, examples would include:
        - A molecular dynamics simulation at different temperatures: where the line `#PBS -J 30-80:5` in the PBS script could execute the same script at 30C, 35C, ... 75C, and 80C, if the `$PBS_ARRAY_INDEX` variable is appropriately used.
        - Changing the output file name for each job (as is shown in the script above).

- `cd $PBS_O_WORKDIR`
    - It is necessary to change into the directory where the job was submitted from.
    - This is because each job is run in a private temporary directory created just for the job, and deleted once it is finished.


---

### (b) running/monitoring/deleting jobs

There are a set of special commands to communicate with the resource manager. Type these directly into the HPC terminal.

- `qsub` - Submitting a *batch* job to the queue, we use the **q**ueue **sub**mit command.
    ```
    qsub example_script.pbs <optional: additional flags here>
    ```
    Additional flags should be written exactly as they are in the PBS script file, without the #PBS at the start.

    Once you submit a job to the queue, it may take a while to start running as the resource manager will only start running the job when the right resources become available.

    - **As a general rule, the smaller the resource request, the less time the job will spend queuing.**

- `qstat` - Monitoring the progress of a job.

    ```
    qstat               # shows a brief summary
    qstat -T -t -w      # shows a expanded summary (for all array jobs individually)
    qstat -s            # -s adds a reason why the job hasn't started
    qstat -T -t -w -s   # the flags can also be stacked like this
    ```
    The column "S" can have a few different values:
    - "Q" - queued
    - "R" - running
    - "C" - completed
- `qdel` - Removing a job from the queue.

    ```
    qdel [jobid]
    qdel 12345678       # deletes job
    qdel 12345678[10]   # this will not work! sub-jobs have ID's like this
                        # but can't be individually deleted
    ```
    When a job is completed, it will disappear from the queue.

## 🧑🏾‍💻 Step 5: Modules

This possibly should have come before step 4. But it is what it is ;)

As was seen in the [script above](#a-example_script.pbs), before you execute your code we need to set up the environment for it. This entails **loading modules** such that you can use a software package.

---

### Loading modules already available on the HPC

These are the commands you might need:

```ruby
module avail                # lists all available modules on the HPC
module avail matlab         # lists all versions of a module that exist (if they exist)
module load matlab          # load a module
module unload matlab        # unload a module
module load matlab/R2018a   # load a specific version
module list                 # lists all loaded modules
module purge                # unloads all loaded modules
```
---

### Loading/downloading modules which are not installed on HPC

There may be certain software packages which are not installed on the HPC. In this case, you can either:

### (a) Check if the package is available on Anaconda

```ruby
module load anaconda3/personal      # load anaconda
anaconda-setup                      # set up only required once on your RDS

conda create -n masters python=3.8  # create new environment called masters
                                    ## with python 3.8 installed

source activate masters             # activate masters environment

conda env list                      # list environments created on conda

conda install scipy                 # install scipy package in the environment
conda install scipy=1.2.0           # a specific version can also be specified

conda deactivate                    # deactivate environment
```

### (b) Ask the RCS to install a software for you

Here you will need to submit a request via [ICT ASK](https://imperial.service-now.com/ask) - search for "RCS Software Install Request"

### (c) Download (using [wget](#c-downloading-files-from-the-internet)) to your home directory

- Here, I recommend you create a `programs/` folder to download & store programmes in.

- Upon downloading, you may need to build the software - each software will have specific instructions on how to do this.

- In order to more simply call the executable directly, e.g.
    ```ruby
    oxDNA <input> <output>
    ```

    you will need to create what is called an `alias` for the executable. This is simply a custom command for a specific path. This `alias` can be added in the `.bashrc` file in your home directory.

    ```
    cd ~            # go to home directory
    ls -a           # lists ALL directories, files and hidden files/folders
    nano .bashrc    # opens the .bashrc file in the nano text editor
    ```
    Then in the file you will need to add the specific path to the executable, e.g.
    ```
    alias oxDNA="/rds/general/user/sp2017/home/programs/oxDNA/build/bin/oxDNA"
    ```
    and once you have saved and exited the file, there is a final step.

    You will need to either:
    - Close & re-open your terminal.
    - Or, manually run the `.bashrc` file  using `source ~/.bashrc`

---

# Introduction Completed 🎉 Happy HPCing 👩🏾‍💻
