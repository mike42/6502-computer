;
; Test for reading from SD card.
; Expects card to be wired CD, CS, DI, DO, CLK on PA0..PA5
;
.import acia_print_char, shell_newline, sys_exit, VIA_DDRA, hex_print_byte, VIA_PORTA, shell_rx_sleep_seconds

.segment "ZEROPAGE"
string_ptr: .res 2        ; Pointer for printing
out_tmp:    .res 1        ; Used for shifting bit out
in_tmp:     .res 1        ; Used when shifing bits in

.segment "BSS"
io_block_id:              .res 4
io_buffer:                .res 512

.segment "CODE"
main:
  jsr via_setup
  jsr sd_reset
  ; Set block ID to 0
  stz io_block_id
  stz io_block_id + 1
  stz io_block_id + 2
  stz io_block_id + 3
  ; Read and print first block
  jsr sd_read_single_block
  jsr print_io_buffer
  ; Read and print second block
  inc io_block_id
  jsr sd_read_single_block
  jsr print_io_buffer

  lda #0
  jmp sys_exit

; Pin direction PA7..PA0.
CS   = %00001000
MOSI = %00000100
MISO = %00000001
CLK  = %00000010

OUTPUT_PINS = CS | MOSI | CLK

; Set up pin directions on the VIA and set initial values.
via_setup:
  lda #(CS | MOSI)      ; CS and MOSI are high initially.
  sta VIA_PORTA
  lda #OUTPUT_PINS
  sta VIA_DDRA
  rts

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

; Reset sequence for SD card, places it in SPI mode, completes initialization.
sd_reset:
  ldx #74
@clock:
  jsr spi_nothing_byte    ; 80 cycles with MOSI and CS high.
  jsr spi_nothing_byte
  jsr spi_nothing_byte
  jsr spi_nothing_byte
  jsr spi_nothing_byte
  jsr spi_nothing_byte
  jsr spi_nothing_byte
  jsr spi_nothing_byte
  jsr spi_nothing_byte
  jsr spi_nothing_byte
  jsr sd_cmd_go_idle_state
  cmp #$01                 ; Check for idle state
  bne @sd_reset_fail
  jsr sd_cmd_send_if_cond
  cmp #01                  ; Expect command to be supported, indicating 2.x SD card.
  bne @sd_reset_fail
  jsr sd_cmd_read_ocr      ; Do not care about response here, but expect it to be supported
  cmp #$01
  bne @sd_reset_fail
  jsr sd_cmd_app_cmd       ; Send app command to activiate initialisation process
  cmp #$01
  bne @sd_reset_fail
  jsr sd_acmd_sd_send_op_cond
  cmp #$01                 ; Expect initialisation in progress.
  bne @sd_reset_fail
  ldx #20                  ; max attempts
@reset_wait:               ; Repeat last step until initialisation is complete
  phx
  jsr sd_cmd_app_cmd
  jsr sd_acmd_sd_send_op_cond
  plx
  cmp #$00                 ; Init complete
  beq @sd_reset_init_ok
  dex
  cpx #0                   ; max attempts exceeded
  bne @reset_wait          ; repeat up to maximum, falls through to failure otherwise
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
@sd_reset_init_ok:
  jsr sd_cmd_read_ocr      ; TODO read response bit here for CCS
  rts

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

  jsr sd_first_byte_of_response
  pha                 ; This will be 01 if everything is OK.

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
  lda #%10000111
  jsr sd_byte_send

  jsr sd_first_byte_of_response
  pha                 ; This will be 01 if command is valid / everything is OK
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  jsr sd_command_end
  pla                 ; Return first byte of response
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
  pha
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send

  jsr sd_command_end
  pla
  rts

; send SD card CMD55
sd_cmd_app_cmd:
  jsr sd_command_start
  lda #%01110111
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%11111111   ; Dummy CRC
  jsr sd_byte_send

  jsr sd_first_byte_of_response
  pha

  jsr sd_command_end
  pla
  rts

; send SD card ACMD41
sd_acmd_sd_send_op_cond:
  jsr sd_command_start
  lda #%01101001
  jsr sd_byte_send
  lda #%01000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%00000000
  jsr sd_byte_send
  lda #%11111111   ; Dummy CRC
  jsr sd_byte_send

  jsr sd_first_byte_of_response
  pha

  jsr sd_command_end
  pla
  rts

; send SD card CMD17
sd_read_single_block:
  jsr sd_command_start
  lda #%01010001
  jsr sd_byte_send
  lda io_block_id + 3
  jsr sd_byte_send
  lda io_block_id + 2
  jsr sd_byte_send
  lda io_block_id + 1
  jsr sd_byte_send
  lda io_block_id
  jsr sd_byte_send

  jsr sd_first_byte_of_response
  cmp #$00                        ; OK, block coming up
  bne @sd_read_single_block_fail
  jsr sd_first_byte_of_response
  cmp #$fe                        ; Start of block
  bne @sd_read_single_block_fail

  ldx #<io_buffer                 ; Set up pointer to I/O buffer
  stx string_ptr
  ldx #>io_buffer
  stx string_ptr + 1

@sd_read_page:                    ; read 255 bytes to I/O buffer, needs to be done twice
  ldy #$00
