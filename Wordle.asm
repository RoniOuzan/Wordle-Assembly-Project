IDEAL
MODEL small

STACK 0f500h

MENU_BACKGROUND  equ 'Menu.bmp'
START_BUTTON equ 'Start.bmp'
HELP_BUTTON equ 'Help.bmp'
EXIT_BUTTON equ 'Exit.bmp'
HELP_TEXT equ 'HelpText.bmp'
GAME_LAYOUT equ 'Game.bmp'
 
BMP_WIDTH = 320
 

DATASEG

    ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
 
	FileHandle	dw ?
	Header 	    db 54 dup(0)
	Palette 	db 400h dup (0)
	
	SmallPicName db 'Pic48X78.bmp',0
	
	
	BmpFileErrorMsg    	db 'Error At Opening Bmp File', 0dh, 0ah,'$'
	ErrorFile           db 0
    BB db "BB..",'$'
	; array for mouse int 33 ax=09 (not a must) 64 bytes
	
	 
	 
	Color db ?
	Xclick dw ?
	Yclick dw ?
	Xp dw ?
	Yp dw ?
	SquareSize dw ?
	 
	BmpLeft dw ?
	BmpTop dw ?
	BmpColSize dw ?
	BmpRowSize dw ?
	
	WidthClick dw ?
	HeightClick dw ?
	GotClick db ?

;----------------------------------------------------

	FileMenu db MENU_BACKGROUND, 0
	FileStartButton db START_BUTTON, 0
	FileHelpButton db HELP_BUTTON, 0
	FileExitButton db EXIT_BUTTON, 0
	FileHelpText db HELP_TEXT, 0
	FileGameLayout db GAME_LAYOUT, 0

;----------------------------------------------------

	MouseClickInfo dw ?
	MouseXPos dw ?
	MouseYPos dw ?
	
	MouseInPos dw ?

;----------------------------------------------------

; 	W db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
; 	     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,

;----------------------------------------------------

	a dw ?
	b dw ?
	c dw ?
	d dw ?
	e dw ?
	f dw ?
	g dw ?
	
	 
CODESEG
 


 
start:
	mov ax, @data
	mov ds, ax
	
	call SetGraphic
 
	call Game
	
		
exit:
	mov dx, offset BB
	mov ah,9
	;int 21h
	
	mov ah,0
	int 16h
	
	mov ax,2
	int 10h

	
	mov ax, 4c00h
	int 21h
	

	
;==========================
;==========================
;===== Procedures  Area ===
;==========================
;==========================

proc Game
	call DisplayBackground
	call DisplayButtons

	call WaitForStart

	ret
endp Game

proc DisplayBackground
	mov dx, offset FileMenu
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp
	
	ret
endp DisplayBackground

proc DisplayButtons
	mov dx, offset FileStartButton
	mov [BmpLeft],96
	mov [BmpTop],80
	mov [BmpColSize], 128
	mov [BmpRowSize], 32
	call OpenShowBmp

	mov dx, offset FileHelpButton
	mov [BmpLeft],96
	mov [BmpTop],120
	mov [BmpColSize], 128
	mov [BmpRowSize], 32
	call OpenShowBmp

	mov dx, offset FileExitButton
	mov [BmpLeft],96
	mov [BmpTop],160
	mov [BmpColSize], 128
	mov [BmpRowSize], 32
	call OpenShowBmp

	ret
endp DisplayButtons

