##  Simple linux commands

Below is a list of common linux (bash) commands.

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
rm <*.log>          # delete all files ending with log - * can be used
                    # anywhere in the expression
rm -r <folder>      # removes the folder & all it's contents

cat <file>          # output contents of file in terminal
cat > <file>        # creates a new file
tail -n <file>      # displays the last n lines of a file
head -n <file>      # displays the first n lines of a file

clear               # clear the contents of the terminal

sudo apt-get <...>  # apt-get is a powerful package manager, and is used
                    # to install/update/remove packages on some linux systems.

```