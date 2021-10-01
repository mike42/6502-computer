CA65=/usr/bin/ca65
LD65=/usr/bin/ld65

all: boot.bin generated/rom_defs.o

boot.bin boot.dbg: boot.o
	$(LD65) \
		--dbgfile boot.dbg \
		-o boot.bin \
		-C boot.cfg \
		boot.o

boot.o: boot.s
	$(CA65) \
		--cpu 65C02 \
		--debug-info \
		boot.s

generated/rom_defs.o: generated/rom_defs.s
		$(CA65) \
		--cpu 65C02 \
		--debug-info \
		boot.s

generated/rom_defs.s: boot.dbg
	python3 generated/generate_rom_defs.py

clean:
	rm -f boot.o boot.bin boot.dbg generated/rom_defs.s generated/rom_defs.o

.PHONY: all

