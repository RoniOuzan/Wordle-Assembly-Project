macro mouseClick l, x, y, w, h
	mov [xClick], x
	mov [yClick], y
	mov [widthClick], w
	mov [heightClick], h
	call ifMouseInPose
	cmp [mouseInPos], 1
	je l
endm

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