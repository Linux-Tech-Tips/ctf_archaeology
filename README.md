# University of Galway CompSoc CTF Challenge: Archaeology

This is a challenge I designed for the 2025 University of Galway CompSoc CTF Event, under the category of Reverse Engineering, of "very hard" difficulty.

Since this was meant for people with experience in CTFs, I decided to have a bit of fun with it.

## Challenge Files

The challenge contains an intro text and a singular file, called H4XG3N.iso, which isn't shipped in this repo.

The H4XG3N.iso file can be created from the source codes locally, by calling the script `./build.sh`, preferably with `nasm` and `python3` installed.

The intro text is as follows:

```
Looking through your family's old attic, you found a mysterious floppy disk. You managed to download a binary off it called H4XG3N.iso, must be something cool huh?
At this point, it's got to be ancient. For starters, you need to figure out how to run it. 

Even if you do though, how long has that floppy been laying around collecting dust? I sure hope no bits of the binary got damaged over the time!
```

## Challenge Solution

The way to solve this is to edit the H4XG3N.iso binary in a program such as hexedit, changing a select few bytes.

Firstly, we need to run the binary, but that can be achieved very simply using a virtualization tool such as qemu, with a command akin to `qemu-system-i386 H4XG3N.iso`.

The first thing a user reading the binary in hexedit might notice is that at byte 0x13, there is the opcode `FB` present, following the instruction `CD 10`. 
`CD 10` calls the system interrupt with ID 10, but `FB` is an instruction to set the interrupt flag, and is quite out of place, especially followed by an arbitrary number.
A skilled user may also realise that `FB` is very close to `EB` (single flipped bit), where `EB` is a jump instruction with one byte as its parameter.
Changing `FB` to `EB` reveals the first part of the flag, "CompSoc{".

Next up, a user reading through the binary in hexedit may observe a pattern of multiple XOR operations (opcode `34`) with numeric literals, performing operations on an important register.
However, in a line of numerous opcode `34` operations, a few of the opcodes are different, either `24` or `14`, both of which are a single bit flip away from `34`.
As `24` is AND and `14` is ADC (Add with Carry), they seem out of place in a line of XORs.
Changing all three back to `34` allows us to unlock the next part of the flag, leading to "CompSoc{23695-OEM-000".

Next, towards the end of the actual instruction code, at byte 0x80, the user can notice a conveniently placed opcode `06` followed by a numeric argument.
Opcode `06` is the PUSH instruction, which seems out of place, also considering that the surrounding instructions are either function calls or adds.
The number is, again, conveniently similar to opcode `04` which happens to be ADD to AL register, and which is also used in the surrounding bytes.
Changing this `06` to a `04` unlocks another piece of the puzzle, going from an innocent, but incorrect "CompSoc{23695-OEM-0009" to "CompSoc{23695-OEM-0009;;?5?<:8\*|".
(It is clear that the first flag isn't complete, since it's missing the closing bracket).

Following this revalation, we can look a bit more carefully at the binary, and find a peculiar thing at address 0x1A.
There are instructions which appear to print a number, and as part of it, 0x38 is added to it. 
However, knowing the ASCII table, we know that the digit characters start at offset 0x30, conveniently also a single bit flip away from 0x38.
Changing the 0x38 to 0x30 allows us to unlock the most of the rest of the flag, leading to "CompSoc{23695-OEM-0001337-7420" followed by 2 strange characters.

For the last part, the user really has to analyse the binary, figure out what it does, and find that there is a function/label that does numeric manipulation.
This label (for Devs - in the source code eloquently named 'martins_bullshit') takes a constant in BX and an argument in AX, does bitwise manipulation on BX, then XORs AX and BX.
Then, it prints the result in Ax, which is incorrect. 
Upon closer observation, it can be found that the constant in BX is statically set to 00, which clearly won't give us the answer we need - oh no, the bits must have erased away completely!
The user can then examine the bitwise multiplication in great detail, and figure out that, since we know the second of the two characters must be '}', for that the constant BX must be 7C.
Changing the zeroes to 7C gives us the final flag, "CompSoc{23695-OEM-0001337-74209}}".

This is the intended solution to this challenge. If anyone manages to solve it in any other way that gets the correct flag, be my guest.


## Author Notes

The fun of this challenge is both that's written in pure x86 assembly, and that conceptually, it's not that difficult to understand.
The intro text hints at bits being altered, so that should be fairly straightforward.
The fact that this can be run in qemu or a similar x86 emulator can be found using the `file` command.

The beauty of this is that for anyone to be able to solve this, they must have a good grasp of the x86 assembly language, and hopefully a table with the opcode bytes.
Any regular decompiler will not work, as those try to decompile binaries into C, which shouldn't really be possible here.
Decompiling using a specialised assembly decompiler is likely to work, but also won't help much without a good understanding of assembly in the first place.

Another note I'd like to point out is that each replaced instruction is exactly one bit flip away from the original one.
This took a bit of time and a bit of looking at the opcode table, but leads to a much more interesting challenge, and one which may be easier to crack, once the contestants understand the thought.

Lastly, the flag in this file in particular just so happens to be a string akin to a Windows 95 OEM key.
It conforms to a key format I found described online, though likely won't actually be usable in a Windows 95 installation.

Overall, I am quite fond of this challenge, both the specific file and the idea behind it.
It may not have reached its target audience though, as there were no solutions on the day of the event itself.

