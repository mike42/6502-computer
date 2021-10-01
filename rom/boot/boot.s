; Boot ROM for 6502 computer. Provides shell which can access test programs.

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
  ldx shell_buffer_used
  cpx #0
  beq @no_command
  lda #0
  sta shell_cmd_id
@test_command_next:
  ldx shell_cmd_id              ; any more commands to compare?
  cpx built_in_count
  bcs @command_not_found        ; no more commands to compare
  jsr shell_command_test
  inc shell_cmd_id
  jmp @test_command_next
@no_command:                    ; pressed enter with nothing at the prompt
  jmp shell_next_command

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
built_in_count: .byte 5
built_in_cmd_offsets:
.byte 0
.byte 5
.byte 11
.byte 14
.byte 22

built_in_cmd:
.asciiz "echo"
.asciiz "hello"
.asciiz "rx"
.asciiz "irqtest"
.asciiz "run"

built_in_main:
.word shell_echo_main
.word shell_hello_main
.word shell_rx_main
.word shell_irqtest_main
.word shell_run_main

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
; Currently just waits 15 seconds, provides correct XMODEM responses to tell
; the sender that it received one packet.
USER_PROGRAM_START = $0400   ; Address for start of user programs
USER_PROGRAM_WRITE_PTR = $00 ; ZP address for writing user program

shell_rx_main:
  ; Set pointers
  lda #<USER_PROGRAM_START   ; Low byte first
  sta USER_PROGRAM_WRITE_PTR
  lda #>USER_PROGRAM_START   ; High byte next
  sta USER_PROGRAM_WRITE_PTR + 1
  ; Delay so that we can set up file send
  lda #1                     ; wait ~1 second
  jsr shell_rx_sleep_seconds
  ; NAK, ACK once
@shell_block_nak:
  lda #$15                  ; NAK gets started
  jsr acia_print_char
  lda SPEAKER               ; Click each time we send a NAK or ACK
  jsr shell_rx_receive_with_timeout  ; Check in loop w/ timeout
  bcc @shell_block_nak     ; Not received yet
  cmp #$01                 ; If we do have char, should be SOH
  bne @shell_rx_fail       ; Terminate transfer if we don't get SOH
@shell_rx_block:
  ; Receive one block
  jsr acia_recv_char     ; Block number
  jsr acia_recv_char     ; Inverse block number
  ldy #0                 ; Start at char 0
@shell_rx_char:
  jsr acia_recv_char
  sta (USER_PROGRAM_WRITE_PTR), Y
  iny
  cpy #128
  bne @shell_rx_char
  jsr acia_recv_char     ; Checksum - TODO verify this and jump to shell_block_nak to repeat if not mathing
  lda #$06               ; ACK the packet
  jsr acia_print_char
  lda SPEAKER               ; Click each time we send a NAK or ACK
  jsr acia_recv_char
  cmp #$04              ; EOT char, no more blocks
  beq @shell_rx_done
  cmp #$01              ; SOH char, next block on the way
  bne @shell_block_nak  ; Anything else fail transfer
  lda USER_PROGRAM_WRITE_PTR      ; This next part moves write pointer along by 128 bytes
  cmp #$00
  beq @block_half_advance
  lda #$00                        ; If low byte != 0, set to 0 and inc high byte
  sta USER_PROGRAM_WRITE_PTR
  inc USER_PROGRAM_WRITE_PTR + 1
@block_half_advance:              ; If low byte = 0, set it to 128
  lda #$80
  sta USER_PROGRAM_WRITE_PTR
  jmp @shell_rx_block
@shell_rx_done:
  lda #$6               ; ACK the EOT as well.
  jsr acia_print_char
  lda SPEAKER           ; Click each time we send a NAK or ACK
  lda #1                ; wait a moment (printing does not work otherwise..)
  jsr shell_rx_sleep_seconds
; jsr shell_rx_print_user_program
  jsr shell_newline
  lda #0
  jmp sys_exit
@shell_rx_fail:
  lda #1
  jmp sys_exit

; Like acia_recv_char, but terminates after a short time if nothing is received
shell_rx_receive_with_timeout:
  ldy #$ff
@y_loop:
  ldx #$ff
@x_loop:
  lda ACIA_STATUS              ; check ACIA status in inner loop
  and #$08                     ; mask rx buffer status flag
  bne @rx_got_char
  dex
  cpx #0
  bne @x_loop
  dey
  cpy #0
  bne @y_loop
  clc                          ; no byte received in time
  rts
@rx_got_char:
  lda ACIA_RX                  ; get byte from ACIA data port
  sec                          ; set carry bit
  rts

shell_rx_sleep_seconds: ; sleep for 0-63 seconds (approx)
  pha                   ; save registers
  phx
  phy
  asl                   ; multiply A by 4, outer loop is approx 250ms.
  asl
