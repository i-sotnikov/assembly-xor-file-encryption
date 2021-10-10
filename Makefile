.PHONY: all clean
TARGET = crypt

all: ${TARGET}

${TARGET}: ${TARGET}.asm
		fasm $< $@

clean:
		rm -f ${TARGET}
