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

;Includes
include stars.inc
include lines.inc
include trig.inc
include blit.inc
include game.inc
;Sounds
include C:\Programs\MASM32\include\windows.inc
include C:\Programs\MASM32\include\winmm.inc
includelib C:\Programs\MASM32\lib\winmm.lib
include keys.inc

	
.DATA
      ;; 2B Character Sprites
      twoB_up DWORD OFFSET up1, OFFSET up2
      twoB_down DWORD OFFSET down1, OFFSET down2
      twoB_left DWORD OFFSET left1, OFFSET left2
      twoB_right DWORD OFFSET right1, OFFSET right2
      ;; Bitmaps
      titlescreen_text_1 BYTE "Far Manualmata", 0                       
      titlescreen_text_2 BYTE "Press z to start...", 0
      ;;Assign each sprite their own Sprites STRUCT. Can initialize their positions here. Or do it in GameInit
      twoB_struct Sprites <320, 350, OFFSET up1>
      plane_struct Sprites <0, 0, OFFSET Plane>
      bullet1 Sprites <1000, 1000, OFFSET bullet>
      bullet2 Sprites <?, ?, OFFSET bullet>
      ; simoneboss_struct Sprites <300, 100, OFFSET simoneboss>
      ;;; Use the following position just for testing
      simoneboss_struct boss <320, 100, OFFSET simoneboss, 16>
      simoneboss_turret_1 boss <96, 50, OFFSET turret, 16>
      simoneboss_turret_2 boss <543, 50, OFFSET turret, 16>
      ;; Statuses Struct
      statuses_struct statuses <1, 0, 0, 0, 3>
      ;; Empty projectiles array. Elements will be filled with projectile structs. This is done with fill_proj_arr PROC.
      projectiles_struct projectiles <?, ?, ?, ?, ?>
      projectiles_arr BYTE (SIZEOF projectiles * 200) DUP(projectiles)
      projectiles_arr_mirror BYTE (SIZEOF projectiles * 200) DUP(projectiles)
      projectiles_arr_2 BYTE (SIZEOF projectiles * 200) DUP(projectiles)
      projectiles_arr_2_mirror BYTE (SIZEOF projectiles * 200) DUP(projectiles)
      projectiles_arr_3 BYTE (SIZEOF projectiles * 200) DUP(projectiles)
      projectiles_arr_3_mirror BYTE (SIZEOF projectiles * 200) DUP(projectiles)
      ;; Fire Trails
      firetrail1 projectiles <100, 191, 0, 0, 1>
      firetrail2 projectiles <200, 246, 0, 0, 1>
      firetrail3 projectiles <300, 301, 0, 0, 1>
      firetrail4 projectiles <400, 394, 0, 0, 1>
      firetrail5 projectiles <500, 457, 0, 0, 1>
      ;; Boss healthbar array
      bosshealth_arr DWORD OFFSET bosshealth1, OFFSET bosshealth2, OFFSET bosshealth3, OFFSET bosshealth4, OFFSET bosshealth5, OFFSET bosshealth6, OFFSET bosshealth7, OFFSET bosshealth8, OFFSET bosshealth9, OFFSET bosshealth10, OFFSET bosshealth11, OFFSET bosshealth12, OFFSET bosshealth13, OFFSET bosshealth14, OFFSET bosshealth15, OFFSET bosshealth16
      ;; Music
      ABeautifulSong BYTE "A-Beautiful-Song.wav"
      ;; Global Timer Variables for Boss Attacks
      pattern1_timer DWORD 0
      pattern1_timer_mirror DWORD 0
      ;; Pattern velocity vectors
      ; 15 projectiles
      pattern1_vel1 DWORD -1, 0,    -2, 0,      -3, 0,    -4,0,     -5, 0,    -4, 1,      -3, 1,      -2, 1,      -3, 2,      -1, 1,    -2, 2,     -2, 3,     -1, 2,      -1, 3,      -1, 4
      ; 21 projectiles
      pattern1_vel2 DWORD 0, 1,     0, 2,      0, 3,    0, 4,    0, 5,          1, 0,       2, 0,       3, 0,       4, 0,       5, 0,       4, 1,       3,1,     3,2,      2,1,        1,1,        2,2,        2,3,        1,2,        1,3,        1,4
    

;;;;;
.CODE
;; Note: You will need to implement CheckIntersect!!!
; number, number -> array
; Takes in number of array elements (count) and size of the struct that populates each element (size_struct)
; Modifies projectiles_struct to be filled with specified number of structs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Fill all projectile arrays with projectile stucts;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fill_proj_arr PROC count:DWORD, size_of_struct:DWORD
      mov edi, count                      ;edi = count = number of elements
      mov esi, size_of_struct                ;This is our array increment to get to the next struct element.

      mov ebx, 0                          ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    add a proj struct to current index
      ;;    increment ebx
      jmp cond
            body:
                  mov ecx, ebx
                  imul ecx, SIZEOF projectiles
                  mov [projectiles_arr + ecx], projectiles
                  inc ebx
            cond:
                  cmp ebx, edi
                  jl body
                  ret
fill_proj_arr ENDP
;;;;;
fill_proj_arr_2 PROC count:DWORD, size_of_struct:DWORD
      mov edi, count                      ;edi = count = number of elements
      mov esi, size_of_struct                ;This is our array increment to get to the next struct element.

      mov ebx, 0                          ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    add a proj struct to current index
      ;;    increment ebx
      jmp cond
            body:
                  mov ecx, ebx
                  imul ecx, SIZEOF projectiles
                  mov [projectiles_arr_2 + ecx], projectiles
                  inc ebx
            cond:
                  cmp ebx, edi
                  jl body
                  ret
fill_proj_arr_2 ENDP
;;;;;
fill_proj_arr_3 PROC count:DWORD, size_of_struct:DWORD
      mov edi, count                      ;edi = count = number of elements
      mov esi, size_of_struct                ;This is our array increment to get to the next struct element.

      mov ebx, 0                          ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    add a proj struct to current index
      ;;    increment ebx
      jmp cond
            body:
                  mov ecx, ebx
                  imul ecx, SIZEOF projectiles
                  mov [projectiles_arr_3 + ecx], projectiles
                  inc ebx
            cond:
                  cmp ebx, edi
                  jl body
                  ret
fill_proj_arr_3 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Second Set ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fill_proj_arr_mirror PROC count:DWORD, size_of_struct:DWORD
      mov edi, count                      ;edi = count = number of elements
      mov esi, size_of_struct                ;This is our array increment to get to the next struct element.

      mov ebx, 0                          ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    add a proj struct to current index
      ;;    increment ebx
      jmp cond
            body:
                  mov ecx, ebx
                  imul ecx, SIZEOF projectiles
                  mov [projectiles_arr_mirror + ecx], projectiles
                  inc ebx
            cond:
                  cmp ebx, edi
                  jl body
                  ret
fill_proj_arr_mirror ENDP
;;;;;
fill_proj_arr_2_mirror PROC count:DWORD, size_of_struct:DWORD
      mov edi, count                      ;edi = count = number of elements
      mov esi, size_of_struct                ;This is our array increment to get to the next struct element.

      mov ebx, 0                          ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    add a proj struct to current index
      ;;    increment ebx
      jmp cond
            body:
                  mov ecx, ebx
                  imul ecx, SIZEOF projectiles
                  mov [projectiles_arr_2_mirror + ecx], projectiles
                  inc ebx
            cond:
                  cmp ebx, edi
                  jl body
                  ret
