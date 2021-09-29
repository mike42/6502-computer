; locations of some functions in ROM
acia_print_char = $c014
acia_recv_char = $c020
shell_newline = $c113
sys_exit = $c11e

.segment "CODE"
main:
  jmp sys_exit

