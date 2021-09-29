CA65=/usr/bin/ca65
LD65=/usr/bin/ld65

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

programs/test.bin: programs/test.s
	ca65 programs/test.s --cpu 65C02  --debug-info
	ld65 -o programs/test.bin -C program.cfg --dbgfile programs/test.dbg programs/test.o

programs/test2.bin: programs/test2.s
	ca65 programs/test2.s --cpu 65C02  --debug-info
	ld65 -o programs/test2.bin -C program.cfg --dbgfile programs/test2.dbg programs/test2.o


clean:
	rm -f boot.o boot.bin boot.dbg programs/test.bin programs/test.o programs/test.dbg

