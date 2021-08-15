; minimal monitor for EhBASIC and 6502 simulator V1.05
; tabs converted to space, tabwidth=6

; To run EhBASIC on the simulator load and assemble [F7] this file, start the simulator
; running [F6] then start the code with the RESET [CTRL][SHIFT]R. Just selecting RUN
; will do nothing, you'll still have to do a reset to run the code.

      .include "basic.s"

; put the IRQ and MNI code in RAM so that it can be changed

IRQ_vec     = VEC_SV+2        ; IRQ code vector
NMI_vec     = IRQ_vec+$0A     ; NMI code vector

; now the code. all this does is set up the vectors and interrupt code
; and wait for the user to select [C]old or [W]arm start. nothing else
; fits in less than 128 bytes

      .segment "CODE"         ; pretend this is in a 1/8K ROM

; reset vector points here

RES_vec
      CLD                     ; clear decimal mode
      LDX   #$FF              ; empty stack
      TXS                     ; set the stack
      JSR ACIAsetup

; set up vectors and interrupt code, copy them to page 2

      LDY   #END_CODE-LAB_vec ; set index/count
LAB_stlp
      LDA   LAB_vec-1,Y       ; get byte from interrupt code
      STA   VEC_IN-1,Y        ; save to RAM
      DEY                     ; decrement index/count
      BNE   LAB_stlp          ; loop if more to do

; now do the signon message, Y = $00 here

LAB_signon
      LDA   LAB_mess,Y        ; get byte from sign on message
      BEQ   LAB_nokey         ; exit loop if done

      JSR   V_OUTP            ; output character
      INY                     ; increment index
      BNE   LAB_signon        ; loop, branch always

LAB_nokey
      JSR   V_INPT            ; call scan input device
      BCC   LAB_nokey         ; loop if no key

      AND   #$DF              ; mask xx0x xxxx, ensure upper case
      CMP   #'W'              ; compare with [W]arm start
      BEQ   LAB_dowarm        ; branch if [W]arm start

      CMP   #'C'              ; compare with [C]old start
      BNE   RES_vec           ; loop if not [C]old start

      JMP   LAB_COLD          ; do EhBASIC cold start

LAB_dowarm
      JMP   LAB_WARM          ; do EhBASIC warm start

; Polled 65c51 I/O routines adapted to EhBASIC. Delay routine from
; http://forum.6502.org/viewtopic.php?f=4&t=2543&start=30#p29795
ACIA_RX      = $8400
ACIA_TX      = $8400
ACIA_STATUS  = $8401
ACIA_COMMAND = $8402
ACIA_CONTROL = $8403

ACIAsetup
      LDA #$00                ; write anything to status register for program reset
      STA ACIA_STATUS
      LDA #$0B                ; %0000 1011 = Receiver odd parity check
                              ;              Parity mode disabled
                              ;              Receiver normal mode
                              ;              RTSB Low, trans int disabled
                              ;              IRQB disabled
                              ;              Data terminal ready (DTRB low)
      STA ACIA_COMMAND        ; set command register  
      LDA #$1F                ; %0001 1111 = 19200 Baud
                              ;              External receiver
                              ;              8 bit words
                              ;              1 stop bit
      STA ACIA_CONTROL        ; set control register  
      RTS

ACIAout
      PHA                     ; save A
      LDA ACIA_STATUS         ; Read (and ignore) ACIA status register
      PLA                     ; restore A
      STA ACIA_TX             ; write byte
      JSR ACIAdelay           ; delay because of bug
      RTS

ACIAdelay
      PHY                     ; Save Y Reg
      PHX                     ; Save X Reg
DELAY_LOOP
      LDY   #6                ; Get delay value (clock rate in MHz 2 clock cycles)
MINIDLY
      LDX   #$68              ; Seed X reg
DELAY_1
      DEX                     ; Decrement low index
      BNE   DELAY_1           ; Loop back until done
      DEY                     ; Decrease by one
      BNE   MINIDLY           ; Loop until done
      PLX                     ; Restore X Reg
      PLY                     ; Restore Y Reg
DELAY_DONE
      RTS                     ; Delay done, return

ACIAin
      LDA ACIA_STATUS         ; get ACIA status
      AND #$08                ; mask rx buffer status flag
      BEQ LAB_nobyw           ; branch if no byte waiting
      LDA ACIA_RX             ; get byte from ACIA data port
      SEC                     ; flag byte received
      RTS
LAB_nobyw
      CLC                     ; flag no byte received
no_load                       ; empty load vector for EhBASIC
no_save                       ; empty save vector for EhBASIC
      RTS

; vector tables

LAB_vec
      .word ACIAin            ; byte in from simulated ACIA
      .word ACIAout           ; byte out to simulated ACIA
      .word no_load           ; null load vector for EhBASIC
      .word no_save           ; null save vector for EhBASIC

; EhBASIC IRQ support

IRQ_CODE
      PHA                     ; save A
      LDA   IrqBase           ; get the IRQ flag byte
      LSR                     ; shift the set b7 to b6, and on down ...
      ORA   IrqBase           ; OR the original back in
      STA   IrqBase           ; save the new IRQ flag byte
      PLA                     ; restore A
      RTI

; EhBASIC NMI support

NMI_CODE
      PHA                     ; save A
      LDA   NmiBase           ; get the NMI flag byte
      LSR                     ; shift the set b7 to b6, and on down ...
      ORA   NmiBase           ; OR the original back in
      STA   NmiBase           ; save the new NMI flag byte
      PLA                     ; restore A
      RTI

END_CODE

LAB_mess
      .byte $0D,$0A,"6502 EhBASIC [C]old/[W]arm ?",$00
                              ; sign on string

; system vectors

      .segment "VECTORS"

      .word NMI_vec           ; NMI vector
      .word RES_vec           ; RESET vector
      .word IRQ_vec           ; IRQ vector

      .end RES_vec            ; set start at reset vector
      
