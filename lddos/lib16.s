/**************************************************************
 *      lib16.s        Copyright(C) 2003-2018 Max Wu
 *
 * libarary of loader from MS-DOS
 *
 **************************************************************/

///////////////////////////////////////////////////////////////
// Include files
///////////////////////////////////////////////////////////////
#include "lib16s.h"
#include "x86boot.h"

.macro DeadLoop2

FlagDeadLoop2:
    # movb    $0x25, %al
    # movb    $0x0c, %ah
    # movl    $0xb8000, %edi
    # movw    %ax, (%edi)

    jmp     FlagDeadLoop2

.endm

.macro DeadLoop

FlagDeadLoop:
    mov     $0xb800, %ax
    mov     %ax, %ds
    movb    $0x24, %al
    movb    $0x0c, %ah
    mov     $0x0, %di
    mov     %ax, (%di)

    jmp     FlagDeadLoop

.endm

.macro FindString16

    mov     $0x00200000, %eax
    mov     %eax,      %edi
    mov     $0x20000,  %ecx
    xor     %eax,         %eax
    mov     $0x0CB424B0,  %eax
    # cld
    # addr32 repne scasd
    # repne scasl

    cmp     %eax, %ds:(%edi)
    DeadLoop2
    je      FindString
    dec     %ecx
    inc     %edi

    cmp     $0, %ecx
    je      findEnd

FindString:

    mov     $0xB8000, %esi
    sub     $4,      %edi

##########################################################
#Show7
    mov     %edi,     %eax
    shr     $28,     %eax
    and     $0x0F,   %eax
    cmp     $0x0A,   %eax

    jl      ShowN7

    sub     $0x0A,   %al
    add     $0x41,   %al
    jmp     Show7

ShowN7:
    add     $0x30,   %al

Show7:
    movb    $0x0c, %ah
    movw    %ax, (%esi)

##########################################################
#Show6
    mov     %edi,     %eax
    shr     $24,      %eax
    and     $0x0F,   %eax
    cmp     $0x0A,   %eax

    jl      ShowN6

    sub     $0x0A,   %al
    add     $0x41,   %al
    jmp     Show6

ShowN6:
    add     $0x30,   %al

Show6:
    add     $2,    %si
    movb    $0x0c, %ah
    movw    %ax, (%esi)

##########################################################
#Show5
    inc     %edi
    mov     %edi,     %eax
    shr     $20,      %eax
    and     $0x0F,   %eax
    cmp     $0x0A,   %eax

    jl      ShowN5

    sub     $0x0A,   %al
    add     $0x41,   %al
    jmp     Show5

ShowN5:
    add     $0x30,   %al

Show5:
    add     $2,    %esi
    movb    $0x0c, %ah
    movw    %ax, (%esi)

##########################################################
#Show4
    mov     %edi,     %eax
    shr     $16,     %eax
    and     $0x0F,   %eax
    cmp     $0x0A,   %ax

    jl      ShowN4

    sub     $0x0A,   %al
    add     $0x41,   %al
    jmp     Show4

ShowN4:
    add     $0x30,   %al

Show4:
    add     $2,    %esi
    movb    $0x0c, %ah
    movw    %ax, (%esi)

##########################################################
#Show3
    mov     %edi,     %eax
    shr     $12,     %eax
    and     $0x0F,   %eax
    cmp     $0x0A,   %eax

    jl      ShowN3

    sub     $0x0A,   %al
    add     $0x41,   %al
    jmp     Show3

ShowN3:
    add     $0x30,   %al

Show3:
    movb    $0x0c, %ah
    movw    %ax, (%esi)

##########################################################
#Show2
    mov     %edi,     %eax
    shr     $8,      %eax
    and     $0x0F,   %eax
    cmp     $0x0A,   %eax

    jl      ShowN2

    sub     $0x0A,   %al
    add     $0x41,   %al
    jmp     Show2

ShowN2:
    add     $0x30,   %al

Show2:
    add     $2,    %si
    movb    $0x0c, %ah
    movw    %ax, (%esi)

##########################################################
#Show1
    inc     %edi
    mov     %edi,     %eax
    shr     $4,      %eax
    and     $0x0F,   %eax
    cmp     $0x0A,   %eax

    jl      ShowN1

    sub     $0x0A,   %al
    add     $0x41,   %al
    jmp     Show1

ShowN1:
    add     $0x30,   %al

Show1:
    add     $2,    %esi
    movb    $0x0c, %ah
    movw    %ax, (%esi)

##########################################################
#Show0
    mov     %edi,     %eax
    and     $0x0F,   %eax
    cmp     $0x0A,   %ax

    jl      ShowN0

    sub     $0x0A,   %al
    add     $0x41,   %al
    jmp     Show0

ShowN0:
    add     $0x30,   %al

Show0:
    add     $2,    %esi
    movb    $0x0c, %ah
    movw    %ax, (%esi)

findEnd:

    DeadLoop

