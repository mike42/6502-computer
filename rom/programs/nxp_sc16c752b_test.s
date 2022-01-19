;
; Test program for the SC16C752B dual UART from NXP
;
.import sys_exit

; Assuming /CSA is connected to IO3
UART_BASE = $8c00

; UART registers
; Not included: FIFO ready register, Xon1 Xon2 words.
UART_RHR = UART_BASE        ; Receiver Holding Register (RHR) - R
UART_THR = UART_BASE        ; Transmit Holding Register (THR) - W
UART_IER = UART_BASE + 1    ; Interrupt Enable Register (IER) - R/W
UART_IIR = UART_BASE + 2    ; Interrupt Identification Register (IIR) - R
UART_FCR = UART_BASE + 2    ; FIFO Control Register (FCR) - W
UART_LCR = UART_BASE + 3    ; Line Control Register (LCR) - R/W
UART_MCR = UART_BASE + 4    ; Modem Control Register (MCR) - R/W
UART_LSR = UART_BASE + 5    ; Line Status Register (LSR) - R
UART_MSR = UART_BASE + 6    ; Modem Status Register (MSR) - R
UART_SPR = UART_BASE + 7    ; Scratchpad Register (SPR) - R/W
; Different meaning when LCR is logic 1
UART_DLL = UART_BASE        ; Divisor latch LSB - R/W
UART_DLM = UART_BASE + 1    ; Divisor latch MSB - R/W
; Different meaning when LCR is %1011 1111 ($bh).
UART_EFR = UART_BASE + 2    ; Enhanced Feature Register (EFR) - R/W
UART_TCR = UART_BASE + 6    ; Transmission Control Register (TCR) - R/W
UART_TLR = UART_BASE + 7    ; Trigger Level Register (TLR) - R/W

.segment "CODE"
main:
  lda #$80                  ; Enable divisor latches
  sta UART_LCR
  lda #1                    ; Set divisior to 1 - on a 1.8432 MHZ XTAL1, this gets 115200bps.
  sta UART_DLL
  lda #0
  sta UART_DLM
  lda #%00010111            ; Sets up 8-n-1
  sta UART_LCR
  lda #%00001111            ; Enable FIFO, set DMA mode 1
  sta UART_FCR
  jsr test_print
  jsr test_recv
  lda #0
  jmp sys_exit

test_print:                 ; Send test string to UART
  ldx #0
@test_char:
  lda test_string, X
  beq @test_done
  sta UART_THR
  inx
  jmp @test_char
@test_done:
  rts

test_string: .asciiz "Hello, world!"

test_recv:                  ; Receive three characters and echo them back
  jsr uart_recv_char
  sta UART_THR
  jsr uart_recv_char
  sta UART_THR
  jsr uart_recv_char
  sta UART_THR
  rts

uart_recv_char:             ; Receive next char to A register
  lda UART_LSR
  and #%00000001
  cmp #%00000001
  bne uart_recv_char
  lda UART_RHR
  rts

