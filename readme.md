# cflow-mingw

## Building
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

## Building x64
Install msys-2 for x86_64 (these instructions are helpful: http://stackoverflow.com/a/30071634). Then run as above (correcting path etc to run correct tools).

## License
GPL v3 from cflow.
