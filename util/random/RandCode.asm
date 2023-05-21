proc generateRandomWord
    call createFlagFile
    mov cx, 200
    call waitMilliseconds
    call readRandomWord
    ret
endp generateRandomWord

proc createFlagFile
    push ax
    push bx
    push cx
    push dx

    xor ax, ax
    mov ah, 3ch
    mov cx, 00h ; read only
    mov dx, offset RANDOM_WORD_FLAG_PATH

    int 21h

    mov bx, ax
    xor ax, ax
    mov ah, 3eh

    int 21h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp createFlagFile

proc readRandomWord
    push ax
    push bx
    push cx
    push dx

    xor ax, ax

    ; Opening the file:
    mov ah, 3Dh
    mov dx, offset RANDOM_WORD_PATH
    int 21h
    mov bx, ax

    ; Reading the file:
    xor ax, ax
    mov ah, 3fh
    mov cx, 05h ; 1 byte per 1 letter
    mov dx, offset answer
    int 21h
    
    ; Closing the file:
    xor ax, ax
    mov ah, 3eh
    int 21h


    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp readRandomWord

proc waitMilliseconds
    push cx        ; Save the original value of CX

    mov dx, cx     ; Move the number of milliseconds to DX
    mov cx, 10     ; Set the timer frequency to 1 ms

    ; Calculate the number of iterations needed to wait the desired time
    mul cx         ; Multiply DX by CX

    ; Loop to wait for the desired time
    loop_wait:
        mov cx, dx ; Restore the original value of CX
        mov ah, 86h ; Function 86h - Get System Time
        int 15h    ; Call interrupt 15h to get the current system time
        sub dx, cx ; Subtract the original value of CX from the current time
        cmp dx, ax ; Compare with the number of iterations needed
        jb loop_wait ; Jump back if the desired time has not elapsed

    pop cx ; Restore the original value of CX
    ret
endp waitMilliseconds

; proc generateRandomWord

;     mov ah, 3Dh
;     mov al, 0
;     mov dx, offset answersFilePath
;     int 21h

;     mov bx, ax

;     mov bx, 1
;     mov dx, 1550
;     call RandomByCsWord

;     mov dx, 6
;     mul dx

;     mov [randomGeneratedNumberHigh], dx 
;     mov [randomGeneratedNumberLow], ax

;     mov ah, 42h         ; DOS function to move file pointer
;     mov al, 0           ; Move from the beginning of the file
;     mov cx, [randomGeneratedNumberHigh]           ; High-order word of offset
;     mov dx, [randomGeneratedNumberLow]           ; Low-order word of offset (desired line number)
;     int 21h             ; Call DOS interrupt

;     mov ah, 3Fh     ; DOS function to read from file
;     mov cx, 05h     ; Maximum number of characters to read
;     mov dx, offset answer  ; Buffer to store the read line
;     int 21h         ; Call DOS interrupt

;     mov ah, 3Eh     ; DOS function to close a file
;     int 21h         ; Call DOS interrupt

;     ret
; endp generateRandomWord

; Description  : get RND between any bl and bh includs (max 0 -255)
; Input        : 1. BX = min (from 0) , DX, Max (till 64k -1)
; 			     2. RndCurrentPos a  word variable,   help to get good rnd number
; 				 	Declre it at DATASEG :  RndCurrentPos dw ,0
;				 3. EndOfCsLbl: is label at the end of the program one line above END start		
; Output:        AX - rnd num from bx to dx  (example 50 - 1550)
; More Info:
; 	BX  must be less than DX 
; 	in order to get good random value again and again the Code segment size should be 
; 	at least the number of times the procedure called at the same second ... 
; 	for example - if you call to this proc 50 times at the same second  - 
; 	Make sure the cs size is 50 bytes or more 
; 	(if not, make it to be more) 
; proc RandomByCsWord
;     push es
; 	push si
; 	push di
 
	
; 	mov ax, 40h
; 	mov	es, ax
	
; 	sub dx,bx  ; we will make rnd number between 0 to the delta between bl and bh
; 			   ; Now bh holds only the delta
; 	cmp dx,0
; 	jz @@ExitP
	
