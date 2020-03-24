; #########################################################################
;
;   game.asm - Assembly file for CompEng205 Assignment 4/5
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
include game.inc
include keys.inc
.DATA
.CODE
up1 EECS205BITMAP <14, 17, 0e0h,, offset up1 + sizeof up1>
	BYTE 0e0h,0e0h,0e0h,0e0h,000h,08eh,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,092h,092h,08eh,092h,092h,092h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h
	BYTE 0ffh,092h,0ffh,092h,0ffh,0ffh,092h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,0ffh,0ffh,0ffh
	BYTE 092h,0ffh,0ffh,0ffh,0ffh,092h,0e0h,0e0h,0e0h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,092h,0e0h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,092h,0ffh,092h,092h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,092h
	BYTE 092h,0ffh,000h,0ffh,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,0ffh,000h
	BYTE 000h,0ffh,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,0ffh,000h,0e0h,000h
	BYTE 092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,000h,0e0h,0e0h,000h,092h,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,000h,0e0h,000h,0ffh,092h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,092h,0ffh,000h,000h,0ffh,092h,092h,0ffh,092h,0ffh,0ffh
	BYTE 092h,0ffh,0ffh,092h,0ffh,000h,0e0h,000h,092h,0ffh,0ffh,092h,092h,0ffh,092h,0ffh
	BYTE 092h,092h,000h,0e0h,0e0h,0e0h,092h,092h,092h,092h,092h,092h,092h,092h,092h,000h
	BYTE 0e0h,0e0h,0e0h,0e0h,000h,08eh,08eh,08eh,000h,000h,08eh,08eh,08eh,000h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,000h,000h,000h,0e0h,0e0h,000h,000h,000h,0e0h,0e0h,0e0h

;;;;;
up2 EECS205BITMAP <14, 16, 0e0h,, offset up2 + sizeof up2>
	BYTE 0e0h,0e0h,0e0h,0e0h,000h,08eh,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,092h,092h,08eh,092h,092h,092h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h
	BYTE 0ffh,092h,0ffh,092h,0ffh,0ffh,092h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,0ffh,0ffh,0ffh
	BYTE 092h,0ffh,0ffh,0ffh,0ffh,092h,0e0h,0e0h,0e0h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,092h,0e0h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,092h,0ffh,092h,092h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,092h
	BYTE 092h,0ffh,000h,0ffh,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,0ffh,000h
	BYTE 000h,0ffh,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,0ffh,000h,000h,000h
	BYTE 092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,000h,0ffh,000h,0ffh,092h,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,000h,0ffh,0e0h,000h,092h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,092h,0ffh,000h,0e0h,0e0h,092h,092h,0ffh,092h,0ffh,0ffh
	BYTE 092h,0ffh,0ffh,092h,0ffh,000h,0e0h,0e0h,092h,0ffh,0ffh,092h,092h,0ffh,092h,0ffh
	BYTE 092h,092h,000h,0e0h,0e0h,0e0h,092h,092h,092h,092h,092h,092h,092h,092h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,000h,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h


;;;;;
down1 EECS205BITMAP <18, 17, 0e0h,, offset down1 + sizeof down1>
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,08eh,000h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,092h,0e0h,092h,092h,092h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,092h,0ffh,0ffh,092h,0ffh,0ffh,0ffh
	BYTE 092h,092h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,092h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,0e0h,0e0h,0e0h,0e0h,000h,092h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,092h,0ffh,0ffh,0ffh,0ffh,0ffh,092h,000h,0e0h,0e0h,0e0h,0e0h,092h
	BYTE 0ffh,0ffh,092h,092h,0ffh,0ffh,092h,0ffh,0ffh,0ffh,092h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 000h,0ffh,092h,092h,0ffh,0ffh,092h,0ffh,0ffh,092h,092h,0ffh,0ffh,000h,0e0h,0e0h
	BYTE 0e0h,0e0h,0b2h,0ffh,08eh,0ffh,0ffh,000h,0ffh,0ffh,092h,0ffh,0ffh,0ffh,0ffh,0b2h
	BYTE 0e0h,0e0h,0e0h,0b2h,0ffh,0b2h,08eh,0ffh,0ffh,000h,0ffh,0ffh,000h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0b2h,0e0h,0b2h,0ffh,0ffh,0b2h,08eh,000h,0ffh,0ffh,08eh,08eh,0ffh,0ffh
	BYTE 092h,0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0b2h,0b2h,0ffh,08eh,000h,000h,000h,000h,000h
	BYTE 000h,000h,092h,0ffh,0ffh,0b2h,0b2h,0e0h,0e0h,0e0h,000h,0ffh,0ffh,000h,000h,08eh
	BYTE 08eh,08eh,08eh,000h,092h,0ffh,0ffh,000h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 000h,08eh,000h,000h,000h,000h,000h,000h,08eh,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,000h,08eh,08eh,08eh,000h,000h,08eh,08eh,08eh,000h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,000h,000h,000h,0e0h,0e0h,000h,000h,000h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h


