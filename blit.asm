; #########################################################################
;
;   blit.asm - Assembly file for CompEng205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc


.DATA
	;; If you need to, you can place global variables here
.CODE


DrawPixel PROC USES eax ebx edx edi x:DWORD, y:DWORD, color:DWORD
    
    mov edi, ScreenBitsPtr      ;edi = screenbitsPtr
    mov edx, color

    mov eax, 640            
    mov ebx, y
    imul ebx, eax       

    add ebx, x                  ;ebx = y*640 + x

    ;;; Add the "if" condition
    cmp x, 0
    jl FAILED
    cmp x, 640
    jge FAILED                  ;Don't draw pixel if x < 0 or x >= 640

    cmp y, 0
    jl FAILED
    cmp y, 480
    jge FAILED                  ;Don't draw pixel if y < 0 or y >= 480

    xor eax, eax
    mov al, (EECS205BITMAP PTR [esi]).bTransparent      ;Get bTransparent to compare to "color"
    cmp al, dl                                          ;dl contains the color at the current pixel. Only draw if not equal
    je FAILED

    ;;; If the "if" condition passes ->
    mov BYTE PTR [edi + ebx], dl
    FAILED: ;Jump here if the "if" condition fails

  ret       ; Don't delete this line!!!
DrawPixel ENDP


BasicBlit PROC USES eax ebx ecx edx edi ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD
    LOCAL dwWidth:DWORD, dwHeight:DWORD, bTransparent:BYTE, minx:DWORD, miny:DWORD, x:DWORD, y:DWORD, lpBytes:DWORD
    mov esi, ptrBitmap
    ;;; Get the elements of the EECS205BITMAP structure
    mov eax, (EECS205BITMAP PTR[esi]).dwWidth
    mov dwWidth, eax                                        ;Set dwWidth
    mov eax, (EECS205BITMAP PTR[esi]).dwHeight
    mov dwHeight, eax                                       ;Set dwHeight
    mov ebx, (EECS205BITMAP PTR [esi]).lpBytes
    mov lpBytes, ebx                                        ;Set lpBytes

    ; Set variables that have the minimum x and y values
    ; x
    mov eax, dwWidth
    sar eax, 1  ;Divide by 2 (shift right 1)
    mov ebx, xcenter
    sub ebx, eax
    mov minx, ebx                       ;minx = xcenter - dwWidth/2
    ; y
    mov eax, dwHeight     
    sar eax, 1  ; Divide dwHeight by 2 (shift 2 to right)
    mov ebx, ycenter
    sub ebx, eax
    mov miny, ebx                       ;miny = ycenter - dwHeight/2


    ; for (x = minx, x < dwWidth, x++)
    ;   for (y = miny, y < dwHeight, y++)
    ;       DrawPixel(x,y,pTransparent)
    ; x will be in eax and y will be in ebx
    mov edi, 0  ; x
    jmp check_x
outer_for:
    mov ebx, 0
    jmp check_y
    inner_for:
        mov ecx, dwWidth
        imul ecx, ebx
        add ecx, edi                ;ecx = 640*y + x

        ; xor edx, edx
        ; mov dl, BYTE PTR [lpBytes + ecx]    ;Get the color-value of the current pixel
        mov eax, (EECS205BITMAP PTR [esi]).lpBytes
        xor edx, edx
        mov dl, BYTE PTR [eax + ecx]                ;dl contains the current color at the current pixel

        add edi, minx
        add ebx, miny

        invoke DrawPixel, edi, ebx, dl

        sub edi, minx
        sub ebx, miny
        inc ebx
check_y:
    cmp ebx, dwHeight
    jl inner_for

    inc edi     ;Reached end of y values. Inc x and go back to outer_for
check_x:
    cmp edi, dwWidth
    jl outer_for

	ret 			; Don't delete this line!!!	
BasicBlit ENDP