proc WaitForStart

	MenuLoop:
		; Start
		mov [Xclick], 96
		mov [Yclick], 80
		mov [WidthClick], 128
		mov [HeightClick], 32
		call WaitTillGotClickOnSomePointAsync
		
		cmp [GotClick], 1
		je StartButtonClicked
		
		; Help
		mov [Xclick], 96
		mov [Yclick], 120
		mov [WidthClick], 128
		mov [HeightClick], 32
		call WaitTillGotClickOnSomePointAsync
		
		cmp [GotClick], 1
		je HelpButtonClicked
		
		
		; mov ax, 1
		; int 33h
		; 
		; ; Start
		; call ReadMouse
		; 
		; mov [Xclick], 96
		; mov [Yclick], 80
		; mov [WidthClick], 128
		; mov [HeightClick], 32
		; call IfMouseInPose
		; cmp [MouseInPos], 1
		; je StartButtonClicked
		; 
		; ; Help
		; mov [Xclick], 96
		; mov [Yclick], 120
		; mov [WidthClick], 128
		; mov [HeightClick], 32
		; call IfMouseInPose
		; cmp [MouseInPos], 1
		; je HelpButtonClicked
		; 
		; mov ax, 2
		; int 33h

		jmp MenuLoop

	ret
endp WaitForStart
	
StartButtonClicked:
	call StartGame

HelpButtonClicked:
	call DisplayHelp

proc StartGame
	mov dx, offset FileGameLayout
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp

	; mov dx, offset FileExitButton
	; mov [BmpLeft],174
	; mov [BmpTop],12
	; mov [BmpColSize], 128
	; mov [BmpRowSize], 32
	; call OpenShowBmp

	
	GameLoop:
		; mov [Xclick], 174
		; mov [Yclick], 12
		; mov [WidthClick], 128
		; mov [HeightClick], 32
		; call WaitTillGotClickOnSomePointAsync
		; cmp [GotClick], 1
		; je GoToMenu
		
		mov ah, 0h
		int 16h
		cmp ah, 1
		je GoToMenu
		
		jmp GameLoop

	ret
endp StartGame

GoToMenu:
	call Game


proc DisplayHelp
	mov dx, offset FileHelpText
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320	
	mov [BmpRowSize], 200
	call OpenShowBmp

	mov dx, offset FileExitButton
	mov [BmpLeft],96
	mov [BmpTop],164
	mov [BmpColSize], 128
	mov [BmpRowSize], 32
	call OpenShowBmp

	mov [Xclick], 96
	mov [Yclick], 164
	mov [WidthClick], 128
	mov [HeightClick], 32
	call WaitTillGotClickOnSomePoint
	cmp [GotClick], 1
	je GoToMenu

	ret
endp DisplayHelp


;-----------------------------------------------------------;
;                              BMP                          ;
;-----------------------------------------------------------;

proc OpenShowBmp near
	
	 
	call OpenBmpFile
	cmp [ErrorFile],1
	je @@ExitProc
	
	call ReadBmpHeader
	
	call ReadBmpPalette
	
	call CopyBmpPalette
	
	call ShowBMP
	
	 
	call CloseBmpFile

@@ExitProc:
	ret
endp OpenShowBmp

 
 
	
; input dx filename to open
proc OpenBmpFile	near						 
	mov ah, 3Dh
	xor al, al
	int 21h
	jc @@ErrorAtOpen
	mov [FileHandle], ax
	jmp @@ExitProc
	
@@ErrorAtOpen:
	mov [ErrorFile],1
@@ExitProc:	
	ret
endp OpenBmpFile
 
 
 



proc CloseBmpFile near
	mov ah,3Eh
	mov bx, [FileHandle]
	int 21h
	ret
endp CloseBmpFile




; Read 54 bytes the Header
proc ReadBmpHeader	near					
	push cx
	push dx
	
	mov ah,3fh
	mov bx, [FileHandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	
	pop dx
	pop cx
	ret
endp ReadBmpHeader



proc ReadBmpPalette near ; Read BMP file color palette, 256 colors * 4 bytes (400h)
						 ; 4 bytes for each color BGR + null)			
	push cx
	push dx
	
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	
	pop dx
	pop cx
	
	ret
endp ReadBmpPalette