;;;;;
down2 EECS205BITMAP <18, 16, 0e0h,, offset down2 + sizeof down2>
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,08eh,000h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,092h,0e0h,092h,092h,092h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,092h,0ffh,0ffh,092h,0ffh,0ffh,0ffh
	BYTE 092h,092h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,092h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,092h,0e0h,0e0h,0e0h,0e0h,000h,092h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,092h,0ffh,0ffh,0ffh,0ffh,0ffh,092h,000h,0e0h,0e0h,0e0h,0e0h,092h
	BYTE 0ffh,0ffh,092h,092h,0ffh,0ffh,092h,0ffh,0ffh,0ffh,092h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 000h,0ffh,092h,092h,0ffh,0ffh,092h,0ffh,0ffh,092h,092h,0ffh,0ffh,000h,0e0h,0e0h
	BYTE 0e0h,0e0h,0b2h,0ffh,08eh,0ffh,0ffh,000h,0ffh,0ffh,092h,0ffh,0ffh,0ffh,0ffh,092h
	BYTE 0e0h,0e0h,0e0h,0b2h,0ffh,0b2h,08eh,0ffh,0ffh,000h,0ffh,0ffh,000h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,092h,0e0h,0b2h,0ffh,0ffh,0b2h,08eh,000h,0ffh,0ffh,08eh,08eh,0ffh,0ffh
	BYTE 092h,0ffh,0ffh,0ffh,0ffh,092h,0e0h,0b2h,0b2h,0b2h,08eh,000h,000h,000h,000h,000h
	BYTE 000h,000h,092h,0ffh,0ffh,092h,092h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,000h,08eh,000h
	BYTE 000h,08eh,000h,0ffh,0ffh,092h,092h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h
	BYTE 000h,000h,000h,000h,000h,0ffh,0ffh,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,000h,08eh,08eh,000h,000h,0e0h,000h,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,000h,000h,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h


;;;;;
left1 EECS205BITMAP <14, 17, 0e0h,, offset left1 + sizeof left1>
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0b2h,0b2h,0b2h,0b2h,0b2h,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0e0h,0b2h,0ffh,0ffh,0ffh,0ffh,0b2h,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0b2h,0ffh,0b2h,0b2h,0ffh,0ffh,0b2h,0ffh,0ffh
	BYTE 0ffh,0b2h,0b2h,0e0h,0b2h,0ffh,0ffh,0b2h,0ffh,0b2h,0ffh,0ffh,0b2h,0ffh,0ffh,0ffh
	BYTE 0ffh,0dbh,0e0h,0b2h,0b2h,0ffh,000h,0ffh,0dbh,0dbh,0dbh,0b2h,0ffh,0b2h,0b2h,0ffh
	BYTE 0e0h,0e0h,000h,0ffh,000h,0ffh,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e0h,0e0h
	BYTE 000h,0ffh,0ffh,0ffh,0dbh,0ffh,0ffh,0ffh,0b2h,0ffh,0b2h,0ffh,0e0h,0e0h,0e0h,000h
	BYTE 08eh,0ffh,0dbh,0ffh,0dbh,0b2h,0ffh,0ffh,0b2h,0ffh,0e0h,0e0h,0e0h,0e0h,000h,000h
	BYTE 0dbh,0ffh,0dbh,0ffh,0ffh,0ffh,0ffh,0b6h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,0ffh,0ffh
	BYTE 0ffh,0b2h,0ffh,0b2h,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,000h,0ffh,0ffh,0b2h
	BYTE 0ffh,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,08eh,08eh,000h,000h,0b2h,0b2h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,08eh,08eh,08eh,08eh,000h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,000h,000h,000h,000h,0e0h,0e0h,0e0h,0e0h,0e0h

;;;;;
left2 EECS205BITMAP <14, 16, 0e0h,, offset left2 + sizeof left2>
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0b2h,0b2h,0b2h,0b2h,0b2h,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0e0h,0b2h,0ffh,0ffh,0ffh,0ffh,0b2h,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0b2h,0b2h,0ffh,0b2h,0b2h,0ffh,0ffh,0b2h,0ffh,0ffh
	BYTE 0ffh,0b2h,0b2h,0e0h,0b2h,0ffh,0ffh,0b2h,0ffh,0b2h,0ffh,0ffh,0b2h,0ffh,0ffh,0ffh
	BYTE 0ffh,0b2h,0e0h,0b2h,0b2h,0ffh,000h,0ffh,0ffh,0ffh,0b2h,0b2h,0ffh,0b2h,0b2h,0ffh
	BYTE 0e0h,0e0h,000h,0ffh,000h,0ffh,0ffh,06dh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0e0h,0e0h
	BYTE 000h,0ffh,0ffh,0ffh,0ffh,06dh,0ffh,0ffh,092h,0ffh,092h,0ffh,0e0h,0e0h,0e0h,000h
	BYTE 08eh,0ffh,0ffh,06dh,000h,092h,0ffh,0ffh,092h,0ffh,0e0h,0e0h,0e0h,0e0h,000h,06dh
	BYTE 0ffh,06dh,000h,092h,0ffh,0ffh,0ffh,092h,0e0h,0e0h,000h,000h,000h,06dh,06dh,06dh
	BYTE 0ffh,0ffh,092h,092h,092h,0e0h,0e0h,000h,08eh,08eh,000h,08eh,08eh,000h,0ffh,0ffh
	BYTE 000h,000h,000h,0e0h,0e0h,0e0h,000h,08eh,08eh,000h,000h,000h,000h,000h,000h,08eh
	BYTE 000h,0e0h,0e0h,0e0h,0e0h,000h,000h,000h,0e0h,0e0h,0e0h,0e0h,000h,000h,0e0h,0e0h


