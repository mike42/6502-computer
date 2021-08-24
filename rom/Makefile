MINIPRO=minipro

all: rom.bin

rom.bin: basic custom
	cat basic/basic.bin custom/boot.bin > rom.bin

basic:
	$(MAKE) -C basic

custom:
	$(MAKE) -C custom

clean:
	rm -f rom.bin
	$(MAKE) -C basic clean
	$(MAKE) -C custom clean

flashrom: rom.bin
	$(MINIPRO) -p AT28C256 -w rom.bin

.PHONY: all basic custom flashrom
