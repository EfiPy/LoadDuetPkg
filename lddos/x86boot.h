/**************************************************************
 *      x86boot.h        Copyright(C) 2003-2018 Max Wu
 *
 * Header file loader from MS-DOS
 *
 **************************************************************/

#ifndef X86BOOT_H
#define X86BOOT_H

///////////////////////////////////////////////////////////////
// Include files
///////////////////////////////////////////////////////////////
/**************************************************************
 * None
 **************************************************************/

///////////////////////////////////////////////////////////////
// data structure
///////////////////////////////////////////////////////////////
/**************************************************************
 * None
 **************************************************************/

///////////////////////////////////////////////////////////////
// global variable
///////////////////////////////////////////////////////////////
/*************************************************************
 * Memery address for each section
 *************************************************************/
#define CODE_BASE       0x00200000      // kernel code address
#define DATA_BASE       0x00000000      // kernel data address
// #define STACK_BASE      0x00000000      // kernel stack address
#define START_ENTRY     0x00201000      // kernel code entry address

#define CODE_LIMIT      0x00010000      // kernel code limit
#define DATA_LIMIT      0xFFFFFFFF      // kernel data limit

#define DES_BASE        0x001F0000      // Desctiptor base address
#define BACK_IP         DES_BASE + 6    // IP for back to real mode

#define PG_TABLE        0x01000000      // Total 0x42000 size, 0x190000 + 0x42000 = 0x1D2000
#define G_IDTR          0x001E0000
#define STACK_LIMIT     PG_TABLE        // kernel stack limit

/*************************************************************
 * Selector define
 *************************************************************/
#define DOS_DATA        (1<<3)
#define DOS_CODE        (2<<3)
#define KERNEL_CODE     (4<<3)
#define KERNEL_DATA     (3<<3)
// #define KERNEL_STACK    (5<<3)
#define KERNEL_STACK    (3<<3)
#define SYS_DATA64      (6<<3)
#define SYS_CODE64      (7<<3)

///////////////////////////////////////////////////////////////
// global function
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

///////////////////////////////////////////////////////////////
// static inline function
///////////////////////////////////////////////////////////////
/**************************************************************
 * None
 **************************************************************/

#endif // X86BOOT_H

///////////////////////////////////////////////////////////////
// LOG
///////////////////////////////////////////////////////////////
// 2004 02 01 -- 0001 creat this log