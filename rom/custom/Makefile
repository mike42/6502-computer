CA65=/usr/bin/ca65
LD65=/usr/bin/ld65

all: boot.bin programs

programs:
	$(MAKE) -C programs

boot.bin: boot.o
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

clean:
	rm -f boot.o boot.bin boot.dbg
	$(MAKE) -C programs clean

.PHONY: all programs

