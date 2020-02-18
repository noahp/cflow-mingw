# cflow-mingw

## cflow-1.4

### Building
Download and install mingw and msys (base configuration for each).
I used msys 1.0 and mingw "TDM-GCC 4.7.1 32-bit".

Add to windows path.
Run the following commands in the cflow distribution directory-
```shell
bash configure  
make
```

After building, executable is available under src.
Prebuilt executable stored in project root.

### Building x64
Install msys-2 for x86_64 (these instructions are helpful: http://stackoverflow.com/a/30071634). Then run as above (correcting path etc to run correct tools).

## cflow-1.6

### Building

I installed msys2: https://www.msys2.org/

Then installed some packages:

```bash
pacman -S --needed \
  base-devel \
  mingw-w64-i686-toolchain \
  mingw-w64-x86_64-toolchain \
  msys2-devel
```

To run the build:

```bash
# include mingw in PATH
export PATH=$PATH:/c/msys64/mingw32/bin

./configure
make -j 6
```

## License
cflow sources are GPL v3. everything else is public domain.