;;;;;
right1 EECS205BITMAP <14, 17, 0e0h,, offset right1 + sizeof right1>
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0b2h,0b2h,0b2h,0b2h,0b2h,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0e0h,0b2h,0ffh,0ffh,0ffh,0ffh,0ffh,0b2h
	BYTE 0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0b2h,0b2h,0ffh,0ffh,0ffh,0b2h,0ffh,0ffh,0b2h
	BYTE 0b2h,0ffh,0b2h,0e0h,0dbh,0ffh,0ffh,0ffh,0ffh,0b2h,0ffh,0ffh,0b2h,0ffh,0b2h,0ffh
	BYTE 0ffh,0b2h,0ffh,0b2h,0b2h,0ffh,0b2h,0dbh,0dbh,0dbh,0ffh,000h,0ffh,0b2h,0b2h,0e0h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0ffh,000h,0ffh,000h,0e0h,0e0h,0ffh,0b2h
	BYTE 0ffh,0b2h,0ffh,0ffh,0ffh,0dbh,0ffh,0ffh,0ffh,000h,0e0h,0e0h,0ffh,0b2h,0ffh,0ffh
	BYTE 0b2h,0dbh,0ffh,0dbh,0ffh,08eh,000h,0e0h,0e0h,0e0h,0b6h,0ffh,0ffh,0ffh,0ffh,0dbh
	BYTE 0ffh,0dbh,000h,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h,0b2h,0ffh,0b2h,0ffh,0ffh,0ffh
	BYTE 000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h,0ffh,0b2h,0ffh,0ffh,000h,000h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h,0b2h,000h,000h,08eh,08eh,000h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,08eh,08eh,08eh,08eh,000h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,000h,000h,000h,000h,0e0h,0e0h,0e0h,0e0h,0e0h

;;;;;
right2 EECS205BITMAP <14, 16, 0e0h,, offset right2 + sizeof right2>
	BYTE 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,000h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h
	BYTE 0e0h,0e0h,0b2h,0b2h,0b2h,0b2h,0b2h,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0e0h,0e0h,0e0h,0b2h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0e0h,0b2h,0ffh,0ffh,0ffh,0ffh,0ffh,0b2h
	BYTE 0ffh,0ffh,0ffh,0ffh,0b2h,0e0h,0e0h,0b2h,0b2h,0ffh,0ffh,0ffh,0b2h,0ffh,0ffh,0b2h
	BYTE 0b2h,0ffh,0b2h,0b2h,0b2h,0ffh,0ffh,0ffh,0ffh,0b2h,0ffh,0ffh,0b2h,0ffh,0b2h,0ffh
	BYTE 0ffh,0b2h,0ffh,0b2h,0b2h,0ffh,0b2h,0b2h,0ffh,0ffh,0ffh,000h,0ffh,0b2h,0b2h,0e0h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,06dh,0ffh,0ffh,000h,0ffh,000h,0e0h,0e0h,0ffh,092h
	BYTE 0ffh,092h,0ffh,0ffh,06dh,0ffh,0ffh,0ffh,0ffh,000h,0e0h,0e0h,0ffh,092h,0ffh,0ffh
	BYTE 092h,000h,06dh,0ffh,0ffh,08eh,000h,0e0h,0e0h,0e0h,092h,0ffh,0ffh,0ffh,092h,000h
	BYTE 06dh,0ffh,06dh,000h,0e0h,0e0h,0e0h,0e0h,0e0h,092h,092h,092h,0ffh,0ffh,06dh,06dh
	BYTE 06dh,000h,000h,000h,0e0h,0e0h,0e0h,000h,000h,000h,0ffh,0ffh,000h,08eh,08eh,000h
	BYTE 08eh,08eh,000h,0e0h,0e0h,000h,08eh,000h,000h,000h,000h,000h,000h,08eh,08eh,000h
	BYTE 0e0h,0e0h,0e0h,0e0h,000h,000h,0e0h,0e0h,0e0h,0e0h,000h,000h,000h,0e0h,0e0h,0e0h


;;;;;
END