.endm

///////////////////////////////////////////////////////////////
// debug function
///////////////////////////////////////////////////////////////
/**************************************************************
 * function:    lib16_putreg16
 *
 * parameter:   %ax
 *
 * return:      none
 *
 * description: put register value to console
 **************************************************************/
.code16
#if(DEBUG)
lib16_putreg16:
        pushl   %eax
        pushl   %ebx
        pushl   %ecx
        pushl   %esi
        push    %ds
        push    %es
        pushf

        mov     %cs,        %bx
        mov     %bx,        %ds
        mov     %bx,        %es

        mov     %ax,        %bx
        shr     $12,        %bx
        cmpb    $10,        %bl
        jb      reg_dig0
        add     $55,        %bx
        jmp     reg_bit0
    reg_dig0:
        add     $0x30,      %bx
    reg_bit0:
        movb    %bl,        %ss:(lib16_putreg16_buff)
        mov     %ax,        %bx
        shr     $8,         %bx
        and     $0x0F,      %bx
        cmpb    $10,         %bl
        jb      reg_dig1
        add     $55,        %bx
        jmp     reg_bit1
    reg_dig1:
        add     $0x30,      %bx
    reg_bit1:
        movb    %bl,        %ss:(lib16_putreg16_buff+1)
        mov     %ax,        %bx
        shr     $4,         %bx
        and     $0x0F,      %bx
        cmpb    $10,         %bl
        jb      reg_dig2
        add     $55,        %bx
        jmp     reg_bit2
    reg_dig2:
        add     $0x30,      %bx
    reg_bit2:
        movb    %bl,        %ss:(lib16_putreg16_buff+2)
        mov     %ax,        %bx
        and     $0x0F,      %bx
        cmpb    $10,         %bl
        jb      reg_dig3
        add     $55,        %bx
        jmp     reg_bit3
    reg_dig3:
        add     $0x30,      %bx
    reg_bit3:
        movb    %bl,        %ss:(lib16_putreg16_buff+3)

        DBG16_PUTSTR(lib16_putreg16_buff)

        popf
        pop     %es
        pop     %ds
        popl    %esi
        popl    %ecx
        popl    %ebx
        popl    %eax
        ret

lib16_putreg16_buff:
    .string  "     "

/**************************************************************
 * function:    unreal_test
 *
 * parameter:   none
 *
 * return:      none
 *
 * description: test big real mode function
 **************************************************************/
unreal_test:
        push    %ds
        push    %es
        push    %esi
        push    %edi
        push    %ax
        push    %cx
        pushf

        mov     $26,        %cx
        cld

        xorl    %esi,       %esi
        mov     %si,        %ds
        mov     %cs,        %si
        shll    $4,         %esi
        add     $mov_test_str,  %si

        xorl    %eax,       %eax
        mov     %ax,        %es
        movl    $0xB8100,   %edi

        .byte   0x67
        rep
        movsb

        popf
        pop     %cx
        pop     %ax
        pop     %edi
        pop     %esi
        pop     %es
        pop     %ds

        ret

mov_test_str:   .string     "s t r i n g   t e s t   1 "
#endif // DEBUG

///////////////////////////////////////////////////////////////
// public function body
///////////////////////////////////////////////////////////////
#if (A20_TEST)
/**************************************************************
 * function:    x86_a20_enable
 *
 * parameter:   none
 *
 * return:      none
 *
 * description: enable A20 line before enter switch mode
 **************************************************************/
.equ                 DELAY_PORT, 0x0ed # Port to use for 1uS delay
.equ                 KBD_CONTROL_PORT, 0x060 # 8042 control port     
.equ                 KBD_STATUS_PORT, 0x064 # 8042 status port      
.equ                 WRITE_DATA_PORT_CMD, 0x0d1 # 8042 command to write the data port
.equ                 ENABLE_A20_CMD, 0x0df # 8042 command to enable A20

Empty8042InputBuffer: 
        movw $0,%cx
Empty8042Loop: 
        outw    %ax, $DELAY_PORT            # Delay 1us
        inb     $KBD_STATUS_PORT, %al       # Read the 8042 Status Port
        andb    $0x2,%al                    # Check the Input Buffer Full Flag
        loopnz  Empty8042Loop               # Loop until the input buffer is empty or a timout of 65536 uS
        ret

x86_a20_enable:
#
# If INT 15 Function 2401 is not supported, then attempt to Enable A20 manually.
#
        movw $0x2401,%ax                    # Enable A20 Gate
        int $0x15
        jnc A20GateEnabled                  # Jump if it suceeded

        call    Empty8042InputBuffer        # Empty the Input Buffer on the 8042 controller
        jnz     Timeout8042                 # Jump if the 8042 timed out
        outw    %ax, $DELAY_PORT            # Delay 1 uS
        movb    $WRITE_DATA_PORT_CMD, %al   # 8042 cmd to write output port
        outb    %al, $KBD_STATUS_PORT       # Send command to the 8042
        call    Empty8042InputBuffer        # Empty the Input Buffer on the 8042 controller
        jnz     Timeout8042                 # Jump if the 8042 timed out
        movb    $ENABLE_A20_CMD, %al        # gate address bit 20 on
        outb    %al, $KBD_CONTROL_PORT      # Send command to thre 8042
        call    Empty8042InputBuffer        # Empty the Input Buffer on the 8042 controller
        movw    $25,%cx                     # Delay 25 uS for the command to complete on the 8042