fill_proj_arr_2_mirror ENDP
;;;;;
fill_proj_arr_3_mirror PROC count:DWORD, size_of_struct:DWORD
      mov edi, count                      ;edi = count = number of elements
      mov esi, size_of_struct                ;This is our array increment to get to the next struct element.

      mov ebx, 0                          ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    add a proj struct to current index
      ;;    increment ebx
      jmp cond
            body:
                  mov ecx, ebx
                  imul ecx, SIZEOF projectiles
                  mov [projectiles_arr_3_mirror + ecx], projectiles
                  inc ebx
            cond:
                  cmp ebx, edi
                  jl body
                  ret
fill_proj_arr_3_mirror ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Fill all projectile arrays with boss positions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_projectiles PROC count:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                             ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      mov ebx, simoneboss_struct.x
      mov edx, simoneboss_struct.y
      mov esi, 1
      jmp cond
      body:
            mov ecx, loopcounter
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr
            mov (projectiles PTR [ecx]).x, ebx
            mov (projectiles PTR [ecx]).y, edx
            mov (projectiles PTR [ecx]).num, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            ret
init_projectiles ENDP
;;;;;
init_projectiles_2 PROC count:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                             ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      mov ebx, simoneboss_turret_1.x
      mov edx, simoneboss_turret_1.y
      mov esi, 1
      jmp cond
      body:
            mov ecx, loopcounter
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_2
            mov (projectiles PTR [ecx]).x, ebx
            mov (projectiles PTR [ecx]).y, edx
            mov (projectiles PTR [ecx]).num, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            ret
init_projectiles_2 ENDP
;;;;;
init_projectiles_3 PROC count:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                             ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      mov ebx, simoneboss_turret_2.x
      mov edx, simoneboss_turret_2.y
      mov esi, 1
      jmp cond
      body:
            mov ecx, loopcounter
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_3
            mov (projectiles PTR [ecx]).x, ebx
            mov (projectiles PTR [ecx]).y, edx
            mov (projectiles PTR [ecx]).num, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            ret
init_projectiles_3 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Second Set ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
init_projectiles_mirror PROC count:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                             ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      mov ebx, simoneboss_struct.x
      mov edx, simoneboss_struct.y
      mov esi, 1
      jmp cond
      body:
            mov ecx, loopcounter
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_mirror
            mov (projectiles PTR [ecx]).x, ebx
            mov (projectiles PTR [ecx]).y, edx
            mov (projectiles PTR [ecx]).num, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            ret
init_projectiles_mirror ENDP
;;;;;
init_projectiles_2_mirror PROC count:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                             ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      mov ebx, simoneboss_turret_1.x
      mov edx, simoneboss_turret_1.y
      mov esi, 1
      jmp cond
      body:
            mov ecx, loopcounter
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_2_mirror
            mov (projectiles PTR [ecx]).x, ebx
            mov (projectiles PTR [ecx]).y, edx
            mov (projectiles PTR [ecx]).num, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            ret
init_projectiles_2_mirror ENDP
;;;;;
init_projectiles_3_mirror PROC count:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                             ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      mov ebx, simoneboss_turret_2.x
      mov edx, simoneboss_turret_2.y
      mov esi, 1
      jmp cond
      body:
            mov ecx, loopcounter
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_3_mirror
            mov (projectiles PTR [ecx]).x, ebx
            mov (projectiles PTR [ecx]).y, edx
            mov (projectiles PTR [ecx]).num, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            ret
init_projectiles_3_mirror ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Initialize game objects and CheckIntersect Procedure ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GameInit PROC uses edi    ;Called by the library code ONCE on startup. Put initializations here.
      ;Currently, all bitmap positions are being initialized in .DATA
      invoke fill_proj_arr, 35, SIZEOF projectiles
      invoke init_projectiles, 35

      invoke fill_proj_arr_2, 35, SIZEOF projectiles
      invoke init_projectiles_2, 35

      invoke fill_proj_arr_3, 35, SIZEOF projectiles
      invoke init_projectiles_3, 35
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;;;; Second Set ;;;;;;;;;;;;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      invoke fill_proj_arr_mirror, 35, SIZEOF projectiles
      invoke init_projectiles_mirror, 35

      invoke fill_proj_arr_2_mirror, 35, SIZEOF projectiles
      invoke init_projectiles_2_mirror, 35

      invoke fill_proj_arr_3_mirror, 35, SIZEOF projectiles
      invoke init_projectiles_3_mirror, 35
	ret         ;; Do not delete this line!!!
