/**
 * STM32F103 Bootloader linker script
 *
 * John Berg @ netbasenext.nl
 */

OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(Reset_Handler)

MEMORY
{
    FLASH (RX)  : ORIGIN = 0x08000000, LENGTH = 56K   /* 8k from 128(64)k reserved for bootloader */
    RAM (W!RX)  : ORIGIN = 0x20000000, LENGTH = 16K   /* do not mix user app ram and bootloader */
}

/**
 * Define the top of the stack as the end of RAM
 */
_heap_size_min = 256;
_stack_size_min = 512; /* On a system with 64K, 8K was used */
_estack = (0x20000000+8K);

SECTIONS
{
    /* General code */
    .text :
    {
        _flash_start = .;
        . = ALIGN(4);
        /* At beginning of flash is:
         *
         * Required:
         * 0x0000 Initial stack pointer
         * 0x0004 Reset Handler
         *
         * Optional:
         * 0x0008 and beyond: NVIC ISR Table
         */
        KEEP(*(.isr_vector))
        . = ALIGN(4);
        *(.text)
        *(.text*)
        *(.glue_7)
        *(.glue_7t)

        /* C startup support */
        /* TODO: Convert to -nostartfiles for maximum DIY */
        *(.eh_frame)
        KEEP(*(.init))
        KEEP(*(.fini))
    } > FLASH

    /* Additional C++ Support sections */
    .preinit_array :
    {
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP (*(.preinit_array*))
        PROVIDE_HIDDEN (__preinit_array_end = .);
    } > FLASH
    .init_array :
    {
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP (*(SORT(.init_array.*)))
        KEEP (*(.init_array*))
        PROVIDE_HIDDEN (__init_array_end = .);
    } > FLASH
    .fini_array :
    {
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP (*(SORT(.fini_array.*)))
        KEEP (*(.fini_array*))
        PROVIDE_HIDDEN (__fini_array_end = .);
    } > FLASH

    .eeprom :
    {
        *(.eeprom)
        *(.eeprom*)
    } > EEPROM

    /* Load address of .data in flash for startup code */
    _sidata = LOADADDR(.data);

    /* Initialized data */
    .data :
    {
        . = ALIGN(4);
        _sdata = .; /* Start of data in RAM */
        *(.data);
        *(.data*);

        . = ALIGN(4);
        _edata = .; /* End of data in RAM */
    } > RAM AT > FLASH

    /* Zeroed data */
    . = ALIGN(4);
    .bss :
    {
        _sbss = .; /* Start of bss in RAM */
        __bss_start__ = _sbss;
        *(.bss)
        *(.bss*)
        . = ALIGN(4);
        _ebss = .; /* End of bss in RAM */
        __bss_end__ = _ebss;
    } > RAM

    /* Fake stack section to ensure that sufficient space is left */
    ._user_heap_stack :
    {
        . = ALIGN(4);
        . = . + _stack_size_min;
        . = . + _heap_size_min;
        . = ALIGN(4);
    } > RAM

    /* USB/CAN Packet Memory Area (PMA) */
    .pma :
    {
        _pma_start = .; /* Start of PMA in real memory space */
        . = ALIGN(2);
        *(.pma)
        *(.pma*)
        . = ALIGN(2);
        _pma_end = .; /* End of PMA in PMA space */
    } > PMA

    /* Remove information from the standard libraries */
    /DISCARD/ :
    {
        libc.a ( * )
        libm.a ( * )
        libgcc.a ( * )
    }

    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    }
    PROVIDE_HIDDEN (__exidx_end = .);
}

