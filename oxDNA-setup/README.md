# oxDNA setup

You should be able to follow the instructions on the [oxDNA GitHub](https://github.com/lorenzo-rovigatti/oxDNA).

---

Below, I (/we) will put any small tips and tricks for issues when and as they occur...

### Compiling w CUDA

...ensure all the required libraries are installed (`cmake` and `g++` as listed in the link above)! Also remember the -DCUDA=1 flag. (_shanil_: I had a lot of trouble with this, but a clean install fixed my issues.)

### WSL2 & CUDA

In order to run oxDNA locally on Windows Subsystem for Linux with a GPU... you need WSL2 and the set up for CUDA has to be done very specifically.

Follow these instructions on the [nvidia website](https://docs.nvidia.com/cuda/wsl-user-guide/index.html) (_shanil_: I followed all of step 3, and 4.2.6 specifically)