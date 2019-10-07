;==============================================================================
; Contents of this file are copyright Phillip Stevens
;
; You have permission to use this for NON COMMERCIAL USE ONLY
; If you wish to use it elsewhere, please include an acknowledgement to myself.
;
; https://github.com/feilipu/
;
; https://feilipu.me/
;
;
; This work was authored in Marrakech, Morocco during May/June 2017.

    INCLUDE "config_private.inc"

    SECTION code_driver

    PUBLIC asm_i2c1_read_get

    EXTERN __i2c1RxPtr
    EXTERN __i2c1ControlEcho, __i2c1SlaveAddr, __i2c1SentenceLgth

;   Read from the I2C Interface, using Byte Mode transmission
;   uint8_t i2c_read_get( char addr, char length );
;   parameters passed in registers
;   B  = length of data sentence expected, uint8_t _i2c1SentenceLgth
;   C  = 7 bit address of slave device, uint8_t _i2c1SlaveAddr

.asm_i2c1_read_get
    ld a,b                      ;check the sentence expected for zero length
    and a
    ret Z                       ;return if the expected sentence is 0 length

    ld a,(__i2c1SlaveAddr)      ;check the 7 bit slave address
    rra
    xor c
    ret NZ                      ;return if the slave address is mismatched

.i2c1_read_wait                 ;busy wait loop
    ld a,(__i2c1ControlEcho)
    tst __IO_I2C_CON_ECHO_BUS_RESTART|__IO_I2C_CON_ECHO_BUS_ILLEGAL
    ret NZ                      ;just exit if a fault

    and __IO_I2C_CON_ECHO_BUS_STOPPED
    jr Z,i2c1_read_wait         ;if the bus is still not stopped, then wait till it is

    ld hl,__i2c1SentenceLgth    ;return the remaining unobtained sentence length (zero for success)
    ld l,(hl)
    ld h,0
    ret
