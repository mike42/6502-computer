;
; Test for reading from SD card.
; Expects card to be wired CD, CS, DI, DO, CLK on PA0..PA5
;
.import acia_print_char, shell_newline, sys_exit, VIA_DDRA, hex_print_byte, VIA_PORTA, shell_rx_sleep_seconds

.segment "ZEROPAGE"
string_ptr: .res 2        ; Pointer for printing
out_tmp: .res 1           ; Used for shifting bit out
in_tmp: .res 1            ; Used when shifing bits in

.segment "CODE"
main:
  jsr via_setup
  jsr sd_detect
  jsr sd_reset
  lda #0
  jmp sys_exit

; Pin direction PA7..PA0.
CD   = %00000001
CS   = %00000010
MOSI = %00000100
MISO = %00001000
CLK  = %00010000

OUTPUT_PINS = CS | MOSI | CLK

; Set up pin directions on the VIA and set initial values.
via_setup:
  lda #(CS | MOSI)      ; CS and MOSI are high initially.
  sta VIA_PORTA
  lda #OUTPUT_PINS
  sta VIA_DDRA
  rts

; Detect SD card. Checks the CD flag on PA0.
sd_detect:
  lda VIA_PORTA
  and #CD    ; Check CD. 0 is card not present, 1 is card present.
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

; Reset sequence for SD card, places it in SPI mode etc.
sd_reset:
  ; Toggle clock 74 times with MOSI and CS high.
  ldx #74
@clock:
  lda #(MOSI | CS)
  sta VIA_PORTA
  lda #(MOSI | CS | CLK)
  sta VIA_PORTA
  dex
  cpx #0
  bne @clock
  jsr sd_cmd_go_idle_state
  cmp #$01                 ; Reset OK?
  bne @sd_reset_fail
  jsr sd_cmd_send_if_cond
  cmp #09                  ; Expect command to not be supported.
  bne @sd_reset_fail
  jsr sd_cmd_read_ocr
  rts
@sd_reset_fail:
  ldx #<string_sd_reset_fail
  stx string_ptr
  ldx #>string_sd_reset_fail
  stx string_ptr + 1
  jsr print_string
  jsr shell_newline
  ; Not OK. Terminate program.
  lda #1
  jmp sys_exit

; send SD card CMD0
sd_cmd_go_idle_state:
  ; Select chip
  jsr sd_command_start
  ; Send command
  lda #%01000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%10010101
  jsr sd_byte_send

  lda #%11111111      ; One byte fill? (is this even byte-aligned?)
  jsr sd_byte_send

  lda #%11111111      ; Response comes through here.
  jsr sd_byte_send
  pha                 ; This will be 01 if everything is OK.

  lda #%11111111      ; Another fill byte seems to help here.
  jsr sd_byte_send

  jsr sd_command_end
  pla
  rts

; send SD card CMD8
sd_cmd_send_if_cond:
  ; Select chip
  jsr sd_command_start
  lda #%01001000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000001
  jsr sd_byte_send
  lda #%10101010
  jsr sd_byte_send
  lda #%00001111
  jsr sd_byte_send

  lda #%11111111      ; One byte fill?
  jsr sd_byte_send
  lda #%11111111      ; 5 byte response maybe?!
  jsr sd_byte_send
  pha                 ; This will be 09 if command is invalid
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  jsr sd_command_end
  pla                 ; Return that initial value
  rts

; send SD card CMD58
sd_cmd_read_ocr:
  jsr sd_command_start
  lda #%01111010
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%01110101
  jsr sd_byte_send

  lda #%11111111      ; Fill
  jsr sd_byte_send

  lda #%11111111      ; 5 byte response
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send

  lda #%11111111      ; More fill to check for expected 0xFF response.
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send

  jsr sd_command_end
  rts

spi_debug = 1               ; Optional wrapper. Print everything!
sd_command_start:
  lda #0
  sta VIA_PORTA
  rts

sd_command_end:
  ; De-select chip
  lda #(MOSI | CS)
  sta VIA_PORTA
.if spi_debug = 1
  jsr shell_newline
.endif
  rts

sd_byte_send:
.if spi_debug = 1
  phx
  phy
  pha
  jsr hex_print_byte
  lda #'/'
  jsr acia_print_char
  pla
  ply
  plx
  jsr sd_byte_send_real
  phx
  phy
  pha
  jsr hex_print_byte
  lda #' '
  jsr acia_print_char
  pla
  ply
  plx
  rts
.endif
sd_byte_send_real:        ; Send the byte stored in the A register
  ldx #8
  sta out_tmp
  stz in_tmp
@sd_send_bit:             ; Send one bit
  asl in_tmp
  asl out_tmp             ; Carry bit holds bit to send.
  bcs @sd_send_1
@sd_send_0:               ; Send a 0
  lda #0
  sta VIA_PORTA
  lda #CLK
  sta VIA_PORTA
  ;jsr debug_0_sent
  jmp @sd_send_bit_done
@sd_send_1:               ; Send a 1
  lda #MOSI
  sta VIA_PORTA
  lda #(MOSI | CLK)
  sta VIA_PORTA
  ;jsr debug_1_sent
@sd_send_bit_done:        ; Check received bit
  lda VIA_PORTA
  and #MISO
  cmp #MISO
  beq @sd_recv_1
@sd_recv_0:               ; Received a 0 - nothing to do.
;  jsr debug_0_sent
  jmp @sd_recv_done
@sd_recv_1:               ; Received a 1
  lda in_tmp
  ora #%00000001
  sta in_tmp
;  jsr debug_1_sent
@sd_recv_done:
  dex
  cpx #0
  bne @sd_send_bit       ; Repeat until all 8 bits are sent
;  jsr debug_byte_done
  lda in_tmp
;  jsr hex_print_byte
;  jsr debug_byte_done
  rts

string_sd_not_detected:   .asciiz "SD card not detected"
string_sd_detected:       .asciiz "SD card detected"
string_sd_reset_fail:     .asciiz "SD card reset failed"
