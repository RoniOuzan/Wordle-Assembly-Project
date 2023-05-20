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

;--------------------------------Async-------------------------------------------

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