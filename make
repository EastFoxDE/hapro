#!/bin/usr/bash
nasm -f elf64 -Ox current.asm
ld -o current current.o