@a_loop:
  cmp #0                ; stop if A is 0 (outer loop)
  beq @end
  ldy #$ff              ; start Y at 255 and decrement (middle loop)
@y_loop:
  ldx #$ff
@x_loop:                ; start Y at 255 and decrement (inner loop)
  dex
  cpx #0
  bne @x_loop           ; end inner loop
  dey
  cpy #0
  bne @y_loop           ; end middle loop
  dec                   ; decrement A and repeat
  jmp @a_loop           ; end outer loop
@end:
  ply                   ; restore registers
  plx
  pla
  rts

shell_rx_print_user_program:
; Print the first 255 bytes of uploaded user program
  ldy #0
@user_program_line:
  jsr shell_newline
  ldx #16               ; Number of hex digits per line
@user_program_char:
  lda USER_PROGRAM_START, Y
  phx
  jsr hex_print_byte    ; Print the char (clobbers X)
  plx
  lda #$20              ; space between chars
  jsr acia_print_char
  iny
  cpy #0                ; Wrap-around at 255 bytes
  beq @user_program_done
  dex
  cpx #0
  bne @user_program_char
  jmp @user_program_line
@user_program_done:
  rts

; test routine tp show what is being received over serial.
; receive bytes from ACIA, and echo them back in hex until Ctrl+C is pressed
shell_rx_print_chars:
  ldx #26               ; Number of hex digits per line, fills 80 chars
@next_byte:
  phx
  jsr acia_recv_char    ; get char
  cmp #$03              ; Ctrl+C?
  beq @done
  jsr hex_print_byte    ; print as hex (2 digits)
  lda #$20              ; space between chars
  jsr acia_print_char
  plx
  dex
  cpx #0
  bne @next_byte        ; loop until x is 0
  jsr shell_newline     ; line break
  jmp shell_rx_print_chars
@done:
  plx
  jsr shell_newline     ; line break
  rts

; Jump into user program
shell_run_main:
  jmp USER_PROGRAM_START

; Set up a timer to trigger an IRQ
IRQ_CONTROLLER = $8C00

; Some values to help us debug
DEBUG_LAST_INTERRUPT_INDEX = $00
DEBUG_INTERRUPT_COUNT = $01

shell_irqtest_main:
  lda #$ff              ; set interrupt index to dummy value (so we can see if it's not being overridden)
  sta DEBUG_LAST_INTERRUPT_INDEX
  lda #$00              ; reset interrupt counter
  sta $01
  ; setup for via
  lda #%00000000        ; set ACR. first two bits = 00 is one-shot for T1
  sta VIA_ACR
  lda #%11000000        ; enable VIA interrupt for T1
  sta VIA_IER
  sei                   ; enable IRQ at CPU - normally off in this code
  ; set up a timer at ~65535 clock pulses.
  lda #$ff              ; set T1 low-order counter
  sta VIA_T1C_L
  lda #$ff              ; set T1 high-order counter
  sta VIA_T1C_H
  wai                   ; wait for interrupt
  ; reset for via
  cli                   ; disable IRQ at CPU - normally off in this code
  lda #%01000000        ; disable VIA interrupt for T1
  ; Print out which interrupt was used, should be 02 if irq1_isr ran
  lda DEBUG_LAST_INTERRUPT_INDEX
  jsr hex_print_byte
  jsr shell_newline
  ; print number of times interrupt ran, should be 01 if it only ran once
  lda DEBUG_INTERRUPT_COUNT
  jsr hex_print_byte
  jsr shell_newline
  lda #0
  jmp sys_exit
;
;fake_irq:
;  ldx IRQ_CONTROLLER        ; read interrupt controller to find highest-priority interrupt to service
;  jmp (isr_jump_table, X)   ; jump to matching service routine

hex_print_byte:               ; print accumulator as two ascii digits (hex)
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

irq1_isr:                        ; interrupt routine for VIA
  stx DEBUG_LAST_INTERRUPT_INDEX ; store interrupt index for debugging
  ldx VIA_T1C_L                  ; clear IFR bit 6 on VIA (side-effect of reading T1 low-order counter)
  jmp irq_return

nop_isr:                         ; interrupt routine for anything else
  stx DEBUG_LAST_INTERRUPT_INDEX ; store interrupt index for debugging
  jmp irq_return

isr_jump_table:                  ; 10 possible interrupt sources
.word nop_isr
.word irq1_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr
.word nop_isr               ; 11th option for when no source is triggering the interrupt

irq:
  phx                       ; push x for later
  inc DEBUG_INTERRUPT_COUNT ; count how many times this runs..
  ldx IRQ_CONTROLLER        ; read interrupt controller to find highest-priority interrupt to service
  jmp (isr_jump_table, X)   ; jump to matching service routine

irq_return:
  plx                       ; restore x
  rti

nmi:
  rti

.segment "VECTORS"
.word nmi
.word reset
.word irq

