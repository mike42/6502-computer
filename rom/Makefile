MINIPRO=minipro

all: rom.bin programs

rom.bin: basic boot
	cat basic/basic.bin boot/boot.bin > rom.bin

basic:
	$(MAKE) -C basic

boot:
	$(MAKE) -C boot

programs:
	$(MAKE) -C programs

clean:
	rm -f rom.bin
	$(MAKE) -C basic clean
	$(MAKE) -C boot clean
	$(MAKE) -C programs clean

flashrom: rom.bin
	$(MINIPRO) -p AT28C256 -w rom.bin

.PHONY: all basic boot programs flashrom

