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
    include 'util/mouse/MouseData.asm'
	 
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

	LetterEmpty db LETTER_IMAGE, '__.bmp', 0

;----------------------------------------------------

	currentWord db 0
	CurrentLine db 0

	Line0 db 0, 0, 0, 0, 0
	Line1 db 0, 0, 0, 0, 0
	Line2 db 0, 0, 0, 0, 0
	Line3 db 0, 0, 0, 0, 0
	Line4 db 0, 0, 0, 0, 0

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
	include "util/mouse/MouseCode.asm"
 
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
		je GoToMenu

		cmp ah, 0Eh
		je CallBackspace

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
	call Backspace
	jmp GameLoop


proc Backspace
	mov [line0 + currentWord], 0

	mov dx, [LetterEmpty]
	call DisplayDXOnNode

	ret
endp Backspace


proc WriteLetter
	call WriteLetterOnScreen
	call WriteLetterInCode
	call NextLetter

	ret
endp WriteLetter


proc WriteLetterOnScreen
	push dx

	mov [LetterToWrite], al
	mov [LetterColor], 'g'
	mov dx, offset Letter

	call DisplayDXOnNode

	pop dx

	ret
endp WriteLetter

proc DisplayDXOnNode
	push ax
	push bx

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

	ret
endp DisplayDXOnNode

proc WriteLetterInCode
	push ax
	push bx
	push dx

	mov dl, al

	mov bl, al
	sub bl, 'a'

	mov [line0 + bl], dl

	pop dx
	pop bx
	pop ax

	ret
endp WriteLetterInCode

proc NextLetter
	inc [currentWord]
	ret
endp NextLetter

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
 
END start


