macro displayImage i, x, y, w, h
	mov dx, offset i
	mov [bmpLeft],x
	mov [bmpTop],y
	mov [bmpColSize], w
	mov [bmpRowSize], h
	call openShowBmp
endm

macro displayBackground i
	displayImage i, 0, 0, 320, 200
endm

proc openShowBmp near
	
	 
	call openBmpFile
	cmp [errorFile],1
	je @@exitProc
	
	call readBmpHeader
	
	call readBmpPalette
	
	call copyBmpPalette
	
	call showBMP
	
	 
	call closeBmpFile

@@exitProc:
	ret
endp openShowBmp
	
; input dx filename to open
proc openBmpFile near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@errorAtOpen
	mov [fileHandle], ax
	jmp @@exitProc
	
@@errorAtOpen:
	mov [errorFile],1
@@exitProc:	
	ret
endp openBmpFile

proc closeBmpFile near
	mov ah,3Eh
	mov bx, [fileHandle]
	int 21h
	ret
endp closeBmpFile

; Read 54 bytes the Header
proc readBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [fileHandle]
	mov cx,54
	mov dx, offset header
	int 21h
	
	pop dx
	pop cx
	ret
endp readBmpHeader

proc readBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp readBmpPalette

; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc copyBmpPalette	near														
	push cx
	push dx
	
	mov si,offset palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
copyNextColor:
	mov al,[si+2] 		; Red				
	shr al,2 			; divide by 4 Max (cos max is 63 and we have here max 255 ) (loosing color resolution).				
	out dx,al 						
	mov al,[si+1] 		; Green.				
	shr al,2            
	out dx,al 							
	mov al,[si] 		; Blue.				
	shr al,2            
	out dx,al 							
	add si,4 			; Point to next color.  (4 bytes for each color BGR + null)				
								
	loop copyNextColor
	
	pop dx
	pop cx
	
	ret
endp copyBmpPalette

proc drawHorizontalLine	near
	push si
	push cx
drawLine:
	cmp si,0
	jz exitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	 
	
	inc cx
	dec si
	jmp drawLine
	
	
exitDrawLine:
	pop cx
    pop si
	ret
endp drawHorizontalLine

proc drawVerticalLine near
	push si
	push dx
 
drawVertical:
	cmp si,0
	jz @@exitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	
	inc dx
	dec si
	jmp drawVertical
	
@@exitDrawLine:
	pop dx
    pop si
	ret
endp drawVerticalLine

; cx = col dx= row al = color si = height di = width 
proc rect
	push cx
	push di
nextVerticalLine:	
	
	cmp di,0
	jz @@endRect
	
	cmp si,0
	jz @@endRect
	call drawVerticalLine
	inc cx
	dec di
	jmp nextVerticalLine
	
	
@@endRect:
	pop di
	pop cx
	ret
endp rect
   
proc setGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp setGraphic

proc showBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[bmpRowSize]
	
	mov ax,[bmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[bmpLeft]
	
@@nextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[bmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	dec di
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[bmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset scrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[bmpColSize]  
	mov si,offset scrLine
	rep movsb ; Copy line to the screen
	
	pop dx
	pop cx
	 
	loop @@nextLine
	
	pop cx
	ret
endp showBMP 
