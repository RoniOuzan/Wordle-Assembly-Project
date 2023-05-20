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
    include 'util/mouse/MoseData.asm'
	 
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
	FileHelpText db HELP_TEXT, 0
	FileGameLayout db GAME_LAYOUT, 0

	FileStartButton db START_BUTTON, 0
	FileHelpButton db HELP_BUTTON, 0
	FileExitButton db EXIT_BUTTON, 0

	Letter db LETTER_IMAGE
	LetterToWrite db 'a', '_'
	LetterColor db 'g.bmp', 0

	LetterEmpty db LETTER_IMAGE, '___.bmp', 0

;----------------------------------------------------

	currentWord db 0
	CurrentLine db 0

	Line0 db 0, 0, 0, 0, 0
	Line1 db 0, 0, 0, 0, 0
	Line2 db 0, 0, 0, 0, 0
	Line3 db 0, 0, 0, 0, 0
	Line4 db 0, 0, 0, 0, 0

	LineColor db 'w', 'w', 'w', 'w', 'w'

	Answer db 'abcde'

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
	include "util/mouse/MoseCode.asm"
 
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
	call Reset

	call DisplayBackground
	call DisplayButtons

	call WaitForStart

	ret
endp Game

proc Reset
	mov [CurrentLine], 0
	mov [currentWord], 0
	call ResetLineColor
	ret
endp Reset

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

		jmp MenuLoop
	ret
endp WaitForStart

StartButtonClicked:
	call StartGame

HelpButtonClicked:
	call DisplayHelp

GoToMenuFromEsc:
	call Game

proc StartGame
	mov dx, offset FileGameLayout
	mov [BmpLeft],0
	mov [BmpTop],0
	mov [BmpColSize], 320
	mov [BmpRowSize], 200
	call OpenShowBmp

	GameLoop:
		mov ah, 0h ; Reads input from keyboard
		int 16h

		cmp ah, 1 ; if esc: go to menu
		je GoToMenuFromEsc

		cmp ah, 1Ch ; if enter: check if full and enter the line
		je CallEnterLine

		cmp ah, 0Eh ; if backspace: delete one letter
		je CallBackspace

		cmp [currentWord], 4 ; if the line is full: don't delete
		ja GameLoop

		call ConvertALToUpperCase ; converts to upper case

		cmp al, 'a' ; if key is not a letter: wait for the next type
		jb GameLoop
		cmp al, 'z'
		ja GameLoop

		call WriteLetter ; if the key is letter: write it on the screen
	
		jmp GameLoop

	ret
endp StartGame

proc ConvertALToUpperCase
	cmp al, 'A'
	jb ExitConvertALToUpperCase
	cmp al, 'Z'
	ja ExitConvertALToUpperCase

	add al, 32

ExitConvertALToUpperCase:
	ret
endp ConvertALToUpperCase

CallBackspace:
	cmp [currentWord], 0
	jbe GameLoop

	call Backspace
	jmp GameLoop

CallEnterLine:
	cmp [currentWord], 5
	jb GameLoop

	call EnterLine
	jmp GameLoop

proc EnterLine
	call CheckLineLetters
	call RewriteLine

	call CheckIfWon
	call CheckifLoss

	call ResetLineColor
	inc [CurrentLine]
	mov [currentWord], 0
	ret
endp EnterLine

proc CheckIfLoss
	cmp [CurrentLine], 4
	jae Loss

	ret
endp CheckIfLoss

Loss:
	call DisplayHelp

proc CheckIfWon
	mov bx, 0
	mov cx, 0
	CheckIfWonLoop:
		cmp [LineColor + bx], 'g'
		jne ContinueCheckIfWon

		inc cx

		ContinueCheckIfWon:
			inc bx
			cmp bx, 5
			jb CheckIfWonLoop
	
	cmp cx, 5
	je Win

	ret
endp CheckIfWon

Win:
	call Game

proc CheckLineLetters
	call GreenCheck
	call YellowCheck

	ret
endp CheckLineLetters