fxptintconv PROC USES ecx edx FXPTNum:FXPT, intNum:DWORD
  
    mov edx, 0
    mov ecx, FXPTNum
    mov eax, intNum
    sal eax, 16
    imul ecx
    mov eax, edx

    ; mov edx, x          ; edx holds int
    ; sal edx, 16         ; convert int into ficed 16|16
    ; mov eax, y          ; eax holds fixed
    ; imul edx            ; edx * eax  has int * fixed = 32+32 fixed
    ; mov eax, edx        ; return int part of result

    ret
fxptintconv ENDP


RotateBlit PROC USES eax ebx ecx edx esi edi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
LOCAL dwWidth:DWORD, dwHeight:DWORD
LOCAL shiftX:DWORD, shiftY:DWORD
LOCAL dstWidth:DWORD, dstHeight:DWORD
LOCAL dstX:DWORD, dstY:DWORD
LOCAL srcX:DWORD, srcY:DWORD
LOCAL cosa:FXPT, sina:FXPT
LOCAL bigX:DWORD, bigY:DWORD

    ;cosa = FixedCos(angle)  
    ;sina = FixedSin(angle) 
    invoke FixedCos, angle
    mov cosa, eax
    xor eax, eax
    invoke FixedSin, angle
    mov sina, eax
    xor eax, eax
    ;esi = lpBmp
    mov esi, lpBmp
    ;shiftX = (EECS205BITMAP PTR [esi]).dwWidth * cosa / 2 ​  -  (EECS205BITMAP PTR [esi]).dwHeight * sina / 2
    ;          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ;                           a                                                     b
    mov edi, (EECS205BITMAP PTR [esi]).dwWidth          ;edi = dwWidth  
    mov dwWidth, edi                                    ;Def dwWidth
    invoke fxptintconv, cosa, dwWidth
    sar eax, 1
    mov edi, eax                        ;edi = a

    mov edx, (EECS205BITMAP PTR [esi]).dwHeight         ;edx = dwHeight
    mov dwHeight, edx                                   ;Def dwHeight
    invoke fxptintconv, sina, dwHeight
    sar eax, 1
    mov edx, eax                        ;edx = b

    sub edi, edx
    mov shiftX, edi                                     ;shiftX done



    ;shiftY = (EECS205BITMAP PTR [esi]).dwHeight * cosa / 2 +  (EECS205BITMAP PTR [esi]).dwWidth * sina / 2
    ;          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ;                           a                                                     b
    invoke fxptintconv, cosa, dwHeight
    sar eax, 1
    mov edi, eax                          ;edi = a

    invoke fxptintconv, sina, dwWidth
    sar eax, 1
    mov edx, eax                          ;edx = b

    add edi, edx
    mov shiftY, edi                       ;shiftY done



    ;dstWidth= (EECS205BITMAP PTR [esi]).dwWidth +  (EECS205BITMAP PTR [esi]).dwHeight;  
    ;           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ;                           a                                     b
    mov edi, dwWidth                                    ;a
    mov edx, dwHeight                                   ;b
    add edi, edx
    mov dstWidth, edi                                   ;dstWidth done
    ;dstHeight= dstWidth
    mov dstHeight, edi                                  ;dstHeight done



    ;for(dstX = -​dstWidth; dstX < dstWidth; dstX++)
    ;   for(dstY = -​dstHeight; dstY < dstHeight; dstY++) 
    ;       srcX = dstX*cosa + dstY*sina 
    ;       srcY = dstY*cosa – dstX*sina
    mov edi, dstWidth
    neg edi                         ;edi = dstX = -dstWidth
    mov dstX, edi
    jmp check_x
outer_for:
    mov ebx, dstHeight              ;ebx = dstHeight
    neg ebx                         ;ebx = -dstHeight
    mov dstY, ebx                   ;dstY = -dstHeight
    jmp check_y
    inner_for:
        ;srcX = dstX*cosa + dstY*sina
        invoke fxptintconv, cosa, dstX
        mov edi, eax                ;ebx = dstX*cosa
        
        invoke fxptintconv, sina, dstY
        mov edx, eax                ;ecx = dstY*sina
       
        add edi, edx
        mov srcX, edi               ;srcX done
        ;srcY = dstY*cosa – dstX*sina
        invoke fxptintconv, cosa, dstY
        mov edi, eax                ;ebx = dstY*cosa

        invoke fxptintconv, sina, dstX
        mov edx, eax                ;ecx = dstX*sina

        sub edi, edx
        mov srcY, edi               ;srcY done
