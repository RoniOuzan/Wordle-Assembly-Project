; Sync wait for mouse click
proc waitTillgotClickOnSomePoint
	push si
	push ax
	push bx
	push cx
	push dx
	
	mov ax,1
	int 33h
	
	
clickWaitWithDelay:
	mov cx,1000
ag:	
	loop ag
waitTillPressOnPoint:

	mov ax,5h
	mov bx,0 ; quary the left b
	int 33h
	
	
	cmp bx,00h
	jna clickWaitWithDelay  ; mouse wasn't pressed
	and ax,0001h
	jz clickWaitWithDelay   ; left wasn't pressed

 	
	shr cx,1
	cmp cx,250
	ja clickForExit
	mov si, cx 
	add si, [widthClick]
	cmp si , [xClick]
	jl waitTillPressOnPoint
	mov si, cx 
	sub si, [WidthClick]
	cmp si , [xClick]
	jg waitTillPressOnPoint
	
	
	mov si, dx 
	add si, [heightClick]
	cmp si , [yClick]
	jl waitTillPressOnPoint
	mov si, dx 
	sub si, [heightClick]
	cmp si , [yClick]
	jg waitTillPressOnPoint
	mov [gotClick],1
	jmp @@endProc
clickForExit:	
	mov [gotClick],0
@@endProc:
	mov ax,2
	int 33h
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop si
	ret
endp waitTillgotClickOnSomePoint

;--------------------------------Async-------------------------------------------

; Async wait for mouse click
proc waitTillgotClickOnSomePointAsync
	push si
	push ax
	push bx
	push cx
	push dx
	mov [gotClick], 0
	
	mov ax,1
	int 33h
	
clickWaitWithDelayAsync:
	mov cx,1000
agAsync:	
	loop agAsync

mov [variable], 1000
waitTillPressOnPointAsync:

	mov ax,5h
	mov bx,0 ; quary the left b
	int 33h
	
	
	cmp bx,00h
	jna @@endProc  ; mouse wasn't pressed
	and ax,0001h
	jz @@endProc   ; left wasn't pressed

 	
	shr cx,1
	cmp cx,250
	ja clickForExit
	
	mov si, [xClick]
	add si, [WidthClick]
	cmp cx, si
	ja jumpMouseClickAsyncCheck
	cmp cx, [xClick]
	jb jumpMouseClickAsyncCheck
	
	mov si, [yClick]
	add si, [heightClick]
	cmp dx, si
	ja jumpMouseClickAsyncCheck
	cmp dx, [yClick]
	jb jumpMouseClickAsyncCheck
	
	mov [gotClick],1
	jmp waitTillAReachesZeroToMouseLeftClickAsync

jumpMouseClickAsyncCheck:
	dec [variable]
	cmp [variable], 0
	jne waitTillPressOnPointAsync
	je clickForExitAsync
	
waitTillAReachesZeroToMouseLeftClickAsync:
	dec [variable]
	cmp [variable], 0
	jne waitTillAReachesZeroToMouseLeftClickAsync
	je @@endProc
	
clickForExitAsync:	
	mov [gotClick],0
@@endProc:
	mov ax,2
	int 33h
	
	pop dx
	pop cx
	pop bx
	pop ax
	pop si
	ret
endp waitTillgotClickOnSomePointAsync