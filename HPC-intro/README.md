# HPC-intro

## Step 0. Authorisation

You must first be granted access to the HPC before you can use it, your supervisor will need to contact the HPC on your behalf.

## Step 1: Internet

Before logging in on the HPC, you will need to either be using [**VPN**](https://www.imperial.ac.uk/admin-services/ict/self-service/connect-communicate/remote-access/virtual-private-network-vpn/) (off-campus) or the **Imperial-WPA wifi** (on-campus)

## Step 2: Logging in/out

To login, you can use a Linux/Mac or Windows terminal (or the [interactive rcs terminal online](https://login.rcs.ic.ac.uk)) and type the command:

```
ssh your_username@login.hpc.ic.ac.uk
```

It should prompt you for a password, which is the same as your normal password.

To logout, use the `exit` command.

### (optional) Log-in shortcut

We can log in with fewer keystrokes, something along the lines of, ```ssh $HPC```, if we add the username to a variable `HPC` in our environment. If using Linux/Mac shell, we can edit the `.bashrc` file to achieve this.

- Go to your root directory `cd`

- Open file in terminal (using the nano editor):  `nano .bashrc`

- Add the line `export HPC=your_username@login.hpc.ic.ac.uk`.
- Save by using `Ctrl` + `S`
- Exit by using `Ctrl` + `X`
- Close & re-open your terminal, or manually run the `.bashrc` file  using `source ~/.bashrc`

You can now log in using ```ssh $HPC```

_(Note: the .bashrc file is always executed on the start-up of your terminal)_

## Step 3: The Environment & Files
Once you've logged in, if you've never seen Linux or bash before, it may seem like a very foreign environment to you. But don't be alarmed, it's not that bad... see a quick list of common bash commands [here](/HPC-intro/BASH_COMMANDS.md)

**IMPORTANT: When you log in, you're on what is called a _login node_, this is a shared computing space. DO NOT execute any simulations or computations here. This is done using the _cluster resource manager_.** (step 4)

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

### (b) Transferring files

1. Without using the terminal (windows)

    When transferring files, it may be easier to simply drag and drop, rather than using the terminal. For Windows systems, you can add the HPC data store as a network drive - see this [video](https://vimeo.com/302461989). Though, this doesn't always work... in those cases we can use the `scp` command.

2. Using the terminal

    First ensure you are in your local terminal. Then we can use `scp <SourceFile(s)> <TargetFolder>`

    - Copying from local to remote, e.g.

    ```bash
    cd my_files         # move to folder with files to copy
    scp file.txt $HPC:~ # copy to home directory on the HPC
    ```
    - Copying from remote to local, e.g.

    ```bash
    cd my_results           # move to local folder where you want to store the
                            # files from the HPC

    scp $HPC:~/results/* .  # copy all files in the results folder on the HPC
                            # to the local folder (don't forget the dot)
    ```

### (c) Downloading files from the internet

This is actually really simple:

- from your browser, copy the URL for a file you'd like to download
- in the terminal type: `wget <pasted_link>`

## Step 4: The Resource Manager

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

### Example Script

```PB
                        # --- setup --- #
# name of job
#PBS -N exampleScript
# job will run at most 24h
#PBS -l walltime=24:00:00
# select 1 GPU of type 'P1000' (see link below on GPU selection)
#PBS -l select=1:ncpus=1:mem=96gb:ngpus=1:gpu_type=P1000
# range:step of array job index accessed using PBS_ARRAY_INDEX
#PBS -J 50-80:5

# load cuda module into environment
module load cuda/9.2

# changes into directory where script was submitted from
cd $PBS_O_WORKDIR

                       # --- execute --- #

# prints name of compute node job was started on
echo "Started on `/bin/hostname`"

# prints index of the array for this job
echo "${PBS_ARRAY_INDEX}"

# outputs the array of the job into a file
FILENAME="index_${PBS_ARRAY_INDEX}.out"
echo "this is the array index ${PBS_ARRAY_INDEX}" > $FILENAME

```

- Using a GPU

    - Click [here](https://www.imperial.ac.uk/admin-services/ict/self-service/research-support/rcs/computing/job-sizing-guidance/gpu/) for guidance on selecting GPU Type

    - Here, we have used the P1000 GPU, which is recommended for tasks such as MD simulations.

- Array jobs

    - This is a powerful way of running multiple jobs using the same script, where one variable can be changed.
    - For example:
        - a MD simulation at different temperatures: where the line `#PBS -J 50-80:5` in the PBS script would execute the same script at 50C, 55C, ... 75C, and 80C.
        - changing the output file name for each job (as is shown in the script above)

