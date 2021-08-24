.include "hardware/speaker.s"
.include "hardware/acia.s"
.include "hardware/via.s"

.segment "CODE"

reset:
  ldx #$ff
  txs
  cli

  jsr acia_setup
  ldx #0
@nextchar:
  lda message, X
  beq loop
  jsr acia_print_char
  inx
  jmp @nextchar

loop:
  jsr acia_recv_char
  jsr acia_print_char
  jmp loop

message:
.asciiz "Hello"

nmi:
  rti

irq:
  rti

.segment "VECTORS"
.word nmi
.word reset
.word irq