; Will move out to screen memory the colors
; video ports are 3C8h for number of first color
; and 3C9h for all rest
proc CopyBmpPalette		near					
										
	push cx
	push dx
	
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0  ; black first							
	out dx,al ;3C8h
	inc dx	  ;3C9h
CopyNextColor:
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
								
	loop CopyNextColor
	
	pop dx
	pop cx
	
	ret
endp CopyBmpPalette


 
 
proc DrawHorizontalLine	near
	push si
	push cx
DrawLine:
	cmp si,0
	jz ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	 
	
	inc cx
	dec si
	jmp DrawLine
	
	
ExitDrawLine:
	pop cx
    pop si
	ret
endp DrawHorizontalLine



proc DrawVerticalLine	near
	push si
	push dx
 
DrawVertical:
	cmp si,0
	jz @@ExitDrawLine	
	 
    mov ah,0ch	
	int 10h    ; put pixel
	
	 
	
	inc dx
	dec si
	jmp DrawVertical
	
	
@@ExitDrawLine:
	pop dx
    pop si
	ret
endp DrawVerticalLine



; cx = col dx= row al = color si = height di = width 
proc Rect
	push cx
	push di
NextVerticalLine:	
	
	cmp di,0
	jz @@EndRect
	
	cmp si,0
	jz @@EndRect
	call DrawVerticalLine
	inc cx
	dec di
	jmp NextVerticalLine
	
	
@@EndRect:
	pop di
	pop cx
	ret
endp Rect



proc DrawSquare
	push si
	push ax
	push cx
	push dx
	
	mov al,[Color]
	mov si,[SquareSize]  ; line Length
 	mov cx,[Xp]
	mov dx,[Yp]
	call DrawHorizontalLine

	 
	
	call DrawVerticalLine
	 
	
	add dx ,si
	dec dx
	call DrawHorizontalLine
	 
	
	
	sub  dx ,si
	inc dx
	add cx,si
	dec cx
	call DrawVerticalLine
	
	
	 pop dx
	 pop cx
	 pop ax
	 pop si
	 
	ret
endp DrawSquare




 
   
proc  SetGraphic
	mov ax,13h   ; 320 X 200 
				 ;Mode 13h is an IBM VGA BIOS mode. It is the specific standard 256-color mode 
	int 10h
	ret
endp 	SetGraphic

 

 
 
 


proc ShowBMP 
; BMP graphics are saved upside-down.
; Read the graphic line by line (BmpRowSize lines in VGA format),
; displaying the lines from bottom to top.
	push cx
	
	mov ax, 0A000h
	mov es, ax
	
	mov cx,[BmpRowSize]
	
 
	mov ax,[BmpColSize] ; row size must dived by 4 so if it less we must calculate the extra padding bytes
	xor dx,dx
	mov si,4
	div si
	cmp dx,0
	mov bp,0
	jz @@row_ok
	mov bp,4
	sub bp,dx

@@row_ok:	
	mov dx,[BmpLeft]
	
@@NextLine:
	push cx
	push dx
	
	mov di,cx  ; Current Row at the small bmp (each time -1)
	add di,[BmpTop] ; add the Y on entire screen
	
 
	; next 5 lines  di will be  = cx*320 + dx , point to the correct screen line
	dec di
	mov cx,di
	shl cx,6
	shl di,8
	add di,cx
	add di,dx
	 
	; small Read one line
	mov ah,3fh
	mov cx,[BmpColSize]  
	add cx,bp  ; extra  bytes to each row must be divided by 4
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,[BmpColSize]  
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	
	pop dx
	pop cx
	 
	loop @@NextLine
	
	pop cx
	ret
endp ShowBMP 

; Sync wait for mouse click
proc WaitTillGotClickOnSomePoint
	push si
	push ax
	push bx
	push cx
	push dx
	
	mov ax,1
	int 33h
	
	
ClickWaitWithDelay:
	mov cx,1000
ag:	
	loop ag
