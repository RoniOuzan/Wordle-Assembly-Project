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