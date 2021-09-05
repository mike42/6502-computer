.include "hardware/speaker.s"
.include "hardware/acia.s"
.include "hardware/via.s"

.segment "BSS"
shell_cmd_id: .res 1
shell_cmd_tmp: .res 1
shell_buffer_used: .res 1
shell_buffer: .res 64

.segment "CODE"

reset:
  ; Computer setup
  ldx #$ff
  txs
  cli
  jsr acia_setup

  ; Print welcome message
  jsr shell_newline
  ldx #0
@shell_welcome_char:
  lda shell_welcome, X
  beq @shell_welcome_done
  jsr acia_print_char
  inx
  jmp @shell_welcome_char
@shell_welcome_done:
jsr shell_newline

shell_next_command:
  ; Clear buffer
  lda #0
  sta shell_buffer_used
  ; Show prompt
  ldx #0
@shell_prompt_char:
  lda shell_prompt, X
  beq @shell_prompt_done
  jsr acia_print_char
  inx
  jmp @shell_prompt_char
@shell_prompt_done:

shell_next_char:
  ; receive char
  jsr acia_recv_char
  sta shell_cmd_tmp   ; possible future use
  cmp #$0d            ; return key pressed?
  beq @run_command    ; run the command
  ; TODO check for ASCII printable, backspace etc
  ; regular ascii char - save to buffer
  ldx shell_buffer_used
  sta shell_buffer, X
  inx
  stx shell_buffer_used
  ; print char
  jsr acia_print_char
  jmp shell_next_char
@run_command:
  jsr shell_newline
  ; set command ID to 0  
  lda #0
  sta shell_cmd_id
@test_command_next:
  ldx shell_cmd_id              ; any more commands to compare?
  cpx built_in_count
  bcs @command_not_found        ; no more commands to compare
  jsr shell_command_test
  inc shell_cmd_id
  jmp @test_command_next
  
@command_not_found:
  ; Print not found message
  ldx #0
@shell_not_found_char:
  lda shell_not_found, X
  beq @shell_not_found_done
  jsr acia_print_char
  inx
  jmp @shell_not_found_char
@shell_not_found_done:
  jsr shell_newline
  jmp shell_next_command

; if command number shell_cmd_id is the one in shell_buffer then run it, oherwise return
shell_command_test:          
  ldx shell_cmd_id            ; id of this command
  lda built_in_cmd_offsets, X ; start character of this command name in built_in_cmd
  tax                         ; x is index for next character in built_in_cmd
  ldy #0                      ; y is index for next character in shell_buffer
@nextchar:
  tya                         ; check for end of shell command
  cmp shell_buffer_used
  bcs @shell_command_end
  lda shell_buffer, Y         ; next char in shell_buffer
  cmp #32                     ; check for separator between shell command and arg
  beq @shell_command_end
  sta shell_cmd_tmp           ; store to fixed addr for next computation
  lda built_in_cmd, X         ; next char in built_in_cmd
  cmp #0                      ; check for null
  beq @command_not_match      ; command we are checking has ended, user command has not
  cmp shell_cmd_tmp           ; check for char is equal
  bne @command_not_match
  inx
  iny
  jmp @nextchar
@shell_command_end:           ; user command ended
  lda built_in_cmd, X         ; next char of command we are checking against
  cmp #0                      ; if we read a null here it is a match
  beq @command_match          ; command we are checking also ended
@command_not_match:
  rts
@command_match:               ; run the command
  lda shell_cmd_id            ; Get command ID, multiply by 2, jump to it.
  asl                         ; Multiply by 2 - mem address is 2 bytes
  tax
  jmp (built_in_main, X) ; jump to this main method

shell_not_found: .asciiz "Command not found"
shell_welcome: .asciiz "65C02 Computer Ready"
shell_prompt: .asciiz "# "

shell_newline:
  lda #$0d
  jsr acia_print_char
  lda #$0a
  jsr acia_print_char
  rts

sys_exit:  ; Jump here to hand control back to shell
  ldx #$ff ; Discard stack
  txs
  cli
  jmp shell_next_command

;
; Built-in command table
;
built_in_count: .byte 4
built_in_cmd_offsets:
.byte 0
.byte 5
.byte 11
.byte 14

built_in_cmd:
.asciiz "echo"
.asciiz "hello"
.asciiz "rx"
.asciiz "irqtest"

built_in_main:
.word shell_echo_main
.word shell_hello_main
.word shell_rx_main
.word shell_irqtest_main

;
; Built-in command: echo
;
shell_echo_main:
  ldx #5
  
@shell_echo_char:
  lda shell_buffer, X
  jsr acia_print_char
  inx
  cpx shell_buffer_used
  bcs @shell_echo_done
  jmp @shell_echo_char
@shell_echo_done:
  jsr shell_newline
  lda #0
  jmp sys_exit

;
; Built-in command: hello
;
shell_hello_main:
  ldx #0
@hello_char:
  lda hello_world, X
  beq @hello_done
  jsr acia_print_char
  inx
  jmp @hello_char
@hello_done:
  jsr shell_newline
  lda #0
  jmp sys_exit

hello_world: .asciiz "Hello, world"

;
; Built-in command: rx
; Not yet implemented
;
shell_rx_main:
  lda #0
  jmp sys_exit

; Set up a timer to trigger an IRQ
IRQ_CONTROLLER = $8800

shell_irqtest_main:
  ; TODO print $00 instead
  lda #$ff
  sta $00
  jsr hex_print_byte
  jsr shell_newline
  ; TODO do this using VIA timer / interrupt instead
  jsr fake_irq
  ; Print out which interrupt was used
  lda $00
  jsr hex_print_byte
  jsr shell_newline
  lda #0
  jmp sys_exit

fake_irq:
  ldx IRQ_CONTROLLER        ; read interrupt controller to find highest-priority interrupt to service
  jmp (isr_jump_table, X)   ; jump to matching service routine

hex_print_byte:                 ; print accumulator as two ascii digits (hex)
    pha                         ; store byte for later
    lsr                         ; shift out lower nibble
    lsr
    lsr
    lsr
    tax
    lda hex_chars, X            ; convert 0-15 to ascii char for hex digit
    jsr acia_print_char         ; print upper nibble
    pla                         ; retrieve byte again
    and #$0f                    ; mask out upper nibble
    tax
    lda hex_chars, X            ; convert 0-15 to ascii char for hex digit
    jsr acia_print_char         ; print lower nibble
    rts
hex_chars: .byte '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'

irq0_isr:                   ; interrupt routine for VIA
  stx $00                   ; store interrupt index for debugging
;  ldx $8000                ; TODO clear interrupt flag on VIA
;  rti                      ; TODO swap when used from irq later
  rts

nop_isr:                    ; interrupt routine for anything else
  stx $00                   ; store interrupt index for debugging
;  rti                      ; TODO swap when used from irq later
  rts

isr_jump_table:             ; 10 possible interrupt sources
.word irq0_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr               ; when no source is triggering the interrupt

irq:
  ldx IRQ_CONTROLLER        ; read interrupt controller to find highest-priority interrupt to service
  ; TODO when interrupts are being set from timer
  ;jmp (isr_jump_table, X)   ; jump to matching service routine
  rti

nmi:
  rti

.segment "VECTORS"
.word nmi
.word reset
.word irq