WaitTillPressOnPoint:

	mov ax,5h
	mov bx,0 ; quary the left b
	int 33h
	
	
	cmp bx,00h
	jna ClickWaitWithDelay  ; mouse wasn't pressed
	and ax,0001h
	jz ClickWaitWithDelay   ; left wasn't pressed

 	
	shr cx,1
	cmp cx,250
	ja ClickForExit
	mov si, cx 
	add si, [WidthClick]
	cmp si , [Xclick]
	jl WaitTillPressOnPoint
	mov si, cx 
	sub si, [WidthClick]
	cmp si , [Xclick]
	jg WaitTillPressOnPoint
	
	
	mov si, dx 
	add si, [HeightClick]
	cmp si , [Yclick]
	jl WaitTillPressOnPoint
	mov si, dx 
	sub si, [HeightClick]
	cmp si , [Yclick]
	jg WaitTillPressOnPoint
	mov [GotClick],1
	jmp @@EndProc
ClickForExit:	
	mov [GotClick],0
@@EndProc:
	mov ax,2
	int 33h
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop si
	ret
endp WaitTillGotClickOnSomePoint

; Async wait for mouse click
proc WaitTillGotClickOnSomePointAsync
	push si
	push ax
	push bx
	push cx
	push dx
	mov [GotClick], 0
	
	mov ax,1
	int 33h
	
ClickWaitWithDelayAsync:
	mov cx,1000
agAsync:	
	loop agAsync

mov [a], 1000
WaitTillPressOnPointAsync:

	mov ax,5h
	mov bx,0 ; quary the left b
	int 33h
	
	
	cmp bx,00h
	jna @@EndProc  ; mouse wasn't pressed
	and ax,0001h
	jz @@EndProc   ; left wasn't pressed

 	
	shr cx,1
	cmp cx,250
	ja ClickForExit
	
	mov si, [Xclick]
	add si, [WidthClick]
	cmp cx, si
	ja JumpMouseClickAsyncCheck
	cmp cx, [Xclick]
	jb JumpMouseClickAsyncCheck
	
	mov si, [Yclick]
	add si, [HeightClick]
	cmp dx, si
	ja JumpMouseClickAsyncCheck
	cmp dx, [Yclick]
	jb JumpMouseClickAsyncCheck
	
	mov [GotClick],1
	jmp WaitTillAReachesZeroToMouseLeftClickAsync

JumpMouseClickAsyncCheck:
	dec [a]
	cmp [a], 0
	jne WaitTillPressOnPointAsync
	je ClickForExitAsync
	
WaitTillAReachesZeroToMouseLeftClickAsync:
	dec [a]
	cmp [a], 0
	jne WaitTillAReachesZeroToMouseLeftClickAsync
	je @@EndProc
	
ClickForExitAsync:	
	mov [GotClick],0
@@EndProc:
	mov ax,2
	int 33h
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop si
	ret
endp WaitTillGotClickOnSomePointAsync

proc ReadMouse
	push ax
	push bx
	push cx
	push dx

	mov bx, 0
	mov ax,3h
	int 33h
	
	mov [MouseClickInfo], bx
	shr cx, 1
	mov [MouseXPos], cx
	mov [MouseYPos], dx

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp ReadMouse

proc IfMouseInPose
	push si
	
	cmp [MouseClickInfo], 1
	jne NotInPose

	mov si, [Xclick]
	add si, [WidthClick]
	cmp [MouseXPos], si 
	ja NotInPose
	mov si, [Xclick]
	cmp [MouseXPos], si
	jb NotInPose
	
	mov si, [Yclick]
	add si, [HeightClick]
	cmp [MouseYPos], si 
	ja NotInPose
	mov si, [Yclick]
	cmp [MouseYPos], si
	jb NotInPose
	
	mov [MouseInPos], 1
	jmp EndProc
	
NotInPose:
	mov [MouseInPos], 0
	
EndProc:
	pop si

	ret
endp IfMouseInPose
 
END start