Delay25uS: 
        outw    %ax, $DELAY_PORT            # Delay 1 uS
        loop    Delay25uS
Timeout8042: 

A20GateEnabled:

        ret

.code16
/**************************************************************
 * function:    x86_e820_get
 *
 * parameter:   none
 *
 * return:      None
 *
 * description:
 **************************************************************/
x86_e820_get:

        leal OffsetInLongMode, %eax
        xor  %ebx, %ebx
        mov  %cs,          %bx

        shll $4, %ebx
        addl $0x000000+0x6,%eax
        addl %ebx, %eax
        movl %eax, OffsetInLongMode 

        leal OffsetInProtectMode, %eax
        xor  %ebx, %ebx
        mov  %cs,          %bx
        shll $4, %ebx
        addl $0x000000+0x6,%eax
        addl %ebx, %eax
        movl %eax, OffsetInProtectMode 

        movl    $0,                   %ebx
        leal    MemoryMap,            %edi

MemMapLoop: 
        movl    $0xe820,              %eax
        movl    $20,                  %ecx
        movl    $0x534d4150,          %edx  # SMAP
        int     $0x15
        jc      MemMapDone
        addl    $20,                  %edi
        cmpl    $0,                   %ebx

        je      MemMapDone
        jmp     MemMapLoop

MemMapDone: 
        leal    MemoryMap,            %eax
        subl    %eax,                 %edi                  # Get the address of the memory map
        movl    %edi,                 MemoryMapSize         # Save the size of the memory map

        xorl    %ebx,                 %ebx
        movw    %cs,                  %bx                   # BX=segment
        shll    $4,                   %ebx                  # BX="linear" address of segment base
        leal    gdt(%ebx),            %eax                  # EAX=PHYSICAL address of gdt
        movl    %eax,                 (gdtr + 2)            # Put address of gdt into the gdtr
        leal    x86_idt(%ebx),        %eax                  # EAX=PHYSICAL address of idt
        movl    %eax,                 (x86_idtr + 2)        # Put address of idt into the idtr
        leal    MemoryMapSize(%ebx),  %edx                  # Physical base address of the memory map

        push    %es
        xor     %edi, %edi
        mov     %di,  %es
        movl    $(G_IDTR),            %edi
        movl    (x86_idtr),             %eax
        movl    %eax,                 %es:(%edi)
        movl    (x86_idtr + 2),         %eax
        movl    %eax,                 %es:2(%edi)
        movl    (x86_idtr + 4),         %eax
        movl    %eax,                 %es:4(%edi)
        movl    (x86_idtr + 6),         %eax
        movl    %eax,                 %es:6(%edi)

        pop %es
        ret

/**************************************************************
 * function:    x86_a20_test
 *
 * parameter:   none
 *
 * return:      al=1 A20 is enable, al=0 A20 is disable
 *
 * description: test if A20 line is enable ot disable
 **************************************************************/
x86_a20_test:
        push    %bx
        push    %si
        push    %di
        push    %ds
        push    %es
        pushf
    /*
     * %ds:(%di) = 0xFFFF : 0x80*4
     * %es:(%si) = 0x0000 : 0x80*4 + 0x10
     */
        movw    $0x0000,    %ax
        movw    %ax,        %es
        movw    $0xFFFF,    %ax
        movw    %ax,        %ds

        movw    $(0x80*4),  %si
        movw    %si,        %di
        addw    $0x10,      %si

        movw    $0x1234,    %ds:(%si)
        movw    %es:(%di),  %ax
        movw    %ds:(%si),  %bx

        cmp     %ax,        %bx
        je      a20_dis
        movb    $0x01,       %al
        jmp     a20_end
    a20_dis:
        movb    $0x00,       %al
    a20_end:

        popf
        pop     %es
        pop     %ds
        pop     %di
        pop     %si
        pop     %bx
        ret
#endif // A20_TEST

/**************************************************************
 * function:    x86_enter_mode
 *
 * parameter:   bx, selector number
 *
 * return:      none
 *
 * description: enter unreal/real mode
 **************************************************************/
