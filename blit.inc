; #########################################################################
;
;   blit.inc - Includes for CompEng205 Assignment 3
;
;
; #########################################################################


_EECS205BITMAP STRUCT
 dwWidth      DWORD  ?  ; Width of bitmap
 dwHeight     DWORD  ?  ; Height of bitmap
 bTransparent BYTE   ?  ; Color for transparency
              BYTE   3 DUP(?)   ; this is BYTE. NOT DWORD
 lpBytes      DWORD  ?  ; Start of the bitmap's color values
_EECS205BITMAP ENDS

EECS205BITMAP TYPEDEF _EECS205BITMAP

EXTERNDEF ScreenBitsPtr:DWORD

BasicBlit PROTO STDCALL ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD

RotateBlit PROTO STDCALL ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	   