@sd_read_page_next_byte:
  lda #%11111111
  phy
  jsr sd_byte_send
  sta (string_ptr), Y
  ply
  cpy #$ff
  beq @sd_read_page_done
  iny
  jmp @sd_read_page_next_byte
@sd_read_page_done:               ; Done reading a page. Is this first or second?
  ; Check high byte of string_ptr for second page
  ldx #(>io_buffer + 1)
  cpx string_ptr + 1
  beq @sd_read_single_block_done
  ; Bump to next page and repeat
  stx string_ptr + 1
  jmp @sd_read_page
@sd_read_single_block_done:
  lda #%11111111                  ; 16 byte CRC (ignored).
  jsr sd_byte_send
  lda #%11111111
  jsr sd_byte_send
@sd_read_single_block_fail:
  jsr sd_command_end
  rts

print_io_buffer:
  ; Set up pointer to first page of I/O buffer
  ldx #<io_buffer
  stx string_ptr
  ldx #>io_buffer
  stx string_ptr + 1
  jsr hexdump_page
  ;jsr hexdump_page
  rts

hexdump_page:
  ; Hexdump one page of data, pointed to by string_ptr
  ldx #16
@hexdump_page_next_line:
  phx
  jsr hexdump_line
  plx
  cpx #0
  beq @hexdump_page_done
  dex
  jmp @hexdump_page_next_line
@hexdump_page_done:
  rts

; Given address in string_ptr, prints a line. Eg.
; 0c00  67 67 67 67 67 67 67 67  67 67 67 67 67 67 67 67  gggggggggggggggg
hexdump_line:
  ; Print memory address first
  lda string_ptr + 1      ;  High byte
  jsr hex_print_byte
  lda string_ptr          ;  Low byte
  jsr hex_print_byte
  lda #' '                ; Two spaces
  jsr acia_print_char
  jsr acia_print_char
  jsr hexdump_line_hex    ; Print 16 bytes hex
  lda #' '
  jsr acia_print_char     ; Extra space
  jsr hexdump_line_ascii  ; Print 16 bytes ascii
  ; Print line in ASCII
  ; Newline at the end
  jsr shell_newline
  ; Move pointer by 16 bytes
  clc                   ; First byte
  lda string_ptr
  adc #16
  sta string_ptr
  lda string_ptr + 1    ; Second byte if carry set
  adc #0
  sta string_ptr + 1
  rts

hexdump_line_hex:
  ; Print line in hex
  ldy #0
@hexdump_line_next_byte:
  lda (string_ptr), Y
  jsr hex_print_byte      ; Hex byte
  lda #' '                ; Spaces between bytes
  jsr acia_print_char
  iny
  cpy #8
  beq @hexdump_line_half_way
  cpy #16
  beq @hexdump_line_done
  jmp @hexdump_line_next_byte
@hexdump_line_half_way:
  lda #' '              ; Extra space after 8 bytes
  jsr acia_print_char
  jmp @hexdump_line_next_byte
@hexdump_line_done:
  rts

hexdump_line_ascii:
  ldy #0
@hexdump_line_ascii_next_byte:
  lda (string_ptr), Y     ; Print byte as ASCII
  cmp #128                ; Substitute with '.' if >= 128
  bcs @char_subst
  cmp #32                 ; Print if >= 32
  bcs @char_print
@char_subst:              ; Fallthrough to substitute
  lda #'.'
@char_print:
  jsr acia_print_char
  iny
  cpy #16
  beq @hexdump_line_ascii_done
  jmp @hexdump_line_ascii_next_byte
@hexdump_line_ascii_done:
  rts


; Send $ff to the SD card, return the first non-fill byte we get back in the A register.
; Returns $ff if the SD does not respond with a non-fill byte after 255 bytes.
sd_first_byte_of_response:
  ldx #$ff            ; Limit before failure
@spi_consume_fill_byte:
  lda #%11111111      ; Fill
  phx                 ; Preserve X, send the byte
  jsr sd_byte_send
  plx
  cmp #%11111111      ; Empty response?
  bne @spi_consume_fill_bytes_done
  dex                 ; Repeat up to limit
  cpx #$00
  bne @spi_consume_fill_byte
@spi_consume_fill_bytes_done:
  rts

spi_debug = 0               ; Triggers optional wrapper. Print everything!
sd_command_start:
  jsr spi_nothing_byte      ; Send 8 bits of nothing without SD selected
  lda #%11111111            ; Send 8 bits of nothing w/ SD selected
  jsr sd_byte_send
  rts

sd_command_end:
  lda #%11111111            ; Send 8 bits of nothing w/ SD selected
  jsr sd_byte_send
  jsr spi_nothing_byte      ; Send 8 bits of nothing without SD selected
.if spi_debug = 1
  jsr shell_newline
.endif
  rts

spi_nothing_byte:
  ldx #8                    ; Send 8 bits of nothing, without SD selected
@command_start_bit:
  lda #(MOSI | CS)
  sta VIA_PORTA
  lda #(CLK | MOSI | CS)
  dex
  cpx #0
  bne @command_start_bit
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

string_sd_reset_fail:     .asciiz "SD card reset failed"
