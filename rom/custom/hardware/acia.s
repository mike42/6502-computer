ACIA_RX = $8400
ACIA_TX = $8400
ACIA_STATUS = $8401
ACIA_COMMAND = $8402
ACIA_CONTROL = $8403

acia_setup:
	; Polled 65c51 I/O routines. Delay routine from
	; http://forum.6502.org/viewtopic.php?f=4&t=2543&start=30#p29795
	lda #$00 ; write anything to status register for program reset
	sta ACIA_STATUS
	lda #$0b                    ; %0000 1011 = Receiver odd parity check
		                          ;              Parity mode disabled
		                          ;              Receiver normal mode
		                          ;              RTSB Low, trans int disabled
		                          ;              IRQB disabled
		                          ;              Data terminal ready (DTRB low)
	sta ACIA_COMMAND            ; set control register  
	lda #$1f                    ; %0001 1111 = 19200 Baud
		                          ;              External receiver
		                          ;              8 bit words
		                          ;              1 stop bit
	sta ACIA_CONTROL            ; set control register  
	rts

acia_print_char:
  pha                         ; save A
  lda ACIA_STATUS             ; Read ACIA status register
  pla                         ; ELSE, restore ACCUMULATOR from STACK
  sta ACIA_TX                 ; Write byte to ACIA transmit data register
  jsr acia_delay              ; Required delay - Comment out for working 6551/65C51!     
  rts                         ; Done COUT subroutine, RETURN

acia_recv_char:
  lda ACIA_STATUS             ; get ACIA status
  and #$08                    ; mask rx buffer status flag
  beq acia_recv_char          ; loop if rx buffer empty
  lda SPEAKER
  lda ACIA_RX                 ; get byte from ACIA data port
  rts

acia_delay:
  phy                         ; Save Y Reg
  phx                         ; Save X Reg
  ldy   #6                    ; Get delay value (clock rate in MHz 2 clock cycles)
@minidly:
  ldx   #$68                  ; Seed X reg
@delay_1:
  dex                         ; Decrement low index
  bne @delay_1                ; Loop back until done
  dey                         ; Decrease by one
  bne @minidly                ; Loop until done
  plx                         ; Restore X Reg
  ply                         ; Restore Y Reg
@delay_done:
  rts                         ; Delay done, return

