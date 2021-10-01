.import sys_exit, acia_print_char, shell_newline

; Test of standalone program
.org $0400

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
