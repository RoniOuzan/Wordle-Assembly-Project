IDEAL
MODEL small

STACK 0f500h

MENU_BACKGROUND  equ 'images/menus/Menu.bmp'
HELP_TEXT equ 'images/menus/HelpText.bmp'
GAME_LAYOUT equ 'images/menus/Game.bmp'

START_BUTTON equ 'images/buttons/Start.bmp'
HELP_BUTTON equ 'images/buttons/Help.bmp'
EXIT_BUTTON equ 'images/buttons/Exit.bmp'

LETTER_IMAGE equ 'images/letters/'
 
BMP_WIDTH = 320
 

DATASEG

    include 'util/bmp/BmpData.asm'
	 
	color db ?
	xClick dw ?
	yClick dw ?
	xp dw ?
	yp dw ?
	squareSize dw ?
	 
	bmpLeft dw ?
	bmpTop dw ?
	bmpColSize dw ?
	bmpRowSize dw ?
	
	widthClick dw ?
	heightClick dw ?
	gotClick db ?

;----------------------------------------------------

	fileMenu db MENU_BACKGROUND, 0
	fileHelpText db HELP_TEXT, 0
	fileGameLayout db game_LAYOUT, 0

	fileStartButton db START_BUTTON, 0
	fileHelpButton db HELP_BUTTON, 0
	fileExitButton db EXIT_BUTTON, 0

	letter db LETTER_IMAGE
	letterToWrite db 'a', '_'
	letterColor db 'g.bmp', 0

	letterEmpty db LETTER_IMAGE, '___.bmp', 0

;----------------------------------------------------

	currentWord db 0
	currentLine db 0

	line0 db 0, 0, 0, 0, 0
	line1 db 0, 0, 0, 0, 0
	line2 db 0, 0, 0, 0, 0
	line3 db 0, 0, 0, 0, 0
	line4 db 0, 0, 0, 0, 0

	lineColor db 'w', 'w', 'w', 'w', 'w'

	answer db 'abcde'

;----------------------------------------------------

	a dw ?
	b dw ?
	c dw ?
	d dw ?
	e dw ?
	f dw ?
	g dw ?
	
	 
CODESEG
 
	include "util/bmp/BmpCode.asm"
	include "util/mouse/MoseCode.asm" ; It's mose and not mouse because 8 let limit and not because I am stupid
 
start:
	mov ax, @data
	mov ds, ax
	
	call setGraphic
 
	call game
	
		
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

proc game
	call reset

	call displayBackground
	call displayButtons

	call waitForStart

	ret
endp game

proc reset
	mov [currentLine], 0
	mov [currentWord], 0
	call resetlineColor
	ret
endp reset

proc displayBackground
	mov dx, offset fileMenu
	mov [bmpLeft],0
	mov [bmpTop],0
	mov [bmpColSize], 320
	mov [bmpRowSize], 200
	call openShowBmp
	
	ret
endp displayBackground

proc displayButtons
	mov dx, offset fileStartButton
	mov [bmpLeft],96
	mov [bmpTop],80
	mov [bmpColSize], 128
	mov [bmpRowSize], 32
	call openShowBmp

	mov dx, offset fileHelpButton
	mov [bmpLeft],96
	mov [bmpTop],120
	mov [bmpColSize], 128
	mov [bmpRowSize], 32
	call openShowBmp

	mov dx, offset fileExitButton
	mov [bmpLeft],96
	mov [bmpTop],160
	mov [bmpColSize], 128
	mov [bmpRowSize], 32
	call openShowBmp

	ret
endp displayButtons

proc waitForStart
	menuLoop:
		; Start
		mov [xClick], 96
		mov [yClick], 80
		mov [widthClick], 128
		mov [heightClick], 32
		call waitTillGotClickOnSomePointAsync
		
		cmp [GotClick], 1
		je startButtonClicked
		
		; Help
		mov [xClick], 96
		mov [yClick], 120
		mov [widthClick], 128
		mov [heightClick], 32
		call waitTillGotClickOnSomePointAsync
		
		cmp [gotClick], 1
		je helpButtonClicked

		jmp menuLoop
	ret
endp waitForStart

startButtonClicked:
	call startGame

helpButtonClicked:
	call DisplayHelp

goToMenuFromEsc:
	call game

proc startGame
	mov dx, offset fileGameLayout
	mov [bmpLeft],0
	mov [bmpTop],0
	mov [bmpColSize], 320
	mov [bmpRowSize], 200
	call openShowBmp

	gameLoop:
		mov ah, 0h ; Reads input from keyboard
		int 16h

		cmp ah, 1 ; if esc: go to menu
		je goToMenuFromEsc

		cmp ah, 1Ch ; if enter: check if full and enter the line
		je callEnterLine

		cmp ah, 0Eh ; if backspace: delete one letter
		je callBackspace

		cmp [currentWord], 4 ; if the line is full: don't delete
		ja gameLoop

		call convertALToUpperCase ; converts to upper case

		cmp al, 'a' ; if key is not a letter: wait for the next type
		jb gameLoop
		cmp al, 'z'
		ja gameLoop

		call writeLetter ; if the key is letter: write it on the screen
	
		jmp gameLoop

	ret
endp startGame

proc convertALToUpperCase
	cmp al, 'A'
	jb exitConvertALToUpperCase
	cmp al, 'Z'
	ja exitConvertALToUpperCase

	add al, 32

exitConvertALToUpperCase:
	ret
endp convertALToUpperCase

callBackspace:
	cmp [currentWord], 0
	jbe gameLoop

	call backspace
	jmp gameLoop

callEnterLine:
	cmp [currentWord], 5
	jb gameLoop

	call enterLine
	jmp gameLoop

