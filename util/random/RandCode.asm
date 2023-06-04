macro waitMilliseconds a
	mov cx, a
	call wait_milliseconds
endm

proc wait_milliseconds
	push ax
    push cx
	push dx

    mov dx, cx
    mov cx, 10

    mul cx

    loop_wait:
        mov cx, dx
        mov ah, 86h
        int 15h
        sub dx, cx
        cmp dx, ax
        jb loop_wait

	pop dx
    pop cx
	pop ax
	ret
endp wait_milliseconds

proc generateRandomWord

    mov ah, 3Dh
    mov al, 0
    mov dx, offset answersFilePath
    int 21h

    mov [answerFileHandle], bx

    mov bx, 0
    mov dx, 14091
    call RandomByCsWord

    mov dx, 6
    mul dx

    mov [randomGeneratedNumberHigh], dx 
    mov [randomGeneratedNumberLow], ax

	mov bx, [answerFileHandle]
    mov ah, 42h         ; DOS function to move file pointer
    mov al, 0           ; Move from the beginning of the file
    mov cx, [randomGeneratedNumberHigh]           ; High-order word of offset
    mov dx, [randomGeneratedNumberLow]           ; Low-order word of offset (desired line number)
    int 21h             ; Call DOS interrupt

    mov ah, 3Fh     ; DOS function to read from file
    mov cx, 05h     ; Maximum number of characters to read
    mov dx, offset answer  ; Buffer to store the read line
    int 21h         ; Call DOS interrupt

    mov ah, 3Eh     ; DOS function to close a file
    int 21h         ; Call DOS interrupt

    ret
endp generateRandomWord

; Description  : get RND between any bl and bh includs (max 0 -255)
; Input        : 1. BX = min (from 0) , DX, Max (till 64k -1)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
; 				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
; More Info:
; 	BX  must be less than DX 
; 	in order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
proc RandomByCsWord
    push es
	push si
	push di


	mov ax, 40h
	mov	es, ax

	sub dx,bx  ; we will make rnd number between 0 to the delta between bl and bh
			   ; Now bh holds only the delta
	cmp dx,0
	jz @@ExitP

	push bx

	mov di, [word RndCurrentPos]
	call MakeMaskWord ; will put in si the right mask according the delta (bh) (example for 28 will put 31)

@@RandLoop: ;  generate random number 
	mov bx, [es:06ch] ; read timer counter

	mov ax, [word cs:di] ; read one word from memory (from semi random bytes at cs)
	xor ax, bx ; xor memory and counter

	; Now inc di in order to get a different number next time
	inc di
	inc di
	cmp di,(EndOfCsLbl - start - 2)
	jb @@Continue
	mov di, offset start
@@Continue:
	mov [word RndCurrentPos], di

	and ax, si ; filter result between 0 and si (the nask)

	cmp ax,dx    ;do again if  above the delta
	ja @@RandLoop
	pop bx
	add ax,bx  ; add the lower limit to the rnd num
	 
@@ExitP:

	pop di
	pop si
	pop es
	ret
endp RandomByCsWord

Proc MakeMaskWord    
    push dx

	mov si,1
  
@@again:
	shr dx,1
	cmp dx,0
	jz @@EndProc

	shl si,1 ; add 1 to si at right
	inc si

	jmp @@again

@@EndProc:
    pop dx
	ret
endp  MakeMaskWord