x86_enter_mode:

        push    %ds
        push    %es
        push    %fs
        push    %gs
        push    %eax
    /*
     * Save the linear address of gdt to GDTR
     */
        xor     %eax,       %eax
        mov     %ds,        %ax
        shl     $4,         %eax
        add     $x86_gdt,   %eax
        mov     %eax,       (x86_gdtr+2)

        cli
    /*
     * 1. load GDT value into GDT register
     * 2. enter protected mode
     */
        lgdt    x86_gdtr
        mov     %cr0,   %eax
        orb     $0x01,  %al
        mov     %eax,   %cr0
    /*
     * move selector into %ds, %es, %fs, %gs
     */
        mov     %bx,    %ds
        mov     %bx,    %es
        mov     %bx,    %fs
        mov     %bx,    %gs
    /*
     * Leave protected mode, and keep limitation to 4GByte
     */
        mov     %cr0,   %eax
        and     $0xFE,  %al
        mov     %eax,   %cr0

        sti

        pop     %eax
        pop     %gs
        pop     %fs
        pop     %es
        pop     %ds

        ret

///////////////////////////////////////////////////////////////
// global variable body
///////////////////////////////////////////////////////////////
/**************************************************************
 * global variable for enter unreal mode
 *
 * Description: used for enter big real mode
 *
 * x86_gdtr:    point to GDT register buffer
 * x86_gdt:     point to global descriptor table address
 * x86_gdt0:    GDT 0, must be NULL
 * x86_gdt1:    GDT 1, beibg used for big real mode
 **************************************************************/
x86_gdtr:
    .word   x86_gdt_end - x86_gdt
    .long   x86_gdt

x86_gdt:
x86_gdt0:
    .word   0
    .word   0
    .byte   0
    .byte   0
    .byte   0
    .byte   0
x86_gdt1:               /* UNREAL MODE SELECTOR */
    .word   0xFFFF
    .word   0
    .byte   0
    .byte   0x92
    .byte   0xCF
    .byte   0
x86_gdt2:               /* REAL MODE SELECTOR */
    .word   0x0000
    .word   0
    .byte   0
    .byte   0x92
    .byte   0xCF
    .byte   0
x86_gdt_end:

///////////////////////////////////////////////////////////////
// public function body
///////////////////////////////////////////////////////////////
/**************************************************************
 * function:    dos_get_kname
 *
 * parameter:   DI, pointer to fill image name
 *
 * return:      none
 *
 * description: get kernel image name and put into buffer
 **************************************************************/
dos_get_kname:
        push    %si
        push    %ax
    /*
     * set source address
     */
        mov     $0x82,          %si
    /*
     * check string length
     */
        xor     %ax,            %ax
        mov     (0x80),         %al
        cmp     $0x00,          %ax
        je      get_kname_exit

    get_kname_loop:
        movb    (%si),          %al
        cmpb    $0x20,          %al
        je      get_kname_next_char
        cmpb    $0x2E,          %al
        jb      get_kname_exit
        cmpb    $0x7E,          %al
        ja      get_kname_exit
        movb    %al,            (%di)

        inc     %di
    get_kname_next_char:
        inc     %si
        jmp     get_kname_loop

    get_kname_exit:

        pop     %ax
        pop     %si
        ret

/**************************************************************
 * function:    get_buffer
 *
 * parameter:   bx, file id
 *
 * return:      none
 *
 * description: get buffer for kernel image, it shoud be 32bits absolute address
 **************************************************************/
get_buffer:
    /*
     * Assgin dx for file read
     */
        xorl    %eax,           %eax        // EAX = 0
        xorl    %ecx,           %ecx        // ECX = 0
        mov     $end_loader,    %ax         // get code endding address
        add     $0x20,          %ax
        and     $0xFFF0,        %ax         // AX = end of address + 20
        mov     %ax,            %dx
    /*
     * Assign f_buff for file read
     */
        xorl    %esi,           %esi
        mov     %ds,            %si
        shll    $4,             %esi
        add     %eax,           %esi        // ESI absolute address for read

        movl    %esi,           %edi        // EDI absolute address for read
    /*
     * Assign di for image
     */
        movl    $CODE_BASE,     %edi
        movl    %edi,           k_buff      // save EDI to k_buff

    /*
     * Now, dx is 16 bits address for read for DOS interrupt
     * esi, f_buff is 32 bits address for memory move from
     * edi and k_buff are 32 bits address for move to
     */
    get_img_loop:
    /*
     * Read file from file handle
     * used register are, ax, bx, cx, dx, ds
     */
        movb    $0x3F,          %ah
        mov     $BUFF_SIZE,     %cx
        int     $0x21                       // read file

        jc      get_img_exit
        cmp     $0x0000,        %ax
        je      get_img_exit                // check if ok or not

    /*
     * assign register for transfer
     * used register are, ds, es, esi, edi, ecx
     */
        push    %ds                         // save DS and ES(now they are not 0)
        push    %es
        mov     %ax,            %cx         // return value from int, it is read byte

        xor     %ax,            %ax         // assign DS and ES to 0
        mov     %ax,            %ds
        mov     %ax,            %es

    /*
     * start move, now DS and ES are 0, so can not use DS:ESI and ES:EDI
     */
        pushl   %esi                        // revent change ESI
        .byte   0x67                        // start to move woth unreal mode
        rep
        movsb
        popl    %esi                        // not not car EDI, because it is added to what we want

        pop     %es                         // restore ES and DS to read next section
        pop     %ds
        jmp     get_img_loop

    get_img_exit:
        ret

