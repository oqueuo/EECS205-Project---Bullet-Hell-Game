; #########################################################################
;
;   stars.asm - Assembly file for CompEng205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here

.CODE

DrawStarField proc

	;; Place your code here
    invoke DrawStar, 248, 224 ;; draws a single star at location (248, 224)
    invoke DrawStar, 110, 345 ;; draws a single star at location (x, y) 
    invoke DrawStar, 263, 394 ;; draws a single star at location (x, y) 
    invoke DrawStar, 341, 227 ;; draws a single star at location (x, y) 
    invoke DrawStar, 628, 123 ;; draws a single star at location (x, y) 
    invoke DrawStar, 616, 348 ;; draws a single star at location (x, y) 
    invoke DrawStar, 571, 86  ;; draws a single star at location (x, y) 
    invoke DrawStar, 382, 223 ;; draws a single star at location (x, y) 
    invoke DrawStar, 142, 225 ;; draws a single star at location (x, y) 
    invoke DrawStar, 493, 407 ;; draws a single star at location (x, y) 
    invoke DrawStar, 247, 394 ;; draws a single star at location (x, y) 
    invoke DrawStar, 594, 44  ;; draws a single star at location (x, y) 
    invoke DrawStar, 308, 179 ;; draws a single star at location (x, y) 
    invoke DrawStar, 490, 129 ;; draws a single star at location (x, y) 
    invoke DrawStar, 516, 230 ;; draws a single star at location (x, y) 
    invoke DrawStar, 84, 206  ;; draws a single star at location (x, y) 
    invoke DrawStar, 360, 233 ;; draws a single star at location (x, y) 
    invoke DrawStar, 473, 124 ;; draws a single star at location (x, y) 
    invoke DrawStar, 103, 195 ;; draws a single star at location (x, y) 
    invoke DrawStar, 287, 399 ;; draws a single star at location (x, y) 
    invoke DrawStar, 300, 100 ;; draws a single star at location (x, y) 

	ret  			; Careful! Don't remove this line
DrawStarField endp



END
