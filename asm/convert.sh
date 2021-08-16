#!/bin/bash
mips-linux-gnu-gcc -EL -mips32r2 -nostdlib -Ttext 0x80000000 $1.s -o $1.elf
mips-linux-gnu-objdump -D $1.elf > $1_dis.s
mips-linux-gnu-objcopy -j .text -O binary $1.elf $1.bin
rm $1.elf