GameInit ENDP
;;;;;
CheckIntersect PROC STDCALL oneX:DWORD, oneY:DWORD, oneBitmap:PTR EECS205BITMAP, twoX:DWORD, twoY:DWORD, twoBitmap:PTR EECS205BITMAP
      LOCAL one_upp_leftX:DWORD, one_upp_leftY:DWORD, one_upp_rightX:DWORD, one_upp_rightY:DWORD
      LOCAL one_bot_leftX:DWORD, one_bot_leftY:DWORD, one_bot_rightX:DWORD, one_bot_rightY:DWORD
      LOCAL two_upp_leftX:DWORD, two_upp_leftY:DWORD, two_upp_rightX:DWORD, two_upp_rightY:DWORD
      LOCAL two_bot_leftX:DWORD, two_bot_leftY:DWORD, two_bot_rightX:DWORD, two_bot_rightY:DWORD
      ;;; Create the bounding box for object "one"
      ;; Upper Left: (one.x - bitmap.width / 2, one.y - bitmap.height / 2) 
      mov esi, oneBitmap
      mov edi, oneX                                   ;edi = oneX
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwWidth
      mov ebx, 2
      div ebx                                         ;eax should contain dwWidth/2
      sub edi, eax                                    ;edi = oneX - dwWidth/2
      mov one_upp_leftX, edi                          ;one_upp_leftX = oneX - dwWidth/2
      mov edi, oneY                                   ;;;edi = oneY
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwHeight
      mov ebx, 2
      div ebx                                         ;eax should contain dwHeight/2
      sub edi, eax                                    ;edi = oneY - dwHeight/2
      mov one_upp_leftY, edi                          ;;;one_upp_leftY = oneY - dwHeight/2

      ;; Upper Right: (one.x + bitmap.width / 2, one.y - bitmap.height / 2) 
      mov edi, oneX                                   ;edi = oneX
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwWidth
      mov ebx, 2
      div ebx                                         ;eax should contain dwWidth/2
      add edi, eax                                    ;edi = oneX + dwWidth/2
      mov one_upp_rightX, edi                         ;one_upp_rightX = oneX - dwWidth/2
      mov edi, oneY                                   ;;;edi = oneY
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwHeight
      mov ebx, 2
      div ebx                                         ;eax should contain dwHeight/2
      sub edi, eax                                    ;edi = oneY - dwHeight/2
      mov one_upp_rightY, edi                         ;;;one_upp_rightY = oneY - dwHeight/2

      ;; Bottom Left: (one.x - bitmap.width / 2, one.y + bitmap.height / 2)
      mov edi, oneX                                   ;edi = oneX
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwWidth
      mov ebx, 2
      div ebx                                         ;eax should contain dwWidth/2
      sub edi, eax                                    ;edi = oneX - dwWidth/2
      mov one_bot_leftX, edi                          ;one_bot_leftX = oneX - dwWidth/2
      mov edi, oneY                                   ;;;edi = oneY
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwHeight
      mov ebx, 2
      div ebx                                         ;eax should contain dwHeight/2
      add edi, eax                                    ;edi = oneY + dwHeight/2
      mov one_bot_leftY, edi                          ;;;one_bot_right = oneY + dwHeight/2

      ;; Bottom Right: (one.x + bitmap.width / 2, one.y + bitmap.height / 2)
      mov edi, oneX                                   ;edi = oneX
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwWidth
      mov ebx, 2
      div ebx                                         ;eax should contain dwWidth/2
      add edi, eax                                    ;edi = oneX + dwWidth/2
      mov one_bot_rightX, edi                         ;one_bot_leftX = oneX + dwWidth/2
      mov edi, oneY                                   ;;;edi = oneY
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwHeight
      mov ebx, 2
      div ebx                                         ;eax should contain dwHeight/2
      add edi, eax                                    ;edi = oneY + dwHeight/2
      mov one_bot_rightY, edi                         ;;;one_bot_right = oneY + dwHeight/2






      ;;; Create the bounding box for object "two"
      ;; Upper Left: (two.x - bitmap.width / 2, two.y - bitmap.height / 2) 
      mov esi, twoBitmap
      mov edi, twoX                                   ;edi = twoX
      mov eax, (EECS205BITMAP PTR[esi]).dwWidth
      mov ebx, 2
      xor edx, edx
      div ebx                                         ;eax should contain dwWidth/2
      sub edi, eax                                    ;edi = twoX - dwWidth/2
      mov two_upp_leftX, edi                          ;two_upp_leftX = twoX - dwWidth/2
      mov edi, twoY                                   ;;;edi = twoY
      mov eax, (EECS205BITMAP PTR[esi]).dwHeight
      mov ebx, 2
      xor edx, edx
      div ebx                                         ;eax should contain dwHeight/2
      sub edi, eax                                    ;edi = twoY - dwHeight/2
      mov two_upp_leftY, edi                          ;;;two_upp_leftY = twoY - dwHeight/2

      ;; Upper Right: (two.x + bitmap.width / 2, two.y - bitmap.height / 2) 
      mov edi, twoX                                   ;edi = twoX
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwWidth
      mov ebx, 2
      div ebx                                         ;eax should contain dwWidth/2
      add edi, eax                                    ;edi = twoX + dwWidth/2
      mov two_upp_rightX, edi                         ;two_upp_rightX = twoX - dwWidth/2
      mov edi, twoY                                   ;;;edi = twoY
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwHeight
      mov ebx, 2
      div ebx                                         ;eax should contain dwHeight/2
      sub edi, eax                                    ;edi = twoY - dwHeight/2
      mov two_upp_rightY, edi                         ;;;two_upp_rightY = twoY - dwHeight/2

      ;; Bottom Left: (two.x - bitmap.width / 2, two.y + bitmap.height / 2)
      mov edi, twoX                                   ;edi = twoX
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwWidth
      mov ebx, 2
      div ebx                                         ;eax should contain dwWidth/2
      sub edi, eax                                    ;edi = twoX - dwWidth/2
      mov two_bot_leftX, edi                          ;two_bot_leftX = twoX - dwWidth/2
      mov edi, twoY                                   ;;;edi = twoY
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwHeight
      mov ebx, 2
      div ebx                                         ;eax should contain dwHeight/2
      add edi, eax                                    ;edi = twoY + dwHeight/2
      mov two_bot_leftY, edi                          ;;;two_bot_right = twoY + dwHeight/2

      ;; Bottom Right: (two.x + bitmap.width / 2, two.y + bitmap.height / 2)
      mov edi, twoX                                   ;edi = twoX
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwWidth
      mov ebx, 2
      div ebx                                         ;eax should contain dwWidth/2
      add edi, eax                                    ;edi = twoX + dwWidth/2
      mov two_bot_rightX, edi                         ;two_bot_leftX = twoX + dwWidth/2
      mov edi, twoY                                   ;;;edi = twoY
      xor edx, edx
      mov eax, (EECS205BITMAP PTR[esi]).dwHeight
      mov ebx, 2
      div ebx                                         ;eax should contain dwHeight/2
      add edi, eax                                    ;edi = twoY + dwHeight/2
      mov two_bot_rightY, edi                         ;;;two_bot_right = twoY + dwHeight/2


      ;;;;; Now we have all 4 corners for both "one" and "two"
      ;;;;; Check for collisions
      ; For each corner of "two", check if its within the boundary of "one"

      ; After this, have to check if "one" is in the boundary of "two" as well
      ; This is because if "two" completely covers "one", "two"'s corners will not be inside of "one"
      ; but "one"'s corners WILL be inside of "two"

     ;top_left                                                    ;Check if "two"'s corners are inside "one"
            xor eax, eax                  
            mov ebx, two_upp_leftX                                ;ebx = two_upp_leftX
            mov ecx, one_upp_leftX                                ;ecx = one_upp_leftX
            cmp ebx, ecx                                          
            jl top_right                                          ;if ebx < ecx, this corner outside "one"'s left edge. Move onto next corner
            mov ebx, two_upp_leftX                                ;if ebx > ecx, check "one"'s next edge      
            mov ecx, one_upp_rightX
            cmp ebx, ecx            
            jg top_right                                          ;if ebx > ecx, this corner outside "one"'s right edge. Move onto next corner
            mov ebx, two_upp_leftY                                ;if ebx < ecx, check "one"'s next edge    
            mov ecx, one_upp_leftY
            cmp ebx, ecx
            jl top_right                                          ;if ebx < ecx, this corner outside "one"'s top edge. Move onto next corner
            mov ebx, two_upp_leftY                                ;if ebx > ecx, check "one"'s next edge   
            mov ecx, one_bot_leftY
            cmp ebx, ecx
            jg top_right                                          ;if ebx > ecx, this corner outside "one"'s BOTTOM edge. Move onto next corner
            mov eax, 1                                            ;if ebx < ecx, COLLISION. Set eax=1
            jmp collided
      top_right:                                                  ;Next do the same thing for top_right. Refer to comments for top_left (Line 226)
            mov ebx, two_upp_rightX
            mov ecx, one_upp_leftX
            cmp ebx, ecx
            jl bot_left
            mov ebx, two_upp_rightX
            mov ecx, one_upp_rightX
            cmp ebx, ecx
            jg bot_left
            mov ebx, two_upp_rightY
            mov ecx, one_upp_leftY
            cmp ebx, ecx
            jl bot_left
            mov ebx, two_upp_rightY
            mov ecx, one_bot_leftY
            cmp ebx, ecx
            jg bot_left
            mov eax, 1
            jmp collided
      bot_left:                                                   ;Refer to comments for top_left (Line 226)
            mov ebx, two_bot_leftX
            mov ecx, one_upp_leftX
            cmp ebx, ecx
            jl bot_right  
            mov ebx, two_bot_leftX
            mov ecx, one_upp_rightX
            cmp ebx, ecx
            jg bot_right
            mov ebx, two_bot_leftY
            mov ecx, one_upp_leftY
            cmp ebx, ecx
            jl bot_right
            mov ebx, two_bot_leftY
            mov ecx, one_bot_leftY
            cmp ebx, ecx
            jg bot_right
            mov eax, 1
            jmp collided
      bot_right:                                                  ;Refer to comments for top_left (Line 256)
            mov ebx, two_bot_rightX
            mov ecx, one_upp_leftX
            cmp ebx, ecx
            jl othercollision
            mov ebx, two_bot_rightX
            mov ecx, one_upp_rightX
            cmp ebx, ecx
            jg othercollision
            mov ebx, two_bot_rightY
            mov ecx, one_upp_leftY
            cmp ebx, ecx
            jl othercollision
            mov ebx, two_bot_rightY
            mov ecx, one_bot_leftY
            cmp ebx, ecx
            jg othercollision
            mov eax, 1
            jmp collided


      othercollision:                                             
     ;top_left2                                                   ;Check if "one"'s corners are inside "two"
            xor eax, eax

            mov ebx, one_upp_leftX
            mov ecx, two_upp_leftX
            cmp ebx, ecx
            jl top_right2                                         ;if ebx < ecx, this corner is outside "one"'s LEFT edge. Move onto next corner
            mov ebx, one_upp_leftX                                ;if ebx > ecx, check "two"'s next edge
            mov ecx, two_upp_rightX
            cmp ebx, ecx
            jg top_right2                                         ;if ebx > ecx, this corner is outside "one"'s RIGHT edge. Move onto next corner
            mov ebx, one_upp_leftY                                ;if ebx < ecx, check "two"'s next edge
            mov ecx, two_upp_leftY
            cmp ebx, ecx
            jl top_right2                                         ;if ebx < ecx, this corner is outside "one"'s TOP edge. Move onto next corner
            mov ebx, one_upp_leftY                                ;if ebx > ecx, check "two"'s next edge
            mov ecx, two_bot_leftY
            cmp ebx, ecx
            jg top_right2                                         ;if ebx > ecx, this corner is outside "one"'s BOTTOM edge. Move onto next corner
            mov eax, 1                                            ;if ebx < ecx, COLLISION. Set eax=1
            jmp collided
      top_right2:                                                 ;Refer to comments for top_left2 (Line 306)
            mov ebx, one_upp_rightX
            mov ecx, two_upp_leftX
            cmp ebx, ecx
            jl bot_left2
            mov ebx, one_upp_rightX
            mov ecx, two_upp_rightX
            cmp ebx, ecx
            jg bot_left2
            mov ebx, one_upp_rightY
            mov ecx, two_upp_leftY
            cmp ebx, ecx
            jl bot_left2
            mov ebx, one_upp_rightY
            mov ecx, two_bot_leftY
            cmp ebx, ecx
            jg bot_left2
            mov eax, 1
            jmp collided
      bot_left2:                                                  ;Refer to comments for top_left2 (Line 306)
            mov ebx, one_bot_leftX
            mov ecx, two_upp_leftX
            cmp ebx, ecx
            jl bot_right2  
            mov ebx, one_bot_leftX
            mov ecx, two_upp_rightX
            cmp ebx, ecx
            jg bot_right2
            mov ebx, one_bot_leftY
            mov ecx, two_upp_leftY
            cmp ebx, ecx
            jl bot_right2
            mov ebx, one_bot_leftY
            mov ecx, two_bot_leftY
            cmp ebx, ecx
            jg bot_right2
            mov eax, 1
            jmp collided
      bot_right2:                                                 ;Refer to comments for top_left2 (Line 306)
            mov ebx, one_bot_rightX
            mov ecx, two_upp_leftX
            cmp ebx, ecx
            jl nocollision
            mov ebx, one_bot_rightX
            mov ecx, two_upp_rightX
            cmp ebx, ecx
            jg nocollision
            mov ebx, one_bot_rightY
            mov ecx, two_upp_leftY
            cmp ebx, ecx
            jl nocollision
            mov ebx, one_bot_rightY
            mov ecx, two_bot_leftY
            cmp ebx, ecx
            jg nocollision
            mov eax, 1
            jmp collided
      ;;;;;;;;;;;;;;;;;
      nocollision:                                                ;nocollison : set eax to 0 and leave :)
      mov eax, 0
      collided:



    ret
