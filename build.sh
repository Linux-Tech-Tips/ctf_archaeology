#!/bin/bash

# Script to build (and break) the H4XG3N.iso file

nasm -o H4XG3N.iso H4XG3N.s

python3 "./break.py" H4XG3N.iso 0x13:0xFB,0x1A:0x38,0x21:0x00,0x3A:0x24,0x42:0x14,0x4E:0x24,0x80:0x06

