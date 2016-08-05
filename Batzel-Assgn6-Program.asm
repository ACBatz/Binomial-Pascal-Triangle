; This program takes a number from the user, between 1 and 10, and generates binomial coefficients formatted into a Pascal Triangle.
;  It does this incrementing through columns and rows of Pascal's Triangle, making calls to a function that computes the binomial coefficient
;  through recursion, and formatting the display to look like a triangle.
; Author: Andrew C Batzel
; Course: CS370 14F8W1
; Last update: 10/18/2014

INCLUDE Irvine32.inc

; Prototypes of functions located in different files

PascalController PROTO  ; is contained in Binomial.asm
ReadInteger PROTO       ; is contained in Support.asm

.data

.code
main PROC

BeginningState:
    xor     EAX,EAX             ; clear EAX
    call    ReadInteger         ; get a number from user
    cmp     EAX,0               ; check if user enters zero
    je      UserExit            ; conditional jump if user wants to exit
    call    PascalController    ; call to output results based on user input
    jmp	  BeginningState      ; loops through program while user doesn't exit
UserExit:
    call    Crlf                ; new line
    exit
main ENDP

END main