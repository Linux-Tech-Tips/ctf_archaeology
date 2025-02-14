# Python script to break a binary by replacing bytes

import sys

if len(sys.argv) != 3:
    print("Please supply args: <filename> <ADDRESS:BYTE,A2:B2,...>")

filename = sys.argv[1]
toBreak = sys.argv[2].strip().split(",")

with open(filename, "r+b") as f:
    for el in toBreak:
        pair = el.split(":")
        f.seek(int(pair[0], 0), 0)
        f.write(bytes([int(pair[1], 0)]))
