macro mouseClick l, x, y, w, h
	mov [xClick], x
	mov [yClick], y
	mov [widthClick], w
	mov [heightClick], h
	call ifMouseInPose
	cmp [mouseInPos], 1
	je l
endm

; Sync wait for mouse click
proc waitTillgotClickOnSomePoint
	mov [gotClick], 0

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
	sub si, [widthClick]
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
	add si, [widthClick]
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

proc readMouse
	push ax
	push bx
	push cx
	push dx
	
	mov [mouseInPos], 0
	
	mov ax,1
	int 33h

	mov bx, 0
	mov ax,3h
	int 33h
	
	mov [mouseClickInfo], bx
	shr cx, 1
	mov [mouseXPos], cx
	mov [mouseYPos], dx

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp readMouse

proc ifMouseInPose
	push ax
	
	mov [mouseInPos], 0
	
	cmp [mouseClickInfo], 1
	jne notInPose

	mov ax, [xClick]
	add ax, [widthClick]
	cmp [mouseXPos], ax 
	ja notInPose
	mov si, [xClick]
	cmp [mouseXPos], si
	jb notInPose
	
	mov si, [yClick]
	add si, [heightClick]
	cmp [mouseYPos], si 
	ja notInPose
	mov si, [yClick]
	cmp [mouseYPos], si
	jb notInPose
	
	mov [mouseInPos], 1
	
	mov ax,0
	int 33h
	
	jmp endProc
	
notInPose:
	mov [mouseInPos], 0
	
endProc:
	pop ax

	ret
endp IfMouseInPose

;================================================
; Description - Write on screen the value of ax (decimal)
;               the practice :  
;				Divide AX by 10 and put the Mod on stack 
;               Repeat Until AX smaller than 10 then print AX (MSB) 
;           	then pop from the stack all what we kept there and show it. 
; INPUT: AX
; OUTPUT: Screen 
; Register Usage: AX  
;================================================
proc ShowAxDecimal
       push ax
	   push bx
	   push cx
	   push dx
	   
	   ; check if negative
	   test ax,08000h
	   jz PositiveAx
			
	   ;  put '-' on the screen
	   push ax
	   mov dl,'-'
	   mov ah,2
	   int 21h
	   pop ax

	   neg ax ; make it positive
PositiveAx:
       mov cx,0   ; will count how many time we did push 
       mov bx,10  ; the divider
   
put_mode_to_stack:
       xor dx,dx
       div bx
       add dl,30h
	   ; dl is the current LSB digit 
	   ; we cant push only dl so we push all dx
       push dx    
       inc cx
       cmp ax,9   ; check if it is the last time to div
       jg put_mode_to_stack

	   cmp ax,0
	   jz pop_next  ; jump if ax was totally 0
       add al,30h  
	   mov dl, al    
  	   mov ah, 2h
	   int 21h        ; show first digit MSB
	       
pop_next: 
       pop ax    ; remove all rest LIFO (reverse) (MSB to LSB)
	   mov dl, al
       mov ah, 2h
	   int 21h        ; show all rest digits
       loop pop_next
		
	   mov dl, ','
       mov ah, 2h
	   int 21h
   
	   pop dx
	   pop cx
	   pop bx
	   pop ax
	   
	   ret
endp ShowAxDecimal 