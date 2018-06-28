/**************************************************************
 *      lddos.s        Copyright(C) 2003-2018 Max Wu
 *
 *  Main file of loader from MS-DOS
 *
 **************************************************************/

///////////////////////////////////////////////////////////////
// Include files
///////////////////////////////////////////////////////////////
#include "lib16s.h"

///////////////////////////////////////////////////////////////
// public function body
// beause it is asm, public function has beter put in the begin
///////////////////////////////////////////////////////////////
/**************************************************************
 * function:    lddos_start
 *
 * parameter:   image name
 *
 * return:      none
 *
 * description: main routine of loader
 **************************************************************/
.code16
.global lddos_start
lddos_start:

#if (1)
    /*
     *  Show loader copy right
     */
        mov     $lddos_str_name,%si
        call    bios_putstr

        mov     $lddos_str_ver,         %si
        call    bios_putstr

        mov     $lddos_str_build,       %si
        call    bios_putstr

        mov     $lddos_str_date,        %si
        call    bios_putstr

        mov     $lddos_str_space,       %si
        call    bios_putstr

        mov     $lddos_str_time,        %si
        call    bios_putstr

        mov     $lddos_str_copyright,   %si
        call    bios_putstr
#endif
    /*
     * Call E820 for read system memory layout
     */
        // X86_E820_GET()
    /*
     *  Test A20 if enable or not. If not, then exit
     */
        // X86_A20_TEST(a20_ok)
        X86_A20_ENABLE()

    a20_ok:

    /*
     *  Enter unreal mode, and test it
     *  Now, it will hang up after enter CodeView
     */
        mov     $UNREAL_SEL,    %bx
        # mov     $(3<<3),    %bx
        call    x86_enter_mode                      # enter unreal mode

//        DBG16_CALL(unreal_test)
        X86_E820_GET()

    /*
     *  Get image name from DOS API
     */
        mov     $lddos_kf_name, %di
        call    dos_get_kname

    /*
     *  open kernel image file by DOS API
     */
        mov     $0x3D00,        %ax
        mov     $lddos_kf_name, %dx
        int     $0x21
        mov     %ax,            lddos_kf_id

        jc      lddos_fopen_error                   # open file error

    /*
     *  Get kernel image and transfer into buffer
     */
        mov     lddos_kf_id,    %bx
        call    get_buffer

    /*
     *  Close file by DOS API
     */
        movb    $0x3E,          %ah
        mov     lddos_kf_id,    %bx
        int     $0x21

    /*
     * Fill image header
     */
        call    x86_fill_desctriptor

    /*
     * Enter kernel image
     */
        call    x86_enter_pmode

        jmp     lddos_enter_rmode

    /*
     *  string error for open file error
     */
    lddos_fopen_error:
        mov     $lddos_of_error,%si
        call    bios_putstr

    /*
     * Exit unreal mode, enter real mode
     */
    lddos_enter_rmode:
        mov     $(1<<3),      %bx
        # mov     $(3<<3),      %bx
        call    x86_enter_mode                      # enter real mode

    /*
     *  End of program
     */
    lddos_exit:
        mov     $0x4C00,        %ax
        int     $0x21
lddos_end:

///////////////////////////////////////////////////////////////
// global variable body
///////////////////////////////////////////////////////////////
lddos_kf_name:        .fill   13, 1, 0
lddos_kf_id:          .word   0

lddos_of_error:       .string     "Open file error\r\n"

lddos_str_name:       .string     "Sheperd Loader (Version "
lddos_str_ver:        .string     VERSION
lddos_str_build:      .string     ")\r\nBuild time: "
lddos_str_date:       .string     __DATE__
lddos_str_space:      .string     ", "
lddos_str_time:       .string     __TIME__
lddos_str_copyright:  .string     "\r\nCopyright(C) 2003 L.S. Wu\r\n\r\n"

///////////////////////////////////////////////////////////////
// private function body
///////////////////////////////////////////////////////////////
/**************************************************************
 * None
 **************************************************************/

///////////////////////////////////////////////////////////////
// debug function
///////////////////////////////////////////////////////////////
/**************************************************************
 * None
 **************************************************************/
#if(DEBUG)
#else   // DEBUG
#endif  // DEBUG

///////////////////////////////////////////////////////////////
// LOG
///////////////////////////////////////////////////////////////
// 2004 05 22 -- 0002 fix A20 testing routine
// 2004 02 01 -- 0001 creat this log
