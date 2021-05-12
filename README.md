# LoadDuetPkg

Target:
  Load and run EDK2 DuetPkg from DOS.

Source code installation:

  Merge edk2\ folder into official edk2 project.

Toolchain:
  1. DuetPkgPreBuild.sh:
      GCC 4.8 on Linux
  2. edk2:
      VS2015x86

Build:
  1. run DuetPkgPreBuild.sh
      OUTPUT: lddos\lddos.com
              edk2\DuetPkg\BootSector\bin\efi64.com2
  2. run official edk2 build in edk2 folder
      OUTPUT: edk2\Build\DuetPkgX64\DEBUG_VS2015x86\FV\Efildr16Pure

Run:
  1. environment:
      FreeDos or MS-DOS w/o high memory installed.

  2. Run command:
      lddos.com Efildr16Pure

Test environment:
  1. Qemu
  2. Dell XPS M1210

# Video
[![LoadDuetPkg](http://img.youtube.com/vi/Cq7fEUFwsYI/0.jpg)](http://www.youtube.com/watch?v=Cq7fEUFwsYI "LoadDuetPkg")

# Note:
  1. Active platform: DuetPkg/DuetPkgX64.dsc only. Excluding DuetPkg/DuetPkgIa32.dsc
  2. It did not test it widely/strickly.

