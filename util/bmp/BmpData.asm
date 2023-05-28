scrLine 	db 320 dup (0)  ; One Color line read buffer
 
fileHandle	dw ?
header 	    db 54 dup(0)
palette 	db 400h dup (0)

smallPicName db 'Pic48X78.bmp',0


bmpFileErrorMsg    	db 'Error At Opening Bmp File', 0dh, 0ah,'$'
errorFile           db 0
BB db "BB..",'$'
; array for mouse int 33 ax=09 (not a must) 64 bytes

squareSize dw ?