proc enterLine
	call checkLineLetters
	call rewriteLine

	call checkIfWon
	call checkifLoss

	call resetlineColor
	inc [currentLine]
	mov [currentWord], 0
	ret
endp enterLine

proc checkIfLoss
	cmp [currentLine], 4
	jae loss

	ret
endp checkIfLoss

loss:
	call displayHelp

proc checkIfWon
	mov bx, 0
	mov cx, 0
	checkIfWonLoop:
		cmp [lineColor + bx], 'g'
		jne continueCheckIfWon

		inc cx

		continueCheckIfWon:
			inc bx
			cmp bx, 5
			jb checkIfWonLoop
	
	cmp cx, 5
	je win

	ret
endp checkIfWon

win:
	call game

proc checkLineLetters
	call greenCheck
	call yellowCheck

	ret
endp checkLineLetters

proc yellowCheck
	push ax
	push bx
	push cx
	push dx
	push si

	mov cx, 0
	yellowCheckLoop:
		mov bx, cx
		cmp [lineColor + bx], 'g'
		je yellowCheckNextLetter

		mov [currentWord], cl
		call getCurrentLetter

		mov dx, 0
		yellowAnswerCheckLoop:
			mov si, dx
			mov al, [answer + si]
			cmp [lineColor + si], 'g'
			je continueYellowAnswerCheck
			cmp [bx], al
			je putYellow

			continueYellowAnswerCheck:
				inc dx
				cmp dx, 5
				jb yellowAnswerCheckLoop
				jae yellowCheckNextLetter
		
		putYellow:
			mov bx, cx
			mov [lineColor + bx], 'y'

		yellowCheckNextLetter:
			inc cx
			cmp cx, 5
			jb yellowCheckLoop

	pop si
	pop dx
	pop cx
	pop bx
	pop ax	

	ret
endp yellowCheck

proc greenCheck
	push ax
	push bx
	push cx
	push si

	mov cx, 0
	greenCheckLoop:
		mov [currentWord], cl
		call getCurrentLetter

		mov si, cx
		mov al, [answer + si]
		cmp [bx], al
		jne letterIsNotGreen

		mov bx, cx
		mov [lineColor + bx], 'g'

		letterIsNotGreen:
			inc cx
			cmp cx, 5
			jb greenCheckLoop
	
	pop si
	pop cx
	pop bx
	pop ax

	ret
endp greenCheck

proc resetlineColor
	push bx
	push cx

	mov cx, 5
	resetlineColorLoop:
		mov bx, cx
		dec bx
		mov [lineColor + bx], 'w'
		loop resetlineColorLoop
	
	pop cx
	pop bx

	ret
endp resetlineColor

proc rewriteLine
	push ax
	push bx
	push cx
	push dx

	mov bx, 0
	mov [currentWord], 0
	rewriteLineLoop:
		mov dl, [lineColor + bx]
		mov dh, 0
		mov cx, bx
		call getCurrentLetter
		mov al, [bx]
		mov bx, cx
		call writeLetterOnScreen

		inc bx
		inc [currentWord]
		cmp bx, 5
		jb rewriteLineLoop
	
	pop dx
	pop cx
	pop bx
	pop ax

	ret
endp rewriteLine

proc backspace
	push bx

	dec [currentWord]
	mov bl, [currentWord]
	mov bh, 0
	mov [byte line0 + bx], 0

	mov dx, offset letterEmpty
	call displayDXOnNode

	pop bx

	ret
endp backspace


proc writeLetter
	call writeLetterOnScreen
	call writeLetterInCode
	call nextLetter

	ret
endp writeLetter


proc writeLetterOnScreen
	push bx
	push cx
	push dx

	mov [letterToWrite], al
	mov bl, [currentWord]
	mov bh, 0
	mov cl, [lineColor + bx]
	mov [letterColor], cl

	mov dx, offset Letter
	call displayDXOnNode

	pop dx
	pop cx
	pop bx

	ret
endp writeLetterOnScreen

proc displayDXOnNode
	push ax
	push bx
	push dx

	mov al, [currentWord]
	mov bl, 36
	mul bl
	add ax, 16
	mov [bmpLeft], ax

	mov al, [currentLine]
	mov bl, 38
	mul bl
	add ax, 8

	mov [bmpTop], ax
	mov [bmpColSize], 32
	mov [bmpRowSize], 32
	call openShowBmp

	pop dx
	pop bx
	pop ax

	ret
endp displayDXOnNode

proc writeLetterInCode
	push bx
	push cx

	call getCurrentLetter
	mov [bx], al

	pop cx
	pop bx

	ret
endp writeLetterInCode

proc getCurrentLetter
	push ax

	mov bl, [currentWord]
	mov bh, 0
	mov al, [currentLine]
	mov ah, 5
	mul ah
	add bx, ax
	add bx, offset line0

	pop ax

	ret
endp getCurrentLetter

proc nextLetter
	inc [currentWord]
	ret
endp nextLetter

proc displayHelp
	mov dx, offset fileHelpText
	mov [bmpLeft],0
	mov [bmpTop],0
	mov [bmpColSize], 320	
	mov [bmpRowSize], 200
	call openShowBmp

	mov dx, offset fileExitButton
	mov [bmpLeft],96
	mov [bmpTop],164
	mov [bmpColSize], 128
	mov [bmpRowSize], 32
	call openShowBmp

	mov [xClick], 96
	mov [yClick], 164
	mov [widthClick], 128
	mov [heightClick], 32
	call waitTillGotClickOnSomePoint
	cmp [gotClick], 1
	je goToMenuFromHelp

	ret
endp displayHelp

goToMenuFromHelp:
	call game

 
END start


