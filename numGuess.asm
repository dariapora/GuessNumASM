.model small                 ; Specificarea modelului de memorie 'small' - un segment de date, un segment de cod
.stack 100h                  ; Definirea marimii stivei (256 bytes)

.data

gStart db 13,10,'Pentru a incepe jocul, apasa tasta "Enter".$'
textPar db 13,10,13,10,'Ma gandesc la un numar par. Ai 10 incercari! $'
textImpar db 13,10,13,10,'Ma gandesc la un numar impar. Ai 10 incercari! $'
textIncercari db 13,10, 'Incercari ramase: $'
textNivel db 13,10,'Selecteaza nivelul: [1] Usor (0-64) [2] Mediu (0-128) [3] Greu (0-255) $'

textMic db 13,10,'Mai mic... $'
textMare db 13,10,'Mai mare... $'
textRestart db ' Vrei sa incerci din nou? [1] Da [2] Nu $'

gWin db 13,10,13,10,'Ai ghicit numarul!$'
gLose db 13,10,13,10,'Ai pierdut. Data viitoare e cu noroc!$'
gEnd db 13,10,'Jocul s-a terminat!$'

textScore1 db 13, 10, 'Streak-ul tau este de $'
textScore2 db ' runde. Bravo!$'

happyFace db 13, 10, 13, 10
       db '    *****    ', 13, 10
       db '  *       *  ', 13, 10
       db ' *  O   O  * ', 13, 10
       db ' *         * ', 13, 10
       db '  *  \_/  *  ', 13, 10
       db '    *****    ', 13, 10, '$'

mehFace db 13, 10, 13, 10
       db '    *****    ', 13, 10
       db '  *       *  ', 13, 10
       db ' *  O   O  * ', 13, 10
       db ' *         * ', 13, 10
       db '  *  ___  *  ', 13, 10
       db '    *****    ', 13, 10, '$'

zece db 10                   ; Folosit pentru conversia cifrelor din caractere
numInput db 6                ; Folosit pentru citirea numarului introdus de jucator       

.code

pStart:
    mov ax, @data            ; Initializarea segmentului de date
    mov ds, ax

    mov ax, 0
    mov es, ax               ; Initializarea contorului de win streak

    mov ah, 09h           
    mov dx, offset gStart    ; Afisarea mesajului de inceput
    int 21h

    mov ah, 01h            
    int 21h
    mov bl, 0Dh              ; Citirea unui caracter de la tastatura + verificare daca e 'Enter'
    cmp al, bl
    jz gameStart
    jmp gameEnd

gameStart:

    mov ah, 09h 
    mov dx, offset textNivel ; Afisarea mesajului de selectare nivel
    int 21h

    mov ah, 01h
    int 21h                  ; Primirea input-ului pentru nivel
    sub al, '0'              ; Conversia caracterului citit in cifra
    cmp al, 2                ; Verificarea nivelului introdus
    je lvlM
    jl lvlE 
    ja lvlG

resumeStart:
    mov di, 10               ; Initializarea contorului de incercari cu 10
    mov ah, 00h              
    int 1Ah                  ; Obtinerea timpului sistemului pentru numarul aleatoriu
    mov ax, dx       
    xor dx, dx         
    div cx                   ; Impartirea numarului pentru a restrange intervalul conform nivelului 
    push dx                  ; Salvarea numarului generat in stiva
    and dl, 1                ; Verificarea paritatii numarului generat
    jnz nrImpar
    
nrPar:

    mov ah, 09h
    mov dx, offset textPar
    int 21h
    jmp inputLoop

lvlM:

mov cx, 129
jmp resumeStart

lvlE:

mov cx, 65
jmp resumeStart

lvlG:

mov cx, 256
jmp resumeStart

nrImpar:

    mov ah, 09h
    mov dx, offset textImpar
    int 21h

inputLoop:

    mov ah, 0Ah
    mov dx, offset numInput
    int 21h                  ; Receptionarea input-ului de la utilizator (nr. ghicit)
    mov cl, [numInput+1]     ; Mutarea in CL a numarului de caractere pentru loop
    xor ch, ch               ; Curatarea lui CH (Astfel, CX va fi 00CL)
    mov si, offset numInput + 2
    xor ax, ax               ; Curatarea lui AX pentru conversie
    
convertLoop:

    mov bl, [si]             ; Preluarea caracterului curent din sir
    sub bl, '0'              ; Conversia din ASCII in valoare numerica
    mul byte ptr zece        ; Inmultirea valorii curente cu 10
    add al, bl               ; Adaugarea cifrei noi
    inc si                   ; Trecerea la urmatorul caracter
    loop convertLoop         ; Executarea loop-ului pana cand CX = 0000.

    mov bl, al               ; Mutarea numarului convertit in registrul BL
    pop dx                   ; Preluarea numarului generat de program de pe stiva 
    push dx                  ; Inserarea imediata inapoi in stiva pentru urmatoarea comparatie
    cmp bl, dl               ; Compararea numarului citit cu cel generat
    je gameWin          
    jb numBelow         
    jmp numAbove        

outputTries:

    mov ah, 09h
    mov dx, offset textIncercari
    int 21h
    mov dx, di               ; Pregatirea contorului de incercari (stocat in DI) penrtu a fi afisat
    add dl, '0'
    mov ah, 02h
    int 21h                  ; Afisarea contorului de incercari
    mov dl, ' '
    int 21h
jmp inputLoop

numAbove:

    dec di
    jz gameLose
    mov ah, 09h
    mov dx, offset textMic
    int 21h
    jmp outputTries

numBelow:

    dec di                   ; Verificarea contorului de incercari si compararea lui cu zero
    jz gameLose

    mov ah, 09h
    mov dx, offset textMare
    int 21h

    jmp outputTries

intermediate:
jmp gameStart                ; Salt intermediar -- eticheta gameStart este "out of range" pentru salt catre ea din gameEnd

gameWin:
    mov ah, 09h

    mov dx, offset gWin
    int 21h

    mov ah, 09h
    lea dx, happyFace
    int 21h

    mov ax, es              
    inc ax
    mov es, ax              ; Salvarea win streak-ului in segmentul ES
    mov ax, es
    cmp ax, 1
    jle gameEnd

    mov ah, 09h
    mov dx, offset textScore1
    int 21h

    mov ax, es
    mov ah, 02h             
    mov dl, al                    
    add dl, '0'
    int 21h                 ; Afisarea streak-ului

    mov ah, 09h
    mov dx, offset textScore2
    int 21h

    jmp gameEnd

gameLose:

    mov ah, 09h
    mov dx, offset gLose
    int 21h

    mov ah, 09h
    lea dx, mehFace
    int 21h

    mov ax, 0
    mov es, ax              ; Resetarea streak-ului

gameEnd:

    xor ax, ax
    mov ah, 09h
    mov dx, offset gEnd
    int 21h

    mov ah, 09h
    mov dx, offset textRestart
    int 21h

    mov ah, 01h
    int 21h

    sub al, '0'
    cmp al, 1              
    je intermediate        ; Daca utilizatorul vrea sa mai joace, salt catre gameStart
    mov ah, 4Ch
    int 21h                ; Terminarea programului

end pStart