/**************************************************************
 * global variable for image buffer
 *
 * k_buff:  kernel image buffer for target
 **************************************************************/
k_buff:
    .long   0x87654321

/**************************************************************
 * function:    bios_putstr
 *
 * parameter:   ds:si, string pointer
 *
 * return:      none
 *
 * description: put string to console
 **************************************************************/
bios_putstr:
        mov     %cs,        %bx
        mov     %bx,        %ds
        mov     %bx,        %es

        lodsb
        andb    %al,    %al
        jz      fin

        call    prtchr
        jmp     bios_putstr

    fin:
        jmp     prtchr_exit

    prtchr:
        pushw   %ax
        pushw   %cx
        movw    $7,     %bx
        movw    $0x01,  %cx
        movb    $0x0e,  %ah
        int     $0x10
        popw    %cx
        popw    %ax

    prtchr_exit:
        ret

/**************************************************************
 * function:    x86_fill_desctriptor
 *
 * parameter:   none
 *
 * return:      none
 *
 * description: fill image header
 **************************************************************/
x86_fill_desctriptor:
        push    %ds

    /*
     * fill descriptor 1,2 for real mode code/data selector
     */
        xor     %eax,           %eax
        mov     %cs,            %ax
        mov     %ax,            (ld_cs)
        shl     $4,             %eax
        mov     %eax,           %ebx
        push    %ebx
        xor     %ebx,           %ebx

        mov     %ax,            (gdt1+2)    /* DOS_DATA */
        mov     %ax,            (gdt2+2)    /* DOS_CODE */

        shr     $16,            %eax
        movb    %al,            (gdt1+4)    /* DOS_DATA */
        movb    %al,            (gdt2+4)    /* DOS_CODE */

        movb    %ah,            (gdt1+7)    /* DOS_DATA */
        movb    %ah,            (gdt2+7)    /* DOS_CODE */

        pop    %ebx
        add     $x86_exit_pmode32,%ebx
        mov     %ebx,           (x86_ip)

    /*
     * copy descriptor to upper memory
     */
        xor     %esi,           %esi
        mov     $gdtr,          %si
        mov     $DES_BASE,      %edi
        mov     (des_len),      %cx
        xor     %eax,           %eax
        mov     %ax,            %es

        .byte   0x67
        rep
        movsb

        mov     %ax,            %ds
        mov     $DES_BASE,      %esi


        .byte   0x67
.code32
        lgdt    (%esi)
.code16

        pop     %ds
        ret

///////////////////////////////////////////////////////////////
// global variable body
///////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////
// public function body
// beause it is asm, public function has beter put in the begin
///////////////////////////////////////////////////////////////
/**************************************************************
 * function:    x86_enter_pmode
 *
 * parameter:   none
 *
 * return:      none
 *
 * description: enter protected mode
 **************************************************************/
x86_enter_pmode:

    /*
     * fill SP into ld_sp, and CS into ld_cs
     */
        mov     %cs,            %ax
        mov     %ax,            (ld_cs)
        mov     %sp,            %ax
        mov     %ax,            (ld_sp)

        cli

        movl    %cr0,           %eax
        orb     $1,             %al
        mov     $(KERNEL_DATA), %bx
        movl    %eax,           %cr0

        # jmpl    $(KERNEL_CODE),  $x86_enter_protect_mode

        .byte 0x66
        .byte 0xea                  # Far Jump $+9:Selector to reload CS
OffsetInProtectMode: 
        .long 00000000              #   $+9 Offset is ensuing instruction boundary
        .word KERNEL_CODE           #   Selector is our code selector, 38h

    /*
     * return from kernel image in 32 bit protected mode
     */
.code32
    x86_enter_protect_mode:
        .byte   0x66
        movw    $(KERNEL_DATA),    %ax
        movw    %ax, %ds
        movw    %ax, %es
        movw    %ax, %fs
        movw    %ax, %gs
        movw    %ax, %ss
        movl    $(STACK_LIMIT),    %esp

#define PAGE_PRESENT    (1 << 0)
#define PAGE_WRITE      (1 << 1)

