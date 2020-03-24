; #########################################################################
;
;   lines.asm - Assembly file for CompEng205 Assignment 2
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA

	;; If you need to, you can place global variables here
	
.CODE
	

;; Don't forget to add the USES the directive here
;;   Place any registers that you modify (either explicitly or implicitly)
;;   into the USES list so that caller's values can be preserved
	
;;   For example, if your procedure uses only the eax and ebx registers
;;      DrawLine PROC USES eax ebx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
DrawLine proc USES eax ebx ecx edx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
	;; Feel free to use local variables...declare them here
	;; For example:
	;; 	LOCAL foo:DWORD, bar:DWORD
	LOCAL delta_x:DWORD, delta_y:DWORD, inc_x:DWORD, inc_y:DWORD, error:DWORD, curr_x:DWORD, curr_y:DWORD, prev_error:DWORD
	;; Place your code here
	;; delta_x = abs(x1-x0)
	mov eax, x1
	mov ebx, x0    ;; Put x0 and x1 into GPRs
	sub eax, ebx
	cmp eax, 0
	jge ComputeDelta_x  ;; Only want to negate if the value is negative
	neg eax
ComputeDelta_x:
	mov delta_x, eax

	;; delta_y = abs(y1-y0)
	mov eax, y0
	mov ebx, y1
	sub eax, ebx
	cmp eax, 0
	jge ComputeDelta_y
	neg eax
ComputeDelta_y:
	mov delta_y, eax

	;; if (x0 < x1)
	;; 		inc_x = 1
	;; else
	;; 		inc_x = -1
	mov eax, x0
	mov ebx, x1   ;;Put x0 and x1 into GPRs
	cmp eax, ebx
	jge else1   ;; skip the true block if "if" cond. is false
	mov inc_x, 1
	jmp continue1   ;; Unconditional branch to not go to false black if "if" cond. is true
else1:
	mov inc_x, -1
continue1:

	;; if (y0 < y1)
	;; 		inc_y = 1
	;; else
	;; 		inc_y = -1
	mov eax, y0
	mov ebx, y1
	cmp eax, ebx
	jge else2   ;; skip the true block if "if" cond. is false
	mov inc_y, 1
	jmp continue2   ;; Unconditional branch to not go to false block if "if" cond. is true
else2:
	mov inc_y, -1
continue2:

	;; if (delta_x > delta_y)
	;; 		error = delta_x / 2
	;; else 
	;; 		error = -delta_y / 2
	mov eax, delta_x
	mov ebx, delta_y
	cmp eax, ebx
	jle else3   ;; skip the true block if "if" cond. is false
	mov ebx, delta_x
	shr ebx, 2   ;; shr because delta_x is unsigned
	mov error, ebx
	jmp continue3   ;; Unconditional branch to not go to false block if "if" cond. is true
else3:
	mov ebx, delta_y
	neg ebx
	sar ebx, 2   ;; sar because delta_y is negative (signed)
	mov error, ebx
continue3:

	;; curr_x = x0
	;; curr_y = y0
	mov eax, x0
	mov ebx, y0
	mov curr_x, eax
	mov curr_y, ebx

	;; DrawPixel(curr_x, curr_y, color)
	invoke DrawPixel, curr_x, curr_y, color

	;; while (curr_x != x1 OR curr_y != y1)
	;; 		DrawPixel(curr_x, curr_y, color)

	;; 		prev_error = error

	;; 		if (prev_error > -delta_x)
	;; 			error = error - delta_y
	;; 			curr_x = curr_x + inc_x

	;; 		if (prev_error < delta_y)
	;; 			error = error + delta_x
	;; 			curr_y = curr_y + inc_y

	jmp eval4   ;; Eval cond. before using while loop
do4:
	invoke DrawPixel, curr_x, curr_y, color
	mov eax, error
	mov prev_error, eax
firstIf4:
	mov eax, delta_x
	neg eax
	cmp prev_error, eax
	jle secondIf4   ;; Compute "if" cond. If false, skip to next if statement
	mov eax, error
	mov ebx, delta_y
	sub eax, ebx
	mov error, eax
	mov eax, curr_x
	mov ebx, inc_x
	add eax, ebx
	mov curr_x, eax
secondIf4:
	mov eax, delta_y
	cmp prev_error, eax
	jge eval4   ;; Compute "if" cond. If false, go back to eval cond. for the while loop
	mov eax, error
	mov ebx, delta_x
	add eax, ebx
	mov error, eax
	mov eax, curr_y
	mov ebx, inc_y
	add eax, ebx
	mov curr_y, eax
eval4:
	mov eax, curr_x
	mov ebx, x1
	cmp eax, ebx
	jne do4   ;; OR condition. If either cond. is true, go to while loop body.
	mov eax, curr_y
	mov ebx, y1
	cmp eax, ebx
	jne do4   ;; OR condition. If either cond. is true, go to while loop body
continue4:

	ret        	;;  Don't delete this line...you need it
DrawLine endp


END