CheckIntersect ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Handle editing for each projectile ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
projectile_pattern1 PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel1 + 8*ecx]
            mov esi, [pattern1_vel1 + 8*ecx + 4]


            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
projectile_pattern1 ENDP
;;;;;
projectile_pattern1_2 PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel2 + 8*ecx]
            mov esi, [pattern1_vel2 + 8*ecx + 4]

            add ecx, 15
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
projectile_pattern1_2 ENDP
;;;;;
;;;;;
two_projectile_pattern1 PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel1 + 8*ecx]
            mov esi, [pattern1_vel1 + 8*ecx + 4]


            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_2
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
two_projectile_pattern1 ENDP
;;;;;
two_projectile_pattern1_2 PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel2 + 8*ecx]
            mov esi, [pattern1_vel2 + 8*ecx + 4]

            add ecx, 15
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_2
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
two_projectile_pattern1_2 ENDP
;;;;;
;;;;;
three_projectile_pattern1 PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel1 + 8*ecx]
            mov esi, [pattern1_vel1 + 8*ecx + 4]


            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_3
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
three_projectile_pattern1 ENDP
;;;;;
three_projectile_pattern1_2 PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel2 + 8*ecx]
            mov esi, [pattern1_vel2 + 8*ecx + 4]

            add ecx, 15
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_3
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
three_projectile_pattern1_2 ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Set 2 for editing Projectiles;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
projectile_pattern1_mirror PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel1 + 8*ecx]
            mov esi, [pattern1_vel1 + 8*ecx + 4]


            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_mirror
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
projectile_pattern1_mirror ENDP
;;;;;
projectile_pattern1_2_mirror PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel2 + 8*ecx]
            mov esi, [pattern1_vel2 + 8*ecx + 4]

            add ecx, 15
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_mirror
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
projectile_pattern1_2_mirror ENDP
;;;;;
;;;;;
two_projectile_pattern1_mirror PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel1 + 8*ecx]
            mov esi, [pattern1_vel1 + 8*ecx + 4]


            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_2_mirror
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
two_projectile_pattern1_mirror ENDP
;;;;;
two_projectile_pattern1_2_mirror PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel2 + 8*ecx]
            mov esi, [pattern1_vel2 + 8*ecx + 4]

            add ecx, 15
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_2_mirror
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
two_projectile_pattern1_2_mirror ENDP
;;;;;
;;;;;
three_projectile_pattern1_mirror PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel1 + 8*ecx]
            mov esi, [pattern1_vel1 + 8*ecx + 4]


            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_3_mirror
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
three_projectile_pattern1_mirror ENDP
;;;;;
three_projectile_pattern1_2_mirror PROC count:DWORD, deltax:DWORD, deltay:DWORD
      LOCAL loopcounter:DWORD
      mov edi, count                                     ;edi = count = number of elements

      mov loopcounter, 0                                 ;This is the increment we will be using
      ; mov eax, deltax
      ; mov esi, deltay
      ;; for (ebx = 0 : ebx < count, ++ebx)
      ;;    ecx will contain starting address of next struct in the array. Modify its position directly
      jmp cond
      body:
            ;; Get the right velocity vectors as (eax, esi)
            ; x component of current projectile
            mov ecx, loopcounter
            mov eax, [pattern1_vel2 + 8*ecx]
            mov esi, [pattern1_vel2 + 8*ecx + 4]

            add ecx, 15
            imul ecx, SIZEOF projectiles
            add ecx, OFFSET projectiles_arr_3_mirror
            add (projectiles PTR [ecx]).x, eax
            add (projectiles PTR [ecx]).y, esi
            inc loopcounter
      cond:
            cmp loopcounter, edi
            jl body
            
            ret