proc YellowCheck
	push ax
	push bx
	push cx
	push dx
	push si

	mov cx, 0
	YellowCheckLoop:
		mov bx, cx
		cmp [LineColor + bx], 'g'
		je YellowCheckNextLetter

		mov [currentWord], cl
		call GetCurrentLetter

		mov dx, 0
		YellowAnswerCheckLoop:
			mov si, dx
			mov al, [Answer + si]
			cmp [LineColor + si], 'g'
			je ContinueYellowAnswerCheck
			cmp [bx], al
			je PutYellow

			ContinueYellowAnswerCheck:
				inc dx
				cmp dx, 5
				jb YellowAnswerCheckLoop
				jae YellowCheckNextLetter
		
		PutYellow:
			mov bx, cx
			mov [LineColor + bx], 'y'

		YellowCheckNextLetter:
			inc cx
			cmp cx, 5
			jb YellowCheckLoop

	pop si
	pop dx
	pop cx
	pop bx
	pop ax	

	ret
endp YellowCheck

proc GreenCheck
	push ax
	push bx
	push cx
	push si

	mov cx, 0
	GreenCheckLoop:
		mov [currentWord], cl
		call GetCurrentLetter

		mov si, cx
		mov al, [Answer + si]
		cmp [bx], al
		jne LetterIsNotGreen

		mov bx, cx
		mov [LineColor + bx], 'g'

		LetterIsNotGreen:
			inc cx
			cmp cx, 5
			jb GreenCheckLoop
	
	pop si
	pop cx
	pop bx
	pop ax

	ret
endp GreenCheck

proc ResetLineColor
	push bx
	push cx

	mov cx, 5
	ResetLineColorLoop:
		mov bx, cx
		dec bx
		mov [lineColor + bx], 'w'
		loop ResetLineColorLoop
	
	pop cx
	pop bx

	ret
endp ResetLineColor

proc RewriteLine
	push ax
	push bx
	push cx
	push dx

	mov bx, 0
	mov [currentWord], 0
	RewriteLineLoop:
		mov dl, [LineColor + bx]
		mov dh, 0
		mov cx, bx
		call GetCurrentLetter
		mov al, [bx]
		mov bx, cx
		call WriteLetterOnScreen

		inc bx
		inc [CurrentWord]
		cmp bx, 5
		jb RewriteLineLoop
	
	pop dx
	pop cx
	pop bx
	pop ax

	ret
endp RewriteLine

proc Backspace
	push bx

	dec [currentWord]
	mov bl, [currentWord]
	mov bh, 0
	mov [byte line0 + bx], 0

	mov dx, offset LetterEmpty
	call DisplayDXOnNode

	pop bx

	ret
endp Backspace


proc WriteLetter
	call WriteLetterOnScreen
	call WriteLetterInCode
	call NextLetter

	ret
endp WriteLetter


proc WriteLetterOnScreen
	push bx
	push cx
	push dx

	mov [LetterToWrite], al
	mov bl, [currentWord]
	mov bh, 0
	mov cl, [LineColor + bx]
	mov [LetterColor], cl

	mov dx, offset Letter
	call DisplayDXOnNode

	pop dx
	pop cx
	pop bx

	ret
endp WriteLetterOnScreen

proc DisplayDXOnNode
	push ax
	push bx
	push dx

	mov al, [currentWord]
	mov bl, 36
	mul bl
	add ax, 16
	mov [BmpLeft], ax

	mov al, [CurrentLine]
	mov bl, 38
	mul bl
	add ax, 8

	mov [BmpTop], ax
	mov [BmpColSize], 32
	mov [BmpRowSize], 32
	call OpenShowBmp

	pop dx
	pop bx
	pop ax

	ret
endp DisplayDXOnNode

proc WriteLetterInCode
	push bx
	push cx

	call GetCurrentLetter
	mov [bx], al

	pop cx
	pop bx

	ret
endp WriteLetterInCode

proc GetCurrentLetter
	push ax

	mov bl, [currentWord]
	mov bh, 0
	mov al, [CurrentLine]
	mov ah, 5
	mul ah
	add bx, ax
	add bx, offset line0

	pop ax

	ret
endp GetCurrentLetter

proc NextLetter
	inc [currentWord]
	ret
endp NextLetter



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
	je GoToMenuFromHelp

	ret
endp DisplayHelp

GoToMenuFromHelp:
	call Game

 
END start