SwitchToLongMode:
    movl   $(PG_TABLE), %edi
    # ; Zero out the 16KiB buffer.
    # ; Since we are doing a rep stosd, count should be bytes/4.   
    # push di                           ; REP STOSD alters DI.
    push %edi
    mov $(0x806000 / 4), %ecx
    xor %eax, %eax
    cld
    rep stos %eax, %es:(%edi)
    pop %edi
 
 
    # ; Build the Page Map Level 4. PG_TABLE + 0x0000 (1)
    xor %eax, %eax
    lea 0x1000(%edi),  %eax
    or $(PAGE_PRESENT | PAGE_WRITE), %eax
    mov %eax, %es:(%edi)

    # PDPE  : (0x01001000 - 0x01001FFF)

    lea 0x2000(%edi),  %eax
    or $(PAGE_PRESENT | PAGE_WRITE), %eax
    mov %eax, %es:0x1000(%edi)
    lea 0x3000(%edi),  %eax
    or $(PAGE_PRESENT | PAGE_WRITE), %eax
    mov %eax, %es:0x1008(%edi)
    lea 0x4000(%edi),  %eax
    or $(PAGE_PRESENT | PAGE_WRITE), %eax
    mov %eax, %es:0x1010(%edi)
    lea 0x5000(%edi),  %eax
    or $(PAGE_PRESENT | PAGE_WRITE), %eax
    mov %eax, %es:0x1018(%edi)

    # PDE   :  (0x01002000 - 0x01005FFF)

    push %edi

    lea  0x6000(%edi), %eax
    movl $(PG_TABLE + 0x2000), %edi
    or $(PAGE_PRESENT | PAGE_WRITE), %eax

LoopPDE:
    movl %eax,    %es:(%edi)
    addl $0x8,    %edi
    addl $0x1000, %eax
    cmpl $(PG_TABLE + 0x6000), %edi
    jb   LoopPDE

    pop  %edi

    # PTE   :  (0x01006000 - 0x01805FFF)

    push %edi

    # lea  0x6000(%edi), %eax
    xor  %eax, %eax
    movl $(PG_TABLE + 0x6000), %edi
    or $(PAGE_PRESENT | PAGE_WRITE), %eax

LoopPTE:
    movl %eax,    %es:(%edi)
    addl $0x8,    %edi
    addl $0x1000, %eax
    jnc  LoopPTE

    pop  %edi

    #
    # Enable the 64-bit page-translation-table entries by
    # setting CR4.PAE=1 (this is _required_ before activating
    # long mode). Paging is not enabled until after long mode
    # is enabled.
    #
    .byte 0xf
    .byte 0x20
    .byte 0xe0
    # mov eax, cr4
    btsl $5,%eax
    .byte 0xf
    .byte 0x22
    .byte 0xe0
    # mov cr4, eax

    #
    # This is the Trapolean Page Tables that are guarenteed
    #  under 4GB.
    #
    # Address Map:
    #    10000 ~    12000 - efildr (loaded)
    #    20000 ~    21000 - start64.com
    #    21000 ~    22000 - efi64.com
    #    222000 ~    290000 - efildr
    #    290000 ~    296000 - 4G pagetable (will be reload later)
    #
    .byte 0xb8
    .long PG_TABLE
    # mov eax, 190000h
    movl %eax, %cr3

    #
    # Enable long mode (set EFER.LME=1).
    #
    .byte 0xb9
    .long 0xc0000080
    #    mov   ecx, 0c0000080h ; EFER MSR number.
    .byte 0xf
    .byte 0x32
    #    rdmsr                 ; Read EFER.
    .byte 0xf
    .byte 0xba
    .byte 0xe8
    .byte 0x8
    #    bts   eax, 8          ; Set LME=1.
    .byte 0xf
    .byte 0x30
    #    wrmsr                 ; Write EFER.

    #
    # Enable paging to activate long mode (set CR0.PG=1)
    #
    movl  %cr0, %eax      # Read CR0.
    .byte 0xf
    .byte 0xba
    .byte 0xe8
    .byte 0x1f
    movl  %eax, %cr0      # Write CR0.

    jmp   GoToLongMode
GoToLongMode:

      .byte 0x67
      .byte 0xea                  # Far Jump $+9:Selector to reload CS
OffsetInLongMode: 
        .long 00000000              #   $+9 Offset is ensuing instruction boundary
        .word SYS_CODE64            #   Selector is our code selector, 38h
.code64
InLongMode: 
        # .byte 0x66
        # movw    $KERNEL_DATA,%ax
        # movw    %ax,%ds
        .byte 0x66
        # movw    $0x18,%ax
        movw    $SYS_DATA64,%ax
        movw    %ax,%es
        movw    %ax,%ss
        movw    %ax,%ds
        mov     $(STACK_LIMIT - 64), %esp

        # mov     $0x00200000,      %edi
        # mov       $0x001FFFF0,      %edi
        # cmp    %eax, (%edi)

        .byte 0xbd
        .long 0x400000
        #    mov ebp,000400000h                  ; Destination of EFILDR32
        .byte 0xbb
        .long 0x70000
        #    mov ebx,000070000h                  ; Length of copy

        #
        # load idt later
        #
        .byte 0x48
        .byte 0x33
        .byte 0xc0
        #    xor rax, rax
        # .byte 0x66
        # movw $x86_idtr, %ax
         movl $(G_IDTR), %eax
        # .byte 0x48
        # .byte 0x5
        # .long 0x20000
        # add rax, 20000h

        .byte 0xf
        .byte 0x1
        .byte 0x18
        #    lidt    fword ptr [rax]

        .byte 0x48
        .byte 0xc7
        .byte 0xc0
        # .long 0x21000
        .long  START_ENTRY
        #   mov rax, 21000h
        .byte 0x50
        #   push rax

        # ret
        .byte 0xc3
