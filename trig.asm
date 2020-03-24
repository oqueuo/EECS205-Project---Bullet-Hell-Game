; #########################################################################
;
;   trig.asm - Assembly file for CompEng205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  

	;; If you need to, you can place global variables here
	
.CODE

GETSIN PROC USES ebx ecx edx angle:FXPT
	mov eax, angle              	;eax = angle	
	mov ebx, PI_INC_RECIP			;ebx = PI_INC_RECIP
	imul ebx                    	;edx should contain integer index. Truncate it.
	shr eax, 16
	shl edx, 16
	add eax, edx
	shr eax, 16                 	;eax now contains the index for SINTAB
	xor ebx, ebx
	mov bx, [SINTAB + 2 * eax]  	; look up the alue in SINTAB. 2*eax because 16 bits
	mov eax, 0                  	; re-use ebx
	mov eax, ebx
  ret
GETSIN ENDP


FixedSin PROC angle:FXPT

xor eax, eax
mov esi, angle             		;esi = angle	

MAKEPOSITIVE:
  cmp esi, 0                  	;Make sure angle is not negative
  jg POSITIVE
  add esi, TWO_PI               ;Add 2pi to try to make it positive
  jmp MAKEPOSITIVE    
POSITIVE:
  cmp esi, PI_HALF             	;See if its in the first quadrant. If not, go to next cond.
  jg GREATERTHANQUAD1      

  invoke GETSIN, esi			;If in first quad, compute sin directly from SINTAB
  jmp GETOUT                 
GREATERTHANQUAD1:
  cmp esi, PI
  jg GREATERTHANQUAD2         	;Check if in 2nd quad. If not, go to next cond.
  mov eax, PI
  sub eax, esi
  mov esi, eax					;sin(x) = sin(PI-x)
  invoke GETSIN, esi			;If in 2nd quad, compute sin
  jmp GETOUT               
GREATERTHANQUAD2:
  cmp esi, PI + PI_HALF     	;Check if in 3rd quad. If not, go to next cond.
  jg GREATERTHANQUAD3
  
  sub esi, PI               	;Just subtract pi to get the index of SINTAB. Negate that value to get proper sin
  invoke GETSIN, esi
  neg eax                   	; Negate as mentioned above.

  jmp GETOUT 
GREATERTHANQUAD3:
  cmp esi, TWO_PI           	;Check if in 4th quad. If not, angle is above 2pi and must be smalleredererered
  jg TOOFAT             

  sub esi, PI					;Subtract PI
  mov eax, PI					;Do the same thing as second quadrant. Just make sure to negate afterwards.
  sub eax, esi
  mov esi, eax

  invoke GETSIN, esi      
  neg eax						;Negate here for the reason listed above.

  jmp GETOUT
TOOFAT:
  sub esi, TWO_PI           	;Make angle skinnier and go through the loop one more time.
  jmp MAKEPOSITIVE
GETOUT:
	ret			; Don't delete this line!!!

FixedSin ENDP

	
FixedCos PROC angle:FXPT

	mov eax, angle
	add eax, PI_HALF			;cos(x) + sin(x+pi/2)
	invoke FixedSin, eax        

	ret			; Don't delete this line!!!	
FixedCos ENDP	
END