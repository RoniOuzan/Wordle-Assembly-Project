ScrLine 	db BMP_WIDTH dup (0)  ; One Color line read buffer
 
FileHandle	dw ?
Header 	    db 54 dup(0)
Palette 	db 400h dup (0)

SmallPicName db 'Pic48X78.bmp',0


BmpFileErrorMsg    	db 'Error At Opening Bmp File', 0dh, 0ah,'$'
ErrorFile           db 0
BB db "BB..",'$'
; array for mouse int 33 ax=09 (not a must) 64 bytes