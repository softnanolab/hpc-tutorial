# HPC-intro

## 0. Authorisation

You must first be granted access to the HPC before you can use it, your supervisor will need to contact the HPC on your behalf.

## 1. Internet

Before logging in on the HPC, you will need to either be using [**VPN**](https://www.imperial.ac.uk/admin-services/ict/self-service/connect-communicate/remote-access/virtual-private-network-vpn/) (off-campus) or the **Imperial-WPA wifi** (on-campus)

## 2. Logging in/out

To login, you can use a Linux/Mac or Windows terminal (or the [interactive rcs terminal online](https://login.rcs.ic.ac.uk)) and type the command:

```ssh your_username@login.hpc.ic.ac.uk```

It should prompt you for a password, which is the same as your normal password.

To logout, use the `exit` command.

### 2.0 Shortcuts

We can log in with fewer keystrokes, something along the lines of, ```ssh $HPC```, if we add the username to a variable `HPC` in our environment. If using Linux/Mac shell, we can edit the `.bashrc` file to achieve this.

- Go to your root directory `cd`

- Open file in terminal (using the nano editor):  `nano .bashrc`

- Add the line `export HPC=your_username@login.hpc.ic.ac.uk`.
- Save by using `Ctrl` + `S`
- Exit by using `Ctrl` + `X`
- Close & re-open your terminal, or manually run the `.bashrc` file  using `source ~/.bashrc`

You can now log in using ```ssh $HPC```

_(Note: the .bashrc file is always executed on the start-up of your terminal)_

## 3. The Environment
Once you've logged in, if you've never seen Linux or bash before, it may seem like a very foreign environment to you. But don't be alarmed, it's not that bad...

### 3.0 Simple linux commands

```bash
cd <file or path>   # change directory
cd                  # change to root directory
cd ~                # change to root directory
cd ..               # change to parent directory

ls                  # list directory contents

touch <file>        # create a blank file
mkdir <file>        # create an empty folder

mv <file1> <file2>  # move/rename a file - you can also specify a path

cp <file1> <file2>  # copy a file - you can also specify a path

rm <file>           # delete a file
rm <*.log>          # delete all files ending with log - * can be used anywhere in the expression
rm -r <folder>      # removes the folder & all it's contents

cat <file>          # output contents of file in terminal
cat > <file>        # creates a new file
tail -n <file>      # displays the last n lines of a file
head -n <file>      # displays the first n lines of a file

clear               # clear the contents of the terminal

sudo apt-get <...>  # apt-get is a powerful package manager, and is used to install/update/remove packages on some linux systems.

```

### 3.1 Transferring files

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
cd my_results           # move to local folder where you want to store the files from the HPC
scp $HPC:~/results/* .  # copy all files in the results folder on the HPC to the local folder (don't forget the dot)
```