.code32
    x86_exit_pmode32:
        ljmp    $(DOS_CODE),    $x86_exit_pmode16

    /*
     * return from 32 bit protected mode and switch to 16 bit protected mode
     */
.code16
    x86_exit_pmode16:

        mov     $(DOS_DATA),    %ax
        mov     %ax,            %ds
        mov     %ax,            %ss

        mov     ld_sp,          %bx
        mov     ld_cs,          %cx

        movl    %cr0,           %eax
        and     $0xFE,          %al
        movl    %eax,           %cr0

        mov     %cx,            %ds         /* CS */
        mov     %cx,            %ss
        mov     %bx,            %sp         /* SP */

        push    %cx
        mov     $x86_rmode,     %ax
        push    %ax

        iret

    /*
     * it is enter real mode
     */
    x86_rmode:
        mov     %cs,            %ax
        mov     %ax,            %ds
        mov     %ax,            %ss
        sti

        ret

///////////////////////////////////////////////////////////////
// global variable body
///////////////////////////////////////////////////////////////
gdtr:
    .word   gdt_end - gdt
    .long   DES_BASE + gdt - gdtr

    .p2align 1

/**************************************************************
 * image descriptor
 *
 * Description:  these memory will move to DES_BASE
 *
 * DES_BASE: descripted in x86boot.h
 **************************************************************/
x86_ip:
    .long   0x00000000
des_len:
    .long   gdt_end-gdtr

ld_cs:
    .word   0x0000
ld_sp:
    .word   0x0000

    .p2align 1

gdt:
gdt0:
.equ                NULL_SEL, .-gdt    # Selector [0x0]    => gdt0
    .word   0
    .word   0
    .byte   0
    .byte   0
    .byte   0
    .byte   0
gdt1:               /* DOS_DATA */
.equ            LINEAR_SEL, .-gdt  # Selector [0x8]        => gdt1
        .word 0xFFFF    # limit 0xFFFFF
        .word 0         # base 0
        .byte 0
        .byte 0x92      # present, ring 0, data, expand-up, writable
        .byte 0xCF              # page-granular, 32-bit
        .byte 0
gdt2:                   /* DOS_CODE */
.equ            LINEAR_CODE_SEL, .-gdt # Selector [0x10]   => gdt2
        .word 0xFFFF    # limit 0xFFFFF
        .word 0         # base 0
        .byte 0
        .byte 0x9A      # present, ring 0, data, expand-up, writable
        .byte 0xCF              # page-granular, 32-bit
        .byte 0
gdt3:                   /* KERNEL_DATA */
.equ            SYS_DATA_SEL, .-gdt # Selector [0x18]      => gdt3
        .word 0xFFFF    # limit 0xFFFFF
        .word 0         # base 0
        .byte 0
        .byte 0x92      # present, ring 0, data, expand-up, writable
        .byte 0xCF              # page-granular, 32-bit
        .byte 0

gdt4:                   /* KERNEL_CODE */
.equ            SYS_CODE_SEL, .-gdt # Selector [0x20]      => gdt4
        .word 0xFFFF    # limit 0xFFFFF
        .word 0         # base 0
        .byte 0
        .byte 0x9A      # present, ring 0, data, expand-up, writable
        .byte 0xCF              # page-granular, 32-bit
        .byte 0

gdt5:                   /* KERNEL_SPARE3 */
.equ        SPARE3_SEL, .-gdt  # Selector [0x28]           => gdt5
        .word 0         # limit 0xFFFFF
        .word 0         # base 0
        .byte 0
        .byte 0         # present, ring 0, data, expand-up, writable
        .byte 0         # page-granular, 32-bit
        .byte 0

#
# system data segment descriptor
#
gdt6:                   /* SYS_DATA64 */
.equ              SYS_DATA64_SEL, .-gdt # Selector [0x30]    => gdt6
        .word 0xFFFF    # limit 0xFFFFF
        .word 0         # base 0
        .byte 0
        .byte 0x92      # P | DPL [1..2] | 1   | 1   | C | R | A
        .byte 0xCF      # G | D   | L    | AVL | Segment [19..16]
        .byte 0

#
# system code segment descriptor
#
gdt7:                   /* SYS_CODE64 */
.equ              SYS_CODE64_SEL, .-gdt # Selector [0x38]    => gdt7
        .word 0xFFFF    # limit 0xFFFFF
        .word 0         # base 0
        .byte 0
        .byte 0x9A      # P | DPL [1..2] | 1   | 1   | C | R | A
        .byte 0xAF      # G | D   | L    | AVL | Segment [19..16]
        .byte 0

