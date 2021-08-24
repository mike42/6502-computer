CA65=/usr/bin/ca65
LD65=/usr/bin/ld65

boot.bin: boot.o
	$(LD65) -o boot.bin \
		-C ../sbc.cfg \
		boot.o

boot.o: boot.s
	$(CA65) --cpu 65C02 boot.s

clean:
	rm -f boot.o boot.bin

