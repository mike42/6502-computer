;
; Test for reading from SD card.
; Expects card to be wired CD, CS, DI, DO, CLK on PA0..PA5
;
.import acia_print_char, shell_newline, sys_exit, VIA_DDRA, hex_print_byte, VIA_PORTA, shell_rx_sleep_seconds

.segment "ZEROPAGE"
string_ptr: .res 2
tmp_1: .res 1
tmp_2: .res 1

.segment "CODE"
main:
  jsr via_setup
  jsr sd_detect
  jsr sd_reset
  jsr sd_cmd58

  lda #0
  jmp sys_exit

; Set up pin directions on the VIA and set initial values.
via_setup:
  lda #%00000110      ; CS and MOSI are high initially.
  sta VIA_PORTA
  lda #%00010110      ; Pin direction PA7..PA0.
  sta VIA_DDRA
  rts

; Detect SD card. Checks the CD flag on PA0.
sd_detect:
  lda VIA_PORTA
  and #%00000001    ; Check CD. 0 is card not present, 1 is card present.
  cmp #$00
  beq @sd_not_detected
@sd_detected:
  ldx #<string_sd_detected
  stx string_ptr
  ldx #>string_sd_detected
  stx string_ptr + 1
  jsr print_string
  jsr shell_newline
  rts
@sd_not_detected:
  ldx #<string_sd_not_detected
  stx string_ptr
  ldx #>string_sd_not_detected
  stx string_ptr + 1
  jsr print_string
  jsr shell_newline
  ; Not OK. Terminate program.
  lda #1
  jmp sys_exit

; Print null terminated string
print_string:
  ldy #0
@test_char:
  lda (string_ptr), Y
  beq @test_done
  jsr acia_print_char
  iny
  jmp @test_char
@test_done:
  rts

; Reset sequence for SD card, places it in SPI mode.
sd_reset:
  ; Toggle clock 74 times with MOSI and CS high.
  ldx #74
@clock:
  lda #%00000110
  sta VIA_PORTA
  lda #%00010110
  sta VIA_PORTA
  dex
  cpx #0
  bne @clock
; CMD0 - reset command
  lda #%01000000
  jsr sd_send_byte
  lda #%00000000
  jsr sd_send_byte
  lda #%00000000
  jsr sd_send_byte
  lda #%00000000
  jsr sd_send_byte
  lda #%00000000
  jsr sd_send_byte
  lda #%10010101
  jsr sd_send_byte
  ; Receive response?
  jsr sd_reset_wait
  jsr hex_print_byte    ; Prints 00 if everything is OK.
  jsr shell_newline
  ; Switch CS high again
  lda #%00010110
  sta VIA_PORTA
  rts

sd_cmd58:
; CMD58 - request contents of operating conditions register
  lda #%01111010
  jsr sd_send_byte
  lda #%00000000
  jsr sd_send_byte
  lda #%00000000
  jsr sd_send_byte
  lda #%00000000
  jsr sd_send_byte
  lda #%00000000
  jsr sd_send_byte
  lda #%01110101
  jsr sd_send_byte
; Receive 40 bit response
  jsr sd_recv_byte
  jsr hex_print_byte
  lda #$20
  jsr acia_print_char

  jsr sd_recv_byte
  jsr hex_print_byte
  lda #$20
  jsr acia_print_char

  jsr sd_recv_byte
  jsr hex_print_byte
  lda #$20
  jsr acia_print_char

  jsr sd_recv_byte
  jsr hex_print_byte
  lda #$20
  jsr acia_print_char

  jsr sd_recv_byte
  jsr hex_print_byte
  jsr shell_newline

  ; Switch CS high again
  lda #%00010110
  sta VIA_PORTA
  rts

sd_send_byte:   ; Send 8 bits to SD card
  sta tmp_1
  ldx #8        ; Loop index
@sd_send_bit:
  dex
  asl tmp_1                ; Shift A left, next bit to send is in carry bit.
  bcs @sd_send_one
@sd_send_zero:
  lda #%00000000
  sta VIA_PORTA
  lda #%00010000
  sta VIA_PORTA
  lda #'0'         ; TODO debug..
  jsr acia_print_char
  cpx #0
  beq @sd_send_done
  jmp @sd_send_bit
@sd_send_one:
  lda #%00000100
  sta VIA_PORTA
  lda #%00010100
  sta VIA_PORTA
  lda #'1'         ; TODO debug..
  jsr acia_print_char
  cpx #0
  beq @sd_send_done
  jmp @sd_send_bit
@sd_send_done:
  lda #' '         ; TODO debug..
  jsr acia_print_char
  rts

sd_reset_wait:
  ldx #16                   ; Loop index - maximum of 16 clock cycles to respond
@sd_recv_bit_wait:
  dex
  lda #%00000100            ; Toggle clock with MOSI high, CS low
  sta VIA_PORTA
  lda #%00010100
  sta VIA_PORTA
  ; read 1 bit response
  lda VIA_PORTA
  and #%00001000            ; mask out MISO only
  cmp #%00000000            ; is it a a 0?
  beq @sd_reset_recv
  cpx #0
  bne @sd_recv_bit_wait
  jmp sd_reset_fail         ; did not receive a 0 within 16 cycles.
@sd_reset_recv:             ; read remaining 7 bits of basic response
  jsr sd_basic_response_recv
  rts

sd_reset_fail:
  ldx #<string_sd_reset_fail
  stx string_ptr
  ldx #>string_sd_reset_fail
  stx string_ptr + 1
  jsr print_string
  jsr shell_newline
  ; Not OK. Terminate program.
  lda #1
  jmp sys_exit

sd_recv_byte: ; read 8 bits of response
  ldx #8
  jmp sd_recv_bits

sd_basic_response_recv:     ; read 7 bits of response
  ldx #7
  jmp sd_recv_bits

sd_recv_bits: ; Receive number of bits - depends on X register
  lda #00
  sta tmp_1
@sd_basic_response_recv_bit:
  asl tmp_1                 ; Shift previous result by 1 bit
  dex
  lda #%00000100            ; Toggle clock with MOSI high, CS low
  sta VIA_PORTA
  lda #%00010100
  sta VIA_PORTA
  ; read 1 bit response
  lda VIA_PORTA             ; Shifting until MISO is on the right
  lsr
  lsr
  lsr
  and #%00000001            ; Mask out other bits
  jsr debug_a
  ora tmp_1                 ; OR with previous result and store.
  sta tmp_1
  cpx #0
  bne @sd_basic_response_recv_bit
  lda tmp_1             ; WHY?!
  pha                   ; TODO debug..
  pha
  lda #'/'
  jsr acia_print_char
  pla
  jsr hex_print_byte
  lda #' '
  jsr acia_print_char
  pla                   ; end debug

  rts                       ; All done.

debug_a:
  pha
  adc #48
  jsr acia_print_char
  pla
  rts

string_sd_not_detected:   .asciiz "SD card not detected"
string_sd_detected:       .asciiz "SD card detected"
string_sd_reset_fail:     .asciiz "SD card reset failed"