; 	push bx
	
; 	mov di, [word RndCurrentPos]
; 	call MakeMaskWord ; will put in si the right mask according the delta (bh) (example for 28 will put 31)
	
; @@RandLoop: ;  generate random number 
; 	mov bx, [es:06ch] ; read timer counter
	
; 	mov ax, [word cs:di] ; read one word from memory (from semi random bytes at cs)
; 	xor ax, bx ; xor memory and counter
	
; 	; Now inc di in order to get a different number next time
; 	inc di
; 	inc di
; 	cmp di,(EndOfCsLbl - start - 2)
; 	jb @@Continue
; 	mov di, offset start
; @@Continue:
; 	mov [word RndCurrentPos], di
	
; 	and ax, si ; filter result between 0 and si (the nask)
	
; 	cmp ax,dx    ;do again if  above the delta
; 	ja @@RandLoop
; 	pop bx
; 	add ax,bx  ; add the lower limit to the rnd num
		 
; @@ExitP:
	
; 	pop di
; 	pop si
; 	pop es
; 	ret
; endp RandomByCsWord

; Proc MakeMaskWord    
;     push dx
	
; 	mov si,1
    
; @@again:
; 	shr dx,1
; 	cmp dx,0
; 	jz @@EndProc
	
; 	shl si,1 ; add 1 to si at right
; 	inc si
	
; 	jmp @@again
	
; @@EndProc:
;     pop dx
; 	ret
; endp  MakeMaskWord

; proc generateRandomWord
;     ; Open the file
;     mov ah, 3Dh     ; DOS function to open a file
;     mov al, 0       ; Open for reading
;     mov dx, offset answersFilePath ; File name
;     int 21h         ; Call DOS interrupt

;     jc file_error   ; Jump if there was an error opening the file
;     mov [file_handle], ax      ; Save the file handle

;     ; Get the size of the file
;     mov ah, 42h     ; DOS function to get file size
;     mov al, 2       ; Get file size in bytes
;     mov dx, ax      ; File handle
;     xor cx, cx      ; Clear CX to receive file size
;     int 21h         ; Call DOS interrupt

;     jc file_error   ; Jump if there was an error getting the file size

;     ; Generate a random position within the file
;     xor ah, ah      ; Clear AH
;     div cx          ; Divide DX:AX by CX
;     mov dx, ax      ; Remainder (random position within file)

;     ; Calculate the offset to the random position
;     mov bx, 5       ; Each line contains 5 letters
;     mul bx          ; Multiply DX:AX by 5
;     mov cx, ax      ; Offset (random position within file)

;     ; Seek to the random position within the file
;     mov ah, 42h     ; DOS function to move file pointer
;     mov al, 0       ; Move from the beginning of the file
;     mov dx, cx      ; Offset (random position within file)
;     mov bx, ax      ; Clear BX
;     mov cx, 0       ; High-order word of offset
;     mov dx, bx      ; Low-order word of offset
;     mov bx, [file_handle]  ; File handle
;     int 21h         ; Call DOS interrupt

;     jc file_error   ; Jump if there was an error seeking within the file

;     ; Read the word from the file
;     mov ah, 3Fh     ; DOS function to read from file
;     mov cx, 5       ; Read 5 characters (letters)
;     mov dx, offset answer  ; Buffer to store the read word
;     int 21h         ; Call DOS interrupt

;     jc file_error   ; Jump if there was an error reading from the file

;     ; Print the randomly read word
;     mov ah, 09h     ; DOS function to print string
;     mov dx, offset answer  ; Pointer to the buffer
;     int 21h         ; Call DOS interrupt

;     ; Close the file
;     mov ah, 3Eh     ; DOS function to close a file
;     mov bx, [file_handle]  ; File handle
;     int 21h         ; Call DOS interrupt

;     ret
; endp generateRandomWord

; file_error:
;     ; Handle file error here
;     ; Print an error message or perform error handling routine

;     ; Terminate the program
;     mov ah, 4Ch     ; DOS function to exit program
;     mov al, 1       ; Return code 1 to indicate an error
;     int 21h         ; Call DOS interrupt