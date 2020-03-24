; #########################################################################
;
;   game.inc - Includes for CompEng205 Assignment 4/5
;
;
; #########################################################################

;; Library Definitions
statuses STRUCT
    titlescreen DWORD ?
    aniframe DWORD ? 
    player_pause DWORD ?
    timer1 DWORD ?
    lives DWORD ?
    ;; Add more stuff here that you want to keep track of.
statuses ENDS

MouseInfo STRUCT
    x DWORD ?
    y DWORD ?
    buttons DWORD ?
MouseInfo ENDS

Sprites STRUCT  
    x DWORD ?
    y DWORD ?
    bitmap DWORD ?
Sprites ENDS

projectiles STRUCT
    x DWORD ?
    y DWORD ?
    targetx DWORD ?
    targety DWORD ?
    num DWORD ?
projectiles ENDS

boss STRUCT
    x DWORD ?
    y DWORD ?
    bitmap DWORD ?
    lives DWORD ?
boss ENDS

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD

;; Resource stuff that I (Seong Kim) added.
EXTERNDEF simoneBackground:EECS205BITMAP
EXTERNDEF Plane:EECS205BITMAP
EXTERNDEF twoB:EECS205BITMAP
EXTERNDEF russel:EECS205BITMAP
EXTERNDEF collisionMessage:EECS205BITMAP
EXTERNDEF arena:EECS205BITMAP
EXTERNDEF simoneboss:EECS205BITMAP
EXTERNDEF projectile:EECS205BITMAP
EXTERNDEF heart:EECS205BITMAP
EXTERNDEF gameover:EECS205BITMAP
EXTERNDEF heart1:EECS205BITMAP
EXTERNDEF heart2:EECS205BITMAP
EXTERNDEF heart3:EECS205BITMAP
EXTERNDEF bullet:EECS205BITMAP
EXTERNDEF victory:EECS205BITMAP
EXTERNDEF turret:EECS205BITMAP
EXTERNDEF fire:EECS205BITMAP
;; Boss Healthbars
EXTERNDEF bosshealth1:EECS205BITMAP
EXTERNDEF bosshealth2:EECS205BITMAP
EXTERNDEF bosshealth3:EECS205BITMAP
EXTERNDEF bosshealth4:EECS205BITMAP
EXTERNDEF bosshealth5:EECS205BITMAP
EXTERNDEF bosshealth6:EECS205BITMAP
EXTERNDEF bosshealth7:EECS205BITMAP
EXTERNDEF bosshealth8:EECS205BITMAP
EXTERNDEF bosshealth9:EECS205BITMAP
EXTERNDEF bosshealth10:EECS205BITMAP
EXTERNDEF bosshealth11:EECS205BITMAP
EXTERNDEF bosshealth12:EECS205BITMAP
EXTERNDEF bosshealth13:EECS205BITMAP
EXTERNDEF bosshealth14:EECS205BITMAP
EXTERNDEF bosshealth15:EECS205BITMAP
EXTERNDEF bosshealth16:EECS205BITMAP
;; Character 2B Sprites - from charactersprites.asm
EXTERNDEF up1:EECS205BITMAP
EXTERNDEF up2:EECS205BITMAP
EXTERNDEF down1:EECS205BITMAP
EXTERNDEF down2:EECS205BITMAP
EXTERNDEF left1:EECS205BITMAP
EXTERNDEF left2:EECS205BITMAP
EXTERNDEF right1:EECS205BITMAP
EXTERNDEF right2:EECS205BITMAP

;; User Defined Functions
GameInit PROTO
GamePlay PROTO
CheckIntersect PROTO oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP 




