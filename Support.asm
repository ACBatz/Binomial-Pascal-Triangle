INCLUDE Irvine32.inc

; Constants
    TRUE        equ	    1
    FALSE       equ	    0
    CR	      equ	    13
    LF	      equ	    10
    SPC	      equ	    32		; ASCII space
    UPPERLIMIT  equ     10

.data

    numberMsg   BYTE    'Enter an integer (1 thru 10 or 0 to exit): ',0             ; Prompt message to get a number value
    errorMsg    BYTE    'ERROR - Must enter a number between 1 and 10, inclusive',0 ;
    userNum     BYTE    ?

.code

;-----------------------------------------------------------------------
ReadInteger PROC
;
; Prompts the user to enter a number between 1 and 10, then stores the
;  value in the EAX register and checks to ensure that the number entered
;  by the user is within the limits.
; Returns: EAX - value of the number entered by the user
; Calls: WriteString, ReadChar, WriteChar, Crlf, IsLegal
;-----------------------------------------------------------------------
Start:
    xor     ECX,ECX	            ; Clear accumulator
    mov     BL,UPPERLIMIT       ; set BL to upperlimit of program
    mov     EDX,OFFSET numberMsg; EDX points to number prompt message
    call    WriteString         ; display message
GetNext:
    call    ReadChar            ; Get a keyboard value
    cmp	  AL, CR	            ; "ENTER" key pressed?
    je	  GetOut              ; Yes
    call	  isLegal             ; Check if number is allowed in current base
    jz	  GetNext         	  ; Is valid for base?
    call    WriteChar           ; Yes
    xchg	  EAX, ECX	       ; Get accumulated value
    movzx   EBX, BL	            ; convert base to long form
    mul	  EBX			  ; make space in accumulated value
    xchg	  EAX, ECX	       ; Restore updated accumulated value
    xchg	  AL, AH	            ; Get integer back in AL
    movzx   EAX, AL             ; Move integer into 32 bit register
    add	  ECX, EAX	       ; add digit to accumulated value
    jmp	  GetNext             ; repeat until user pressed "Enter"

NumberTooHigh:
    call    Crlf                ; new line
    mov     EDX,OFFSET errorMsg ; EDX points to error message
    call    WriteString         ; display error message
    call    Crlf                ; new line
    jmp     Start               ; begin ReadInteger function from initialization

GetOut:
    xchg    EAX, ECX	       ; return accumulated value to caller
    cmp     EAX,UPPERLIMIT      ; is number greater than upper limits of the program
    jg      NumberTooHigh       ; yes
    ret                         ; no

ReadInteger ENDP

;-----------------------------------------------------------------------
AsciiToDigit PROC 
;
; converts keystrokes from user into their digit equilivants
; Receives: AL - ascii value of keystroke
; Returns: AL - digit equilivant of keystroke
;-----------------------------------------------------------------------
    mov	  BH, AL  ; Save ASCII character
    cmp     AL, '0' ; is digit lower than zero
    jb      inValid ; yes
    cmp     AL, '9' ; is digit greater than 9
    jg      inValid ; yes
    and     AL, 0fh ; conversion from ASCII to numberal equilivant
    jmp     isValid ; go to valid exit of function
inValid:
    mov     AL, -1  ; Assume invalid conversion 
isValid:
    or      AL, AL  ; Set flags
    ret

AsciiToDigit ENDP

;-----------------------------------------------------------------------
IsLegal PROC
;
; checks to see if a number is valid given a particular base
; Receives: BL - base value from user
;           AL - number entered by user
; Returns: AL - 1 if valid 0 if not valid and sets zero flag for conditional jumps
;-----------------------------------------------------------------------
    mov     BH, AL		   ; save ascii
    call    AsciiToDigit
    mov	  AH, AL	        ; save binary conversion of ascii
    mov	  AL, FALSE	   ; assume invalid
    js      illegalExit
checkBase:
    cmp     AH, BL          ; AH input must be < BL
    jge     illegalExit
    mov     AL, TRUE        ; indicate valid conversion 
illegalExit:
    or      AL, AL          ; set flags
    mov	  AL, BH	        ; get ASCII in AL
    ret

IsLegal ENDP


NumToAsc  BYTE "0123456789"
;-----------------------------------------------------------------------
DigitToAscii PROC 
;
; converts a number value into proper ascii value equilivant
; Receives: AL - a number 0 - 15
; Returns: AL - ascii equilivant
;-----------------------------------------------------------------------
    mov     BH, AL      ; Save the digit
    mov     AL, -1      ; Assume invalid conversion
    cmp     BH, 9	    ; is digit great than largest allowed?
    jg      notValid    ; yes
    cmp     BH, 0       ; is digit lower than smalled allowed?
    jl      notValid    ; yes
    movzx   ESI, BH     ; set index from character string
    mov     AL, BYTE PTR NumToAsc[ESI]
notValid:
    or      AL, AL      ; Set flags 
    ret

DigitToAscii ENDP

;-----------------------------------------------------------------------
WriteInteger PROC USES EAX EBX ECX EDX
;
; converts a number from EAX into a given base in EBX and displays result
; Receives: EAX - users selected number
;           EBX - a base value
; Calls: DigitToAscii, WriteChar
;-----------------------------------------------------------------------
    xor	  ECX, ECX        ; Zero digit count register
    movzx	  EBX, BL		   ; Zero bh to 32-bits	
    or      EAX, EAX        ; Test for zero
    jnz     posNum          ; number is positive
    mov     AL, '0'         ; negative numbers become zero
    call    WriteChar       ; display zero
    jmp     WrtExit         ; jump to exit function
posNum:
    xor	  EDX, EDX	   ; clear high portion of 32-bit number
    mov     EBX,10          ; set EBX to a decimal base
    div	  EBX		   ; Divide EDX:EAX by EBX
    xchg	  EAX, EDX	   ; Get remainder into eax
    call	  DigitToAscii	   ; Attempt to convert 
    js	  posNum	        ; Invalid character, skip it for now
    push	  EAX		   ; Save ASCII digit on stack
    inc	  ECX	        ; Update Count digits
    xchg	  EDX, EAX	   ; Restore dividend
    or	  EAX, EAX	   ; check for zero
    jnz	  posNum	        ; Get possible next digit
loopDisp:	                  ; On entry ECX has number of digits on stack
    pop	  EAX             ; get number from stack
    call    WriteChar       ; display number
    loop	  loopDisp        ; loop however many times number was divided and pushed on stack
WrtExit:
    ret

WriteInteger ENDP

END