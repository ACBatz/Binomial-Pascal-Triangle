INCLUDE Irvine32.inc

; Prototype of functions located in different files
WriteInteger PROTO

; Constants
SPC	equ	32    ; Ascii space value

.data
    userNum         WORD    ?   ; variable used to save the users input value
    triangleSpace   WORD    ?   ; variable used when creating pyramid of output values


.code
;-----------------------------------------------------------------------
PascalController PROC
;
; Creates the variables that are pushed on the stack for use in the Binomial
;  function and increments though both the n and r variables up to the users
;  prompted value while formatting the display to look like Pascals Triangle
; Receives: AX - number entered by user
; Calls: WriteChar, Binomial, WriteInteger
;-----------------------------------------------------------------------
    push    EBP                         ; save base pointer
    mov     EBP,ESP                     ; make base pointer the end of stack
    sub     ESP,8                       ; make space on stack for variables
    n_param TEXTEQU <WORD PTR [EBP-4]>  ; parameter used for variable n in binomial coefficient
    r_param TEXTEQU <WORD PTR [EBP-8]>  ; parameter used for variable r in binomial coefficient
    mov     DX,0                        ; holds n for increment
    mov     BX,0                        ; holds r for increment
    mov     userNum,AX                  ; save users input nuber
    mov     triangleSpace,AX            ; set number of spaces for pyramid
    dec     userNum                     ; reduce user's number to correspond with required output

N_Loop:
    call    Crlf                        ; new line
    cmp     DX,userNum                  ; when n variable exceeds user's number, return
    jg      Return
    movzx   ECX,triangleSpace           ; set counter to number of spaces needed to make a pryamid
    push    AX                          ; save current n variable while spaces are being generated
PyramidSpacing:
    mov     AL,SPC                      ; place space character in AL
    call    WriteChar                   ; display space
    loop    PyramidSpacing              ; loop while spaces are being generated to make a pyramid shape of output
    pop     AX                          ; restore n variable
    jmp     R_Loop                      ; jump to r variable loop

DereferenceR:
    mov     BX,0                        ; set r variable back to zero after it exceeds n
    inc     DX                          ; increment n variable for N_Loop
    dec     triangleSpace               ; decrement space to create pyramid effect
    jmp     N_Loop                      ; go back to N_Loop for next row of pyramid

R_Loop:
    cmp     BX,DX                       ; row is complete when r exceeds n
    jg      DereferenceR
    mov     n_param,DX                  ; set n variable
    mov     r_param,BX                  ; set r variable
    call    Binomial                    ; call to calculate binomial coefficient from n and r
    cmp     AX,0                        ; if result of call to Binomial is zero, don't display
    je      R_Loop
    movzx   EAX,AX                      ; move result into EAX for WriteInteger function
    call    WriteInteger                ; call that displays result of Binomial
    mov     AL,SPC                      ; display a space after each result
    call    WriteChar
    inc     BX                          ; increment r variable for next column
    jmp     R_Loop                      ; go back to top of R_Loop

Return:
    add     ESP,8                       ; remove variables from stack
    pop     EBP                         ; restore base pointer
    ret

PascalController ENDP

;-----------------------------------------------------------------------
Binomial PROC
;
; 
; Receives: 
; Returns: 
; Calls: 
;-----------------------------------------------------------------------
    push    EBP                 ; save base pointer
    mov     EBP,ESP             ; make base pointer the top of stack
    mov     DX,[EBP+12]         ; get n variable from stack
    mov     BX,[EBP+8]          ; get r variable from stack
    cmp     BX,DX               ; is r greater than ?
    jg      Return0             ; yes
    call    BinomialCompute     ; no
    jmp     Return

Return0:
    mov     EAX,0               ; set EAX to zero when r is greater than n

Return:
    pop     EBP                 ; restore base pointer
    ret

Binomial ENDP

;-----------------------------------------------------------------------
BinomialCompute PROC
;
; 
; Receives: 
; Returns: 
; Calls: 
;-----------------------------------------------------------------------
mov     AX,1
cmp     BX,0
je      Return
cmp     DX,BX
je      Return
push    DX
dec     DX
call    BinomialCompute
push    AX
push    BX
dec     BX
call    BinomialCompute
pop     BX
mov     DX,AX
pop     AX
add     AX,DX
pop     DX

Return:

ret

BinomialCompute ENDP

END