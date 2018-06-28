@if [%1]==[OvmfPkg] goto OvmfPkg
@if [%1]==[DuetPkg] goto DuetPkg
@goto OvmfHelp

:DuetPkg

@Echo "======== DuetPkg =============="

@set QEMU_PARAMETER=
@set QEMU_LOG=DuetPkg

@goto QemuRun

:OvmfPkg

@Echo "======== Ovmf3264 =============="

@set QEMU_PARAMETER=-L Build\Ovmf3264\DEBUG_VS2015x86\FV\ --bios OVMF.fd 
@set QEMU_LOG=Ovmf3264

@goto QemuRun
@goto end

:QemuRun

@set QEMU_HDA=-hda ..\FreeDos.img
@set QEMU_HDB=-hdb fat:..\Disk\
@set QEMU_HDC=-hdc fat:..\Disk2
@set QEMU_HDC=
@set QEMU_HDD=-cdrom ..\ubuntu-16.10-desktop-amd64.iso
@set QEMU_HDD=

@set QEMU_HEAD="C:\Program Files\qemu\qemu-system-x86_64.exe" -m 1G %QEMU_HDA% %QEMU_HDB% %QEMU_HDC% %QEMU_HDD%

@echo %QEMU_LOG% > %QEMU_LOG%.log
@echo %QEMU_LOG%debug > %QEMU_LOG%debug.log

@%QEMU_HEAD% %QEMU_PARAMETER% -serial file:%QEMU_LOG%.log -debugcon file:%QEMU_LOG%debug.log -global isa-debugcon.iobase=0x402 

goto end

:OvmfHelp
@echo Invalid parameter!
@echo Usage: "Ovmf [OvmfPkg|DuetPkg]"

:end