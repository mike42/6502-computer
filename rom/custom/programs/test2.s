; locations of some functions in ROM
acia_print_char = $c014
acia_recv_char  = $c020
shell_newline   = $c113
sys_exit        = $c11e

.segment "CODE"
main:
  ldx #0
@test_char:
  lda test_string, X
  beq @test_done
  jsr acia_print_char
  inx
  jmp @test_char
@test_done:
  jsr shell_newline
  lda #0
  jmp sys_exit

test_string: .asciiz "Test program"

