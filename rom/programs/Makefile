SOURCE_FILES = $(wildcard *.s)
PROGRAMS = $(addsuffix .bin, $(basename $(SOURCE_FILES)))

all: $(PROGRAMS)

%.bin: %.o ../boot/generated/rom_defs.o
	ld65 -o $@ -C program.cfg --dbgfile $(<:.o=.dbg) $^

%.o: %.s
	ca65 $< --cpu 65C02 --debug-info

clean:
	rm -f *.o *.bin *.dbg

.PHONY: all