;       if (srcX >= 0 && srcX < (EECS205BITMAP PTR [esi]).dwWidth &&      
;           srcY >= 0 && srcY < (EECS205BITMAP PTR [esi]).dwHeight &&     
;           (xcenter+dstX-​shiftX) >= 0 && 
;           (xcenter+dstX​-shiftX) < 639 &&     
;           (ycenter+dstY​-shiftY) >= 0 && 
;           (ycenter+dstY​-shiftY) < 479 &&     
;           bitmap pixel (srcX,srcY) is not transparent) then 
;               DrawPixel(xcenter+dstX-​shiftX, ycenter+dstY​-shiftY, bitmap pixel)
        ;1. srcX >= 0
        mov ebx, srcX                   ;ebx = srcX
        cmp ebx, 0
        jl dont_draw
        ;2. srcX < dwWidth
        cmp ebx, dwWidth
        jge dont_draw
        ;3. srcY >= 0
        mov ebx, srcY                   ;ebx = srcY
        cmp ebx, 0
        jl dont_draw
        ;4. srcY < dwHeight
        cmp ebx, dwHeight
        jge dont_draw
        ;5. (xcenter + dstX - shiftX) >= 0
        mov ebx, xcenter                ;ebx = xcenter  
        add ebx, dstX                   ;ebx = xcenter + dstX
        sub ebx, shiftX                 ;ebx = xcenter + dstX - shiftX
        mov bigX, ebx
        cmp bigX, 0
        jl dont_draw
        ;6. (xcenter + dstX​ - shiftX) < 640
        cmp bigX, 639
        jg dont_draw
        ;7. (ycenter + dstY​ - shiftY) >= 0
        mov ebx, ycenter                ;ebx = ycenter
        add ebx, dstY                   ;ebx = ycenter + dstY
        sub ebx, shiftY                 ;ebx = ycenter + dstY - shiftY
        mov bigY, ebx
        cmp bigY, 0
        jl dont_draw
        ;8. (ycenter + dstY - shiftY) < 480
        cmp bigY, 479
        jg dont_draw
        ;;;;;9. bitmap pixel (srcX, srcY) is not transparent
        ;Find color at this pixel (srxX, srcY)
        mov edx, dwWidth                    ;edx = dwWidth
        imul edx, srcY                      ;edx = dwWidth*srcY
        add edx, srcX                       ;edx = dwWidth*srcY + srcX
        
        ; mov eax, (EECS205BITMAP PTR [esi]).lpBytes
        ; xor ecx, ecx
        ; mov cl, BYTE PTR [eax + edx]                    ;cl = color of pixel\

        mov eax, (EECS205BITMAP PTR [esi]).lpBytes
        xor ecx, ecx
        mov cl, BYTE PTR [eax + edx]                ; get byte quantity of the coordinate.
        ;Get transparent color
        xor ebx, ebx
        mov bl , (EECS205BITMAP PTR [esi]).bTransparent ;bl = bTransparent
        ;See whether color is transparent at (srcX, srcY)
        cmp bl, cl
        je dont_draw
        ;;;;;;;;; ALL CONDITIONS PASSED. DRAW THE PIXEL!!
        ;DrawPixel(xcenter+dstX-​shiftX, ycenter+dstY​-shiftY, bitmap pixel)

        invoke DrawPixel, bigX, bigY, cl
    dont_draw:
        add dstY, 1

check_y:
    mov ebx, dstHeight
    cmp dstY, ebx
    jl inner_for

    add dstX, 1     ;Reached end of y values. Inc x and go back to outer_for
check_x:
    mov ebx, dstWidth
    cmp dstX, ebx
    jl outer_for    

	ret 			; Don't delete this line!!!		
RotateBlit ENDP



END