three_projectile_pattern1_2_mirror ENDP
;;;;;
;;;;;
;;;;;
;;;;;
;;;;;
; "Use Arrow keys to move
; Dodge the projectiles. Don't die. Kill the boss"
; "Press z to begin"
; Once player presses "z", change titlescreen struct element to 0. 
GamePlay PROC
      ;;;;;
      TitleScreen:
            cmp statuses_struct.titlescreen, 1
            jne begingame
            invoke BasicBlit, OFFSET simoneBackground, 320, 240         ;Draw the titlescreen background (simoneBackground)
            ;Check if user is starting the game
            mov edi, KeyPress                                           ;edi = current value of KeyPress
            mov esi, 5Ah                                                ;esi = value of key to start the game
            cmp edi, esi                                                ;Compare edi and esi
            jne continuetitlescreen                                     ;If not equal, keep displaying the title screen
            ;IF THE USER DOES PRESS THE KEY TO START THE GAME - change titlescreen struct element to 0
            mov ebx, OFFSET statuses_struct
            mov ecx, 0
            mov (statuses PTR [ebx]).titlescreen, 0                     ;User has started game. Move 0 into titlescreen struct element
            invoke PlaySound, offset ABeautifulSong, 0, SND_FILENAME OR SND_ASYNC         ;Play the music
            jmp continuetitlescreen                                     ;Skip to end. Don't start game unless titlescreen is 0!!!
      ;;;;;
 begingame:
      ;Check for game's pause status
      cmp statuses_struct.player_pause, 1                           
      je player_pause_on                                         ;if =1, then game is paused
      checkplayerlives:
            cmp statuses_struct.lives, 0
            jg checkbosslives
            invoke BasicBlit, OFFSET gameover, 320, 220
            jmp gameoverrr
      checkbosslives:
            cmp simoneboss_struct.lives, 0
            jne checkpause
            invoke BasicBlit, OFFSET victory, 320, 220
            jmp gameoverrr
            
      ;;;;;
      checkpause:
            mov edi, KeyPress                                     ;edi = KeyPress
            mov esi, 50h                                          ;esi = 50h = P key
            cmp edi, esi
            jne checkarrows
            mov statuses_struct.player_pause, 1
      ;;;;;
      checkarrows:
            ;;;;; Moving the user's Character 2B - Arrow Keys
            key_left:                                             ;How checking keys works
                  mov edi, KeyPress                               ;edi = current value of KeyPress (contains which key is being pressed)
                  mov esi, 25h                                    ;esi = key were are checking for (here, it is Left Arrow)
                  cmp edi, esi                                    ;Compare edi and esi
                  jne key_right                                   ;If not equal, left arrow not being pressed. Move onto check other keys
                  mov ebx, OFFSET twoB_struct                     ;If equal, left arrow is being pressed.
                  mov ecx, (Sprites PTR[ebx]).x                   ;ecx = current xpos
                  sub ecx, 4                                     ;Decrease it by 7
                  mov (Sprites PTR [ebx]).x, ecx                  ;Put new xpos back in

                  ;;; Animate 2B
                  ;;; if aniframe = 1, make it 0 and draw up2
                  cmp statuses_struct.aniframe, 0
                  je frame1_left
                  ;;; aniframe is 1, make it 0 and jump to draw to draw frame 2. Next time, frame 1 will be drawn
                  mov statuses_struct.aniframe, 0
                  jmp changeframe_left
                  frame1_left: 
                  mov statuses_struct.aniframe, 1
                  changeframe_left:
                  ;;; Now draw frame 1. aniframe is now 1, so next time, frame 2 will be drawn. 
                  mov esi, statuses_struct.aniframe
                  mov esi, DWORD PTR [twoB_left + 4*esi]
                  mov (Sprites PTR [ebx]).bitmap, esi
            ;;;;;
            key_right:                                            ;Refer to comments for key_left (Line 400)
                  mov esi, 27h
                  cmp edi, esi
                  jne key_up
                  mov ebx, OFFSET twoB_struct
                  mov ecx, (Sprites PTR[ebx]).x
                  add ecx, 4
                  mov (Sprites PTR [ebx]).x, ecx 

                  ;;; Animate 2B
                  ;;; if aniframe = 1, make it 0 and draw up2
                  cmp statuses_struct.aniframe, 0
                  je frame1_right
                  ;;; aniframe is 1, make it 0 and jump to draw to draw frame 2. Next time, frame 1 will be drawn
                  mov statuses_struct.aniframe, 0
                  jmp changeframe_right
                  frame1_right: 
                  mov statuses_struct.aniframe, 1
                  changeframe_right:
                  ;;; Now draw frame 1. aniframe is now 1, so next time, frame 2 will be drawn. 
                  mov esi, statuses_struct.aniframe
                  mov esi, DWORD PTR [twoB_right + 4*esi]
                  mov (Sprites PTR [ebx]).bitmap, esi     
            ;;;;;
            key_up:                                               ;Refer to comments for key_left (Line 400)
                  mov esi, 26h
                  cmp edi, esi
                  jne key_down
                  mov ebx, OFFSET twoB_struct
                  mov ecx, (Sprites PTR[ebx]).y
                  sub ecx, 4
                  mov (Sprites PTR [ebx]).y, ecx

                  ;;; Animate 2B
                  ;;; if aniframe = 1, make it 0 and draw up2
                  cmp statuses_struct.aniframe, 0
                  je frame1_up
                  ;;; aniframe is 1, make it 0 and jump to draw to draw frame 2. Next time, frame 1 will be drawn
                  mov statuses_struct.aniframe, 0
                  jmp changeframe_up
                  frame1_up: 
                  mov statuses_struct.aniframe, 1
                  changeframe_up:
                  ;;; Now draw frame 1. aniframe is now 1, so next time, frame 2 will be drawn. 
                  mov esi, statuses_struct.aniframe
                  mov esi, DWORD PTR [twoB_up + 4*esi]
                  mov (Sprites PTR [ebx]).bitmap, esi
            ;;;;;
            key_down:                                             ;Refer to comments for key_left (Line 400)
                  mov esi, 28h
                  cmp edi, esi
                  jne spacebar
                  mov ebx, OFFSET twoB_struct
                  mov ecx, (Sprites PTR[ebx]).y
                  add ecx, 4
                  mov (Sprites PTR [ebx]).y, ecx

                  ;;; Animate 2B
                  ;;; if aniframe = 1, make it 0 and draw up2
                  cmp statuses_struct.aniframe, 0
                  je frame1_down
                  ;;; aniframe is 1, make it 0 and jump to draw to draw frame 2. Next time, frame 1 will be drawn
                  mov statuses_struct.aniframe, 0
                  jmp changeframe_down
                  frame1_down: 
                  mov statuses_struct.aniframe, 1
                  changeframe_down:
                  ;;; Now draw frame 1. aniframe is now 1, so next time, frame 2 will be drawn. 
                  mov esi, statuses_struct.aniframe
                  mov esi, DWORD PTR [twoB_down + 4*esi]
                  mov (Sprites PTR [ebx]).bitmap, esi
            spacebar:
                  mov esi, 20h
                  cmp edi, esi
                  jne screenupdate
                  mov ecx, twoB_struct.x
                  mov edx, twoB_struct.y
                  mov bullet1.x, ecx
                  mov bullet1.y, edx

            ;;;;;
            ;;;;;
            ; checkmouse:
            ;       ;;;;; Moving the Plane - Left Mouse Click
            ;       mouse_left:
            ;             mov edi, MouseStatus.buttons                    ;edi = which mouse button is being clicked
            ;             mov esi, 0001h                                  ;esi = value for left click
            ;             cmp edi, esi                                    ;compare edi and esi
            ;             jne mouse_right                                 ;if not equal, not clicking left. Check right click
            ;             mov ebx, OFFSET plane_struct                    ;if equal, left is being clicked. Do all this stuff
            ;             mov ecx, MouseStatus.x                          ;ecx = xpos of mouse
            ;             mov edx, MouseStatus.y                          ;edx = ypos of mouse
            ;             mov (Sprites PTR [ebx]).x, ecx                  ;Move current xpos of mouse into Plane's struct                                             
            ;             mov (Sprites PTR [ebx]).y, edx                  ;Move current ypos of mouse into Plane's struct
            ;       mouse_right:
            ;             mov esi, 0002h
                  ;;;;;
      ;;;;;
      screenupdate:
            ;;;;; UPDATE THE SCREEN
            invoke BasicBlit, OFFSET arena, 320, 220          
            invoke BasicBlit, twoB_struct.bitmap, twoB_struct.x, twoB_struct.y             ;Redraw twoB's new position
            ;mov ebx, OFFSET simoneboss_struct                                           
            ;mov (Sprites PTR [ebx]).x, 300
            ;mov (Sprites PTR [ebx]).y, 300
            invoke BasicBlit, OFFSET simoneboss, simoneboss_struct.x, simoneboss_struct.y       ;Draw final boss simoneboss. This is in GamePlay because eventually it will move on its own
            invoke BasicBlit, OFFSET turret, simoneboss_turret_1.x, simoneboss_turret_1.y
            invoke BasicBlit, OFFSET turret, simoneboss_turret_2.x, simoneboss_turret_2.y
            ;Draw the bullet
            sub bullet1.y, 6
            mov ebx, bullet1.x
            mov ecx, bullet1.y
            invoke BasicBlit, OFFSET bullet, bullet1.x, bullet1.y
            ; invoke BasicBlit, OFFSET Plane, plane_struct.x, plane_struct.y                      ;Draw the Plane
            life_hearts:
                  cmp statuses_struct.lives, 3
                  jne two_hearts
                  invoke BasicBlit, OFFSET heart3, 35, 13
                  jmp boss_health
                  two_hearts:
                  cmp statuses_struct.lives, 2
                  jne one_heart
                  invoke BasicBlit, OFFSET heart2, 24, 13
                  jmp boss_health
                  one_heart:
                  cmp statuses_struct.lives, 1
                  jne gameoverrr
                  invoke BasicBlit, OFFSET heart1, 15, 14
                  jmp boss_health
            boss_health:
                  cmp simoneboss_struct.lives, 0
                  je gameoverrr
                  mov ebx, simoneboss_struct.lives
                  dec ebx
                  imul ebx, 4
                  mov ecx, [bosshealth_arr + ebx]
                  invoke BasicBlit, ecx, 320, 8

      ;;;;; 
      boss_projectiles:                         ;Initialiezs, draws, and checks collisions for projectiles
            ; For loop used to draw all projectiles
            ; xor ebx, ebx                                                 ;Counter
            ; jmp draw_proj_cond
            ; draw_proj_body:
            ;       mov esi, OFFSET projectiles_arr
            ;       mov ecx, ebx
            ;       imul ecx, SIZEOF projectiles
            ;       add esi, ecx
            ;       invoke BasicBlit, OFFSET projectile, (projectiles PTR [esi]).x, (projectiles PTR [esi]).y
            ;       inc ebx
            ; draw_proj_cond:
            ;       cmp ebx, 3
            ;       jl draw_proj_body

            ;;; Tried making the "For" loop above but it just wouldn't run.... so here is hard-coded mostly done with "fine-and-replace"
            
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Bullets from the Boss;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            firstset:
                  projectile_1:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_2
                  ;Draw the projectile
                  mov ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_2
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_2:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_3
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_3
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num
                  
                  projectile_3:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_4
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_4
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num
                  
                  projectile_4:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_5
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_5
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_5:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_6
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_6
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_6:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_7
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_7
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_7:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_8
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_8
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_8:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_9
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_9
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_9:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_10
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_10
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_10:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_11
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_11
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_11:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_12
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_12
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_12:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_13
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_13
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_13:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_14
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_14
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_14:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_15
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_15
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_15:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_16
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_16
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_16:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_17
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_17
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_17:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_18
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_18
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_18:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_19
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_19
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_19:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_20
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_20
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_20:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_21
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_21
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num

                  projectile_21:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_22
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_22
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num        

                  projectile_22:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_23
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_23
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num    

                  projectile_23:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_24
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_24
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num    

                  projectile_24:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_25
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_25
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num    

                  projectile_25:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_26
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_26
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num    

                  projectile_26:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_27
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_27
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num    

                  projectile_27:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_28
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_28
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num    

                  projectile_28:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_29
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_29
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num    

                  projectile_29:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_30
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_30
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num    

                  projectile_30:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_31
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_31
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num  

                  projectile_31:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_32
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_32
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num 

                  projectile_32:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_33
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_33
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num 

                  projectile_33:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_34
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_34
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num 

                  projectile_34:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne projectile_35
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je projectile_35
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num 

                  projectile_35:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_1
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_1
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr
                  dec (projectiles PTR [ebx]).num 
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Bullets from Turret 1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            secondset:
                  two_projectile_1:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_2
                  ;Draw the projectile
                  mov ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_2
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_2:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_3
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_3
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
                  
                  two_projectile_3:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_4
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_4
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
                  
                  two_projectile_4:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_5
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_5
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_5:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_6
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_6
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_6:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_7
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_7
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_7:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_8
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_8
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_8:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_9
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_9
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_9:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_10
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_10
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_10:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_11
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_11
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_11:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_12
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_12
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_12:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_13
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_13
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_13:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_14
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_14
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_14:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_15
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_15
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_15:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_16
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_16
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_16:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_17
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_17
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_17:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_18
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_18
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_18:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_19
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_19
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_19:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_20
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_20
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_20:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_21
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_21
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_21:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_22
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_22
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num        
 
                  two_projectile_22:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_23
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_23
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num    
 
                  two_projectile_23:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_24
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_24
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num    
 
                  two_projectile_24:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_25
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_25
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num    
 
                  two_projectile_25:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_26
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_26
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num    
 
                  two_projectile_26:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_27
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_27
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num    
 
                  two_projectile_27:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_28
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_28
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num    
 
                  two_projectile_28:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_29
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_29
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num    
 
                  two_projectile_29:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_30
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_30
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num    
 
                  two_projectile_30:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_31
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_31
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num  
 
                  two_projectile_31:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_32
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_32
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_32:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_33
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_33
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_33:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_34
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_34
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_34:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne two_projectile_35
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je two_projectile_35
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
 
                  two_projectile_35:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr_2
                  cmp (projectiles PTR [ebx]).num, 1
                  jne thirdset
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr_2
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr_2
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je thirdset
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr_2
                  dec (projectiles PTR [ebx]).num
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Bullets from Turret 2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            thirdset:
                  three_projectile_1:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_2
                  ;Draw the projectile
                  mov ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_2
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_2:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_3
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_3
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 1
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
                  
                  three_projectile_3:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_4
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_4
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 2
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
                  
                  three_projectile_4:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_5
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_5
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 3
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_5:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_6
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_6
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 4
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_6:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_7
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_7
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 5
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_7:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_8
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_8
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 6
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_8:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_9
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_9
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 7
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_9:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_10
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_10
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 8
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_10:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_11
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_11
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 9
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_11:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_12
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_12
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 10
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_12:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_13
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_13
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 11
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_13:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_14
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_14
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 12
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_14:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_15
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_15
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 13
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_15:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_16
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_16
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 14
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_16:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_17
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_17
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 15
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_17:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_18
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_18
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 16
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_18:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_19
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_19
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 17
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_19:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_20
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_20
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 18
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_20:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_21
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_21
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 19
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_21:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_22
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_22
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 20
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num        
 
                  three_projectile_22:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_23
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_23
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 21
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num    
 
                  three_projectile_23:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_24
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_24
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 22
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num    
 
                  three_projectile_24:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_25
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_25
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 23
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num    
 
                  three_projectile_25:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_26
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_26
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 24
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num    
 
                  three_projectile_26:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_27
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_27
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 25
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num    
 
                  three_projectile_27:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_28
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_28
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 26
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num    
 
                  three_projectile_28:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_29
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_29
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 27
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num    
 
                  three_projectile_29:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_30
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_30
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 28
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num    
 
                  three_projectile_30:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_31
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_31
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 29
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num  
 
                  three_projectile_31:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_32
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_32
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 30
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_32:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_33
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_33
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 31
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_33:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_34
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_34
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 32
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_34:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne three_projectile_35
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je three_projectile_35
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 33
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
 
                  three_projectile_35:
                  ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr_3
                  cmp (projectiles PTR [ebx]).num, 1
                  jne mirror_set
                  ;Draw the projectile
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr_3
                  invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                  ;Check Intersect
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr_3
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                  cmp eax, 0
                  je mirror_set
                  ;What to do when collision occurs
                  dec statuses_struct.lives
                  mov ebx, SIZEOF projectiles
                  imul ebx, 34
                  add ebx, OFFSET projectiles_arr_3
                  dec (projectiles PTR [ebx]).num
            ;;;;;;
            ;;;;;; Do the second set of projectiles
            ;;;;;;
            ; This sets an offset for the second set.
            mirror_set:
            cmp pattern1_timer_mirror, 100
            jl fffiretrails
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Bullets from the Boss;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            firstset_mirror:
                 projectile_mirror_1:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_2
                 ;Draw the projectile
                 mov ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_2
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_2:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_3
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_3
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
                
                 projectile_mirror_3:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_4
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_4
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
                
                 projectile_mirror_4:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_5
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_5
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_5:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_6
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_6
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_6:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_7
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_7
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_7:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_8
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_8
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_8:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_9
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_9
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_9:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_10
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_10
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_10:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_11
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_11
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_11:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_12
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_12
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_12:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_13
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_13
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_13:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_14
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_14
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_14:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_15
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_15
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_15:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_16
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_16
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_16:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_17
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_17
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_17:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_18
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_18
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_18:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_19
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_19
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_19:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_20
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_20
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_20:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_21
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_21
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_21:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_22
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_22
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num       
 
                 projectile_mirror_22:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_23
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_23
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num   
 
                 projectile_mirror_23:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_24
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_24
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num   
 
                 projectile_mirror_24:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_25
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_25
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num   
 
                 projectile_mirror_25:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_26
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_26
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num   
 
                 projectile_mirror_26:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_27
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_27
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num   
 
                 projectile_mirror_27:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_28
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_28
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num   
 
                 projectile_mirror_28:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_29
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_29
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num   
 
                 projectile_mirror_29:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_30
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_30
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num   
 
                 projectile_mirror_30:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_31
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_31
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num 
 
                 projectile_mirror_31:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_32
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_32
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_32:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_33
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_33
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_33:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_34
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_34
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_34:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne projectile_mirror_35
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je projectile_mirror_35
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num
 
                 projectile_mirror_35:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne secondset_mirror
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je secondset_mirror
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_mirror
                 dec (projectiles PTR [ebx]).num

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Bullets from Turret 1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            secondset_mirror:
                 two_projectile_mirror_1:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_2
                 ;Draw the projectile
                 mov ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_2
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_2:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_3
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_3
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                
                 two_projectile_mirror_3:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_4
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_4
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                
                 two_projectile_mirror_4:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_5
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_5
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_5:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_6
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_6
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_6:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_7
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_7
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_7:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_8
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_8
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_8:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_9
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_9
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_9:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_10
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_10
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_10:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_11
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_11
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_11:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_12
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_12
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_12:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_13
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_13
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_13:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_14
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_14
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_14:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_15
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_15
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_15:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_16
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_16
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_16:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_17
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_17
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_17:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_18
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_18
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_18:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_19
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_19
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_19:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_20
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_20
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_20:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_21
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_21
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_21:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_22
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_22
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num       
                 two_projectile_mirror_22:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_23
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_23
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num   
                 two_projectile_mirror_23:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_24
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_24
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num   
                 two_projectile_mirror_24:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_25
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_25
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num   
                 two_projectile_mirror_25:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_26
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_26
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num   
                 two_projectile_mirror_26:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_27
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_27
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num   
                 two_projectile_mirror_27:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_28
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_28
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num   
                 two_projectile_mirror_28:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_29
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_29
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num   
                 two_projectile_mirror_29:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_30
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_30
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num   
                 two_projectile_mirror_30:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_31
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_31
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num 
                 two_projectile_mirror_31:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_32
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_32
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_32:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_33
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_33
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_33:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_34
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_34
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_34:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne two_projectile_mirror_35
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je two_projectile_mirror_35
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num
                 two_projectile_mirror_35:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_2_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne thirdset_mirror
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_2_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je thirdset_mirror
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_2_mirror
                 dec (projectiles PTR [ebx]).num

            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Bullets from Turret 2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            thirdset_mirror:
                 three_projectile_mirror_1:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_2
                 ;Draw the projectile
                 mov ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_2
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_2:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_3
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_3
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 1
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                
                 three_projectile_mirror_3:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_4
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_4
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 2
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                
                 three_projectile_mirror_4:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_5
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_5
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 3
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_5:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_6
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_6
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 4
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_6:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_7
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_7
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 5
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_7:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_8
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_8
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 6
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_8:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_9
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_9
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 7
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_9:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_10
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_10
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 8
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_10:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_11
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_11
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 9
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_11:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_12
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_12
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 10
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_12:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_13
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_13
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 11
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_13:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_14
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_14
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 12
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_14:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_15
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_15
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 13
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_15:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_16
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_16
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 14
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_16:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_17
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_17
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 15
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_17:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_18
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_18
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 16
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_18:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_19
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_19
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 17
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_19:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_20
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_20
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 18
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_20:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_21
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_21
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 19
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_21:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_22
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_22
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 20
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num       
                 three_projectile_mirror_22:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_23
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_23
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 21
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num   
                 three_projectile_mirror_23:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_24
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_24
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 22
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num   
                 three_projectile_mirror_24:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_25
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_25
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 23
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num   
                 three_projectile_mirror_25:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_26
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_26
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 24
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num   
                 three_projectile_mirror_26:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_27
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_27
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 25
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num   
                 three_projectile_mirror_27:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_28
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_28
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 26
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num   
                 three_projectile_mirror_28:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_29
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_29
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 27
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num   
                 three_projectile_mirror_29:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_30
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_30
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 28
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num   
                 three_projectile_mirror_30:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_31
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_31
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 29
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num 
                 three_projectile_mirror_31:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_32
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_32
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 30
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_32:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_33
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_33
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 31
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_33:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_34
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_34
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 32
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_34:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne three_projectile_mirror_35
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je three_projectile_mirror_35
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 33
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
                 three_projectile_mirror_35:
                 ;Check if projectile is "alive". If equals 0, skip this projectile and move to next one.
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_3_mirror
                 cmp (projectiles PTR [ebx]).num, 1
                 jne fffiretrails
                 ;Draw the projectile
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke BasicBlit, OFFSET projectile, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y
                 ;Check Intersect
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_3_mirror
                 invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [ebx]).x, (projectiles PTR [ebx]).y, OFFSET projectile
                 cmp eax, 0
                 je fffiretrails
                 ;What to do when collision occurs
                 dec statuses_struct.lives
                 mov ebx, SIZEOF projectiles
                 imul ebx, 34
                 add ebx, OFFSET projectiles_arr_3_mirror
                 dec (projectiles PTR [ebx]).num
            ;;;;;;
            ;;;;;;
            ;;;;;;
            fffiretrails:
                  fffiretrail1:
                        cmp firetrail1.num, 1
                        jne fffiretrail2

                        invoke BasicBlit, OFFSET fire, firetrail1.x, firetrail1.y
                        cmp firetrail1.targetx, 0
                        jne goleft1
                        add firetrail1.x, 10
                        cmp firetrail1.x, 640
                        jl fffiretrail2
                        jmp setleft1
                        setleft1:
                              mov firetrail1.targetx, 1
                              jmp fffiretrail2
                        setright1:
                              mov firetrail1.targetx, 0
                              jmp fffiretrail2
                        goleft1:
                              sub firetrail1.x, 10
                              cmp firetrail1.x, 0
                              jng setright1

                  

                  fffiretrail2:
                        cmp firetrail2.num, 1
                        jne fffiretrail3

                        invoke BasicBlit, OFFSET fire, firetrail2.x, firetrail2.y
                        cmp firetrail2.targetx, 0
                        jne goleft2
                        add firetrail2.x, 10
                        cmp firetrail2.x, 640
                        jl fffiretrail3
                        jmp setleft2
                        setleft2:
                              mov firetrail2.targetx, 1
                              jmp fffiretrail3
                        setright2:
                              mov firetrail2.targetx, 0
                              jmp fffiretrail3
                        goleft2:
                              sub firetrail2.x, 10
                              cmp firetrail2.x, 0
                              jng setright2

                  fffiretrail3:
                        cmp firetrail3.num, 1
                        jne fffiretrail4

                        invoke BasicBlit, OFFSET fire, firetrail3.x, firetrail3.y
                        cmp firetrail3.targetx, 0
                        jne goleft3
                        add firetrail3.x, 10
                        cmp firetrail3.x, 640
                        jl fffiretrail4
                        jmp setleft3
                        setleft3:
                              mov firetrail3.targetx, 1
                              jmp fffiretrail4
                        setright3:
                              mov firetrail3.targetx, 0
                              jmp fffiretrail4
                        goleft3:
                              sub firetrail3.x, 10
                              cmp firetrail3.x, 0
                              jng setright3

                  fffiretrail4:
                        cmp firetrail4.num, 1
                        jne fffiretrail5

                        invoke BasicBlit, OFFSET fire, firetrail4.x, firetrail4.y
                        cmp firetrail4.targetx, 0
                        jne goleft4
                        add firetrail4.x, 10
                        cmp firetrail4.x, 640
                        jl fffiretrail5
                        jmp setleft4
                        setleft4:
                              mov firetrail4.targetx, 1
                              jmp fffiretrail5
                        setright4:
                              mov firetrail4.targetx, 0
                              jmp fffiretrail5
                        goleft4:
                              sub firetrail4.x, 10
                              cmp firetrail4.x, 0
                              jng setright4

                  fffiretrail5:
                        cmp firetrail5.num, 1
                        jne firecollisions

                        invoke BasicBlit, OFFSET fire, firetrail5.x, firetrail5.y
                        cmp firetrail5.targetx, 0
                        jne goleft5
                        add firetrail5.x, 10
                        cmp firetrail5.x, 640
                        jl firecollisions
                        jmp setleft5
                        setleft5:
                              mov firetrail5.targetx, 1
                              jmp projectiles_done
                        setright5:
                              mov firetrail5.targetx, 0
                              jmp projectiles_done
                        goleft5:
                              sub firetrail5.x, 10
                              cmp firetrail5.x, 0
                              jng setright5


                  firecollisions:

                        firecollision1:
                        cmp firetrail1.num, 1
                        jne firecollision2
                        invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, firetrail1.x, firetrail1.y, OFFSET fire
                        cmp eax, 0
                        je firecollision2
                        dec statuses_struct.lives
                        dec firetrail1.num

                        firecollision2:
                        cmp firetrail2.num, 1
                        jne firecollision3
                        invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, firetrail2.x, firetrail2.y, OFFSET fire
                        cmp eax, 0
                        je firecollision3
                        dec statuses_struct.lives
                        dec firetrail2.num

                        firecollision3:
                        cmp firetrail3.num, 1
                        jne firecollision4
                        invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, firetrail3.x, firetrail3.y, OFFSET fire
                        cmp eax, 0
                        je firecollision4
                        dec statuses_struct.lives
                        dec firetrail3.num

                        firecollision4:
                        cmp firetrail4.num, 1
                        jne firecollision5
                        invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, firetrail4.x, firetrail4.y, OFFSET fire
                        cmp eax, 0
                        je firecollision5
                        dec statuses_struct.lives
                        dec firetrail4.num

                        firecollision5:
                        cmp firetrail5.num, 1
                        jne projectiles_done
                        invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, firetrail5.x, firetrail5.y, OFFSET fire
                        cmp eax, 0
                        je projectiles_done
                        dec statuses_struct.lives
                        dec firetrail5.num
            projectiles_done:
                  ;;; First Set Edit Projectiles
                  invoke projectile_pattern1, 15, 1, 1
                  invoke projectile_pattern1_2, 20, 1, 1
                  invoke two_projectile_pattern1, 15, 1, 1
                  invoke two_projectile_pattern1_2, 20, 1, 1
                  invoke three_projectile_pattern1, 15, 1, 1
                  invoke three_projectile_pattern1_2, 20, 1, 1
                  ;;; Second Set Edit Projectiles
                  invoke projectile_pattern1_mirror, 15, 1, 1
                  invoke projectile_pattern1_2_mirror, 20, 1, 1
                  invoke two_projectile_pattern1_mirror, 15, 1, 1
                  invoke two_projectile_pattern1_2_mirror, 20, 1, 1
                  invoke three_projectile_pattern1_mirror, 15, 1, 1
                  invoke three_projectile_pattern1_2_mirror, 20, 1, 1
                  ;;;;;;;;;;;;; Handle Attack Timers
                  ;;;;;; First set
                  inc pattern1_timer
                  mov ebx, pattern1_timer
                  cmp ebx, 260
                  jle attacktimers_secondset
                  ;If timer is reached, reset projectile Arrays
                  mov pattern1_timer, 0
                  invoke init_projectiles, 35
                  invoke init_projectiles_2, 35
                  invoke init_projectiles_3, 35
                  ;;;;;;; Second Set
                  attacktimers_secondset:
                  inc pattern1_timer_mirror
                  mov ebx, pattern1_timer_mirror
                  cmp ebx, 375
                  jle checkcollision
                  ;If timer is reached, reset projectile Arrays
                  mov pattern1_timer_mirror, 100
                  invoke init_projectiles_mirror, 35
                  invoke init_projectiles_2_mirror, 35
                  invoke init_projectiles_3_mirror, 35
      ;;;;;
      checkcollision:
            ;;;;; Check for collision between 2B and BOSS simoneboss
                  invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, simoneboss_struct.x, simoneboss_struct.y, OFFSET simoneboss
                  cmp eax, 0
                  je check_bullet_hit
                  invoke BasicBlit, OFFSET collisionMessage, 514, 143                     ;Draw the collision message only if eax = 1
            ;;; Check collision with 2B's bullet with Simone. If collided, remove 1hp from Simone and make bullet go away
            check_bullet_hit:
                  invoke CheckIntersect, bullet1.x, bullet1.y, OFFSET bullet, simoneboss_struct.x, simoneboss_struct.y, OFFSET simoneboss
                  cmp eax, 0
                  je nocollision
                  dec simoneboss_struct.lives
                  mov ebx, 1000
                  mov bullet1.x, ebx
                  mov bullet1.y, ebx
            ;;;;; Check for collision between 2B and a projectiles
      ; CheckProjectilebutDeleteThisLaterBecauseCollisionWillbeCheckedEarlierOnInProjectileSection:
      ;       mov esi, OFFSET projectiles_arr
      ;       invoke CheckIntersect, twoB_struct.x, twoB_struct.y, twoB_struct.bitmap, (projectiles PTR [esi]).x, (projectiles PTR [esi]).y, OFFSET projectile
      ;       cmp eax, 0
      ;       je nocollision
      ;       invoke BasicBlit, OFFSET collisionMessage, 514, 143
      nocollision:
      ;;;;;
      player_pause_on:
            ;;;; Add a line here that draws the pause screen
            mov edi, KeyPress
            mov esi, 4Fh
            cmp edi, esi
            jne continuetitlescreen                                           ;If player presses "O", unpause the game
            mov statuses_struct.player_pause, 0                               
      continuetitlescreen:
      gameoverrr:
	ret       ;; Do not delete this line!!!
GamePlay ENDP
;;;;;
END