# spare segment descriptor
gdt8:                   /* SPARE4 */
.equ        SPARE4_SEL, .-gdt    # Selector [0x40]           => gdt8
        .word 0         # limit 0xFFFFF
        .word 0         # base 0
        .byte 0
        .byte 0         # present, ring 0, data, expand-up, writable
        .byte 0         # page-granular, 32-bit
        .byte 0

gdt_end:

/**************************************************************
 * real mode IDT
 *
 * Description: IDT for real mode, after back from protected mode
 *              it have to restore
 *
 * x86_idtr:    real mode IDT descriptor
 **************************************************************/
x86_idtr:
      .p2align 1

      .long   x86_idt_end - x86_idt   /* limit=0xFFFF */
	    .quad   0x00000000              /* base=0       */

#idt_tag db "IDT",0     
        .p2align 1

x86_idt: 
# divide by zero (INT 0)
.equ                DIV_ZERO_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# debug exception (INT 1)
.equ                DEBUG_EXCEPT_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# NMI (INT 2)
.equ                NMI_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# soft breakpoint (INT 3)
.equ                BREAKPOINT_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# overflow (INT 4)
.equ                OVERFLOW_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# bounds check (INT 5)
.equ                BOUNDS_CHECK_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# invalid opcode (INT 6)
.equ                INVALID_OPCODE_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# device not available (INT 7)
.equ                DEV_NOT_AVAIL_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# double fault (INT 8)
.equ                DOUBLE_FAULT_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# Coprocessor segment overrun - reserved (INT 9)
.equ                RSVD_INTR_SEL1, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# invalid TSS (INT 0ah)
.equ                INVALID_TSS_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# segment not present (INT 0bh)
.equ                SEG_NOT_PRESENT_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# stack fault (INT 0ch)
.equ                STACK_FAULT_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# general protection (INT 0dh)
.equ                GP_FAULT_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# page fault (INT 0eh)
.equ                PAGE_FAULT_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# Intel reserved - do not use (INT 0fh)
.equ                RSVD_INTR_SEL2, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# floating point error (INT 10h)
.equ                FLT_POINT_ERR_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# alignment check (INT 11h)
.equ                ALIGNMENT_CHECK_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# machine check (INT 12h)
.equ                MACHINE_CHECK_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# SIMD floating-point exception (INT 13h)
.equ                SIMD_EXCEPTION_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# 85 unspecified descriptors, First 12 of them are reserved, the rest are avail
        .fill 85 * 16, 1, 0   # db (85 * 16) dup(0)

# IRQ 0 (System timer) - (INT 68h)
.equ                IRQ0_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 1 (8042 Keyboard controller) - (INT 69h)
.equ                IRQ1_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# Reserved - IRQ 2 redirect (IRQ 2) - DO NOT USE!!! - (INT 6ah)
.equ                IRQ2_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 3 (COM 2) - (INT 6bh)
.equ                IRQ3_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 4 (COM 1) - (INT 6ch)
.equ                IRQ4_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 5 (LPT 2) - (INT 6dh)
.equ                IRQ5_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 6 (Floppy controller) - (INT 6eh)
.equ                IRQ6_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 7 (LPT 1) - (INT 6fh)
.equ                IRQ7_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 8 (RTC Alarm) - (INT 70h)
.equ                IRQ8_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 9 - (INT 71h)
.equ                IRQ9_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 10 - (INT 72h)
.equ                 IRQ10_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 11 - (INT 73h)
.equ                 IRQ11_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 12 (PS/2 mouse) - (INT 74h)
.equ                 IRQ12_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 13 (Floating point error) - (INT 75h)
.equ                 IRQ13_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 14 (Secondary IDE) - (INT 76h)
.equ                 IRQ14_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

# IRQ 15 (Primary IDE) - (INT 77h)
.equ                 IRQ15_SEL, .-x86_idt
        .word 0               # offset 15:0
        .long SYS_CODE64_SEL  # selector 15:0
        .byte 0               # 0 for interrupt gate
        .byte 0x0e | 0x80     # type = 386 interrupt gate, present
        .word 0               # offset 31:16
        .long 0               # offset 63:32
        .long 0               # 0 for reserved

x86_idt_end: 

        .p2align 1

DummbyByte: .byte 0

MemoryMapSize:  .long 0
MemoryMap:  .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0
        .long 0,0,0,0,0,0,0,0

        .long 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

/**************************************************************
 * flags
 *
 * Description:  flag for end of program
 *
 * end_loader:     file end log
 **************************************************************/
end_loader:

///////////////////////////////////////////////////////////////
// LOG
///////////////////////////////////////////////////////////////
// 2004 05 22 -- 0004 add new function x86_a20_enable
// 2004 05 22 -- 0003 fix A20 testing routine
// 2004 02 01 -- 0002 remove debug string for register SP
// 2004 02 01 -- 0001 creat this log
