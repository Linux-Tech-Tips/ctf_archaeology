; H4XG3N.iso
; CTF challenge program to generate the CompSoc FLAG
; Bare-metal 16-bit x86 executable, to be run directly without OS

org 0x7C00 ; Tell the assembler at what address will the code be executed (0x7C00 is where bios loads it)
bits 16 ; Tell the assembler to make 16 bit bytecode (this is what the CPU expects when it boots)

; jump to main
jmp main

; ---------------- data ----------------
; since there's no OS, we need data to exist in the assembled binary file
;  -> 'db' is an assembler thing to add data following it as bytes here in the assembled executable (under the label flag_head)
flag_head: db "CompSoc", 0

; ---------------- function: print a null terminated string ----------------
; input: string pointer in SI
; modifies AX, SI
puts:
  mov ah, 0x0E ; set interrupt INT 0x10 function code to 0x0E (teletype text output to screen)
.loop:
  lodsb ; load a byte pointed to by SI and increment SI
  or al, al ; or register AL with itself - 0 if AL=0, 1 otherwise (ZF set if AL=0)
  jz .done ; jump to done if zero flag is set in line above
  int 0x10 ; call interrupt INT 0x10 with function code in AH
  jmp .loop ; jump back, next iteration
.done:
  ret

; ---------------- function: print a single-digit number from a register as an ASCII digit ----------------
; input: smallest digit of number in AX
put_digit:
  ; since this function doesn't modify AX, we first need to store the original AX to the stack
  push ax
  mov ah, 0x0E ; set interrupt INT 0x10 function code to 0x0E to print text to screen
  add al, 0x30
  int 0x10
  pop ax
  rep ret

; is this a function? I don't even know lol close enough
martins_bullshit:
  mov bl, 0x7C
  rol bl, 4
  not bl
  xor ax, bx
  mov ah, 0x0E
  int 0x10
  ret


; ---------------- main function ----------------
main:

  ; FLAG PART 1 - Print 'CompSoc'
  mov si, flag_head ; load the pointer to the string
  call puts ; call the print function

  ; FLAG PART 2 - Individually print '{23695-OEM-'
  mov ah, 0x0E ; set INT 0x10 function code to print (0x0E)
  mov al, 0x7B ; set AL (print content) to the first character of flag
  int 0x10 ; call INT 0x10 to print character
  xor al, 0x49 ; XOR to get to the next character
  int 0x10 ; print next character
  xor al, 0x01 ; XOR to get character 3
  int 0x10 ; print next character
  xor al, 0x05 ; XOR 4
  int 0x10 ; print next character
  xor al, 0x0F ; XOR 5
  int 0x10 ; print next character
  xor al, 0x0C ; XOR 6
  int 0x10 ; print next character
  xor al, 0x18 ; XOR 7
  int 0x10 ; print next character
  xor al, 0x62 ; XOR 8
  int 0x10 ; print next character
  xor al, 0x0A ; XOR 9
  int 0x10 ; print next character
  xor al, 0x08 ; XOR 10
  int 0x10 ; print next character
  xor al, 0x60 ; XOR 11
  int 0x10 ; print next character

  ; FLAG PART 3 - print '0001337-74209}' in multiple parts
  ; 1. printing 3x '0' in the most convoluted way possible
  mov cx, 0xFF
  mov ax, cx
  xchg cx, ax
.decrement:
  shr ax, 1
  shrd cx, ax, 1
  loop .decrement
  mov ah, 0x0E
  add al, 0x30
  int 0x10
  int 0x10
  int 0x10
  ; 2. printing '1337-' by adding to a register and using the 'put_digit' function
  mov ax, 0x01
  call put_digit
  add al, 2
  call put_digit
  call put_digit
  add al, 4
  call put_digit
  sub al, 10
  call put_digit
  ; 3. printing '74209}'
  ; 3.1. the '7' should be easy to give contestants a break, the '420' constant to be funny (and annoy people since it won't ever change)
  add al, 10
  call put_digit
  mov al, 4
  call put_digit
  mov al, 2
  call put_digit
  mov al, 0
  call put_digit
  ; 3.2. the '9}' has to be extra annoying
  mov al, 0x01
  call martins_bullshit
  mov al, 0x45
  call martins_bullshit
  

; End the program by putting the CPU into a loop
jmp $ ; jump to the current address


; Make it bootable
; an x86 boot sector needs to end with the bytes 0x55 0xAA
times (510 - ($ - $$)) db 0 ; fill the rest of the file with 0s (sector size is 512b so it is (512 - <2 bytes signature> - <current position>) 0s), the 'times' macro will assemble the next command n times, so n times define byte 0
dw 0xAA55 ; the magic bytes (defined as a word, x86 is a little endian system, so it's 0xAA55)
