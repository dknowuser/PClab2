;Marchuk L.B. 5307
;Var 9
;The program outputs window in position (10, 10, 70, 20),
;then it outputs some text bottom-up using all possible combinations 
;of background color and foreground color.
;English name of background color 
;and number of foreground color are outputed. 
assume cs:CSEG, ss:Stk

Stk segment
    db 256 dup(?)
Stk ends

CSEG segment
    Begin:
    jmp actbegin;
    
    ;Names of colours
    black db    'Black      $'
    dkblue db   'Dark blue  $'
    dkgreen db  'Dark green $'
    dkcyan db   'Dark cyan  $'
    dkred db    'Dark red   $'
    dkpurple db 'Dark purple$'
    dkorange db 'Dark orange$'
    gray db     'Gray       $'        
    
    background db 'Background color: $' 
    foreground db 'Foreground color: $'
    
    Str1 db 'The other line moves faster. If you change lines, the one you just left will start to move faster than the one you are now in.      $'
    Str2 db 'I was going to do something today but I have not finished doing nothing from yesterday.                                             $'
    Str3 db 'Do not take your troubles to bed with you, hang them on a chair with your trousers or drop them in a glass of water with your teeth.$'
    
    actbegin:
    ;Move the window
    
    ;Choose text mode
    mov al, 03h;
    int 10h; 
    
    ;Value of symbol attributes is from 00 to FF
    mov cx, 0h;
    
    ;Trying to calculate required string using bx
    mov bx, 0h;
    
    mainloop:
    cmp cx, 0100h;
    jnz continuew;
    
    quit:
    mov dl,10h;
    mov dh, 50h;
    mov ah, 02h;
    int 10h;
    
    scroll:
    ;Read keyboard input
    mov ah, 00h;
    int 16h;
    
    ;if w has been pressed al = 77, move the image down
    cmp al, 77h;
    jne S;
    
    mov ah, 07h;
    mov al, 01h;
    mov bh, 00h;
    mov ch, 0Ah;
    mov cl, 0Ah;
    mov dh, 14h;
    mov dl, 46h;
    int 10h;
    
    jmp scroll;
    ;if s has been pressed al = 73, move the image up
    S:
    cmp al, 73h;
    jne exit;
    
    mov ah, 06h;
    mov al, 01h;
    mov bh, 00h;
    mov ch, 0Ah;
    mov cl, 0Ah;
    mov dh, 14h;
    mov dl, 46h;
    int 10h;
    
    jmp scroll;
    
    exit:
    mov ah, 4Ch;
    int 21h;
    
    continuew:
    ;Set standart symbol attributes
    push bx;
    mov bl, 07h;
    
    ;Output background color 
    mov dl,10h;
    mov dh, 02h;
    mov ah, 02h;
    int 10h;
    
    mov si, offset background;
    mov al, cs:[si];
    
    backgroundlabel:
    cmp al, '$'
    jz endback;
    
    mov ah, 09h;
    
    push cx;
    mov cx, 1h;
    
    int 10h;
    pop cx;
    inc si;
    
    ;Move cursor forward
    inc dl;
    mov ah, 02h;
    int 10h;
    
    mov al, cs:[si];
    jmp backgroundlabel;
    
    endback:
    
    ;Output name of background color
    mov dl,22h;
    mov ah, 02h;
    int 10h;
    
    push cx;
    mov si, offset black;
    shr cx, 4h;
    and cx, 07h;         
    mov ax, 0Ch;
    push dx;
    mul cx;
    add ax, si;
    pop dx;
    pop cx;
    
    ;dx:ax hold actual result
    mov si, ax;
    mov al, cs:[si];
    
    labell:
    cmp al, '$'
    jz endlabel;
    
    mov ah, 09h;
    
    push cx;
    mov cx, 1h;
    
    int 10h;
    pop cx;
    inc si;
    
    ;Move cursor forward
    inc dl;
    mov ah, 02h;
    int 10h;
    
    mov al, cs:[si];
    jmp labell;
    
    endlabel: 
    
    ;Output number of foreground color
    mov dl,10h;
    mov dh, 0h;
    mov ah, 02h;
    int 10h;
    
    mov si, offset foreground;
    mov al, cs:[si];
    
    foregroundlabel:
    cmp al, '$'
    jz endfore;
    
    mov ah, 09h;
    
    push cx;
    mov cx, 1h;
    
    int 10h;
    pop cx;
    inc si;
    
    ;Move cursor forward
    inc dl;
    mov ah, 02h;
    int 10h;
    
    mov al, cs:[si];
    jmp foregroundlabel;
    
    endfore:
    
    ;Calculate required number
    mov dl,22h;
    mov ah, 02h;
    int 10h;
    
    ;
    mov ax, cx;
    and ax, 0Fh;
    push cx;
    
    mov cx, 0Ah;
    div cl;
    
    ;output quotent
    push ax;
    add al, '0'; 
    mov cx, 1h;   
    mov ah, 09h;
    int 10h; 
  
    mov dl,23h;
    mov ah, 02h;
    int 10h;  
    
    ;output remainder
    pop ax; 
    shr ax, 8h;
    add al, '0';    
    mov ah, 09h;
    int 10h;  
    pop cx;
    
    ;Return to start position
    mov bx, 0h;
    mov dl,0Ah;
    mov dh, 014h;
    mov ah, 02h;
    int 10h;
    pop bx;
    
    cmp bl, 01h;
    jz second_string;
    cmp bl, 02h;
    jz third_string;
    
    ;First string
    push bx;
    mov bl, cl;
    push cx;
    
    ;cx holds repeat count
    mov cx, 1h;
    mov si, offset Str1;
    
    outputf:
    mov al, cs:[si];
    cmp al, '$'; 
    jz endoutputf;
    
    ;Output symbol
    mov ah, 09h;
    int 10h;
    
    ;Change position
    cmp dh, 0Ah;
    jne upf;
    
    mov dh, 14h;
    
    cmp dl, 46h;
    jne incdf;
    mov dl, 0Ah;
    
    incdf:
    inc dl;
    
    jmp notincf;
    upf:
    dec dh;
    notincf:
    mov ah, 02h;
    int 10h;
    
    inc si;
    jmp outputf;
    
    endoutputf:
    pop cx;
    pop bx;
    inc bx;
    jmp increment;
    second_string:
    push bx;
    mov bl, cl;
    push cx;
    
    ;cx holds repeat count
    mov cx, 1h;
    mov si, offset Str2;
    
    outputs:
    mov al, cs:[si];
    cmp al, '$'; 
    jz endoutputs;
    
    ;Output symbol
    mov ah, 09h;
    int 10h;
    
    ;Change position
    cmp dh, 0Ah;
    jne ups;
    
    mov dh, 14h;
    
    cmp dl, 46h;
    jne incds;
    mov dl, 0Ah;
    
    incds:
    inc dl;
    
    jmp notincs;
    ups:
    dec dh;
    notincs:
    mov ah, 02h;
    int 10h;
    
    inc si;
    jmp outputs;
    
    endoutputs:
    pop cx;
    pop bx;
    inc bx;
    jmp increment;
    third_string:
    push bx;
    mov bl, cl;
    push cx;
    
    ;cx holds repeat count
    mov cx, 1h;
    mov si, offset Str3;
    
    outputt:
    mov al, cs:[si];
    cmp al, '$'; 
    jz endoutputt;
    
    ;Output symbol
    mov ah, 09h;
    int 10h;
    
    ;Change position
    cmp dh, 0Ah;
    jne upt;
    
    mov dh, 14h;
    
    cmp dl, 46h;
    jne incdt;
    mov dl, 0Ah;
    
    incdt:
    inc dl;
    
    jmp notinct;
    upt:
    dec dh;
    notinct:
    mov ah, 02h;
    int 10h;
    
    inc si;
    jmp outputt;
    
    endoutputt:
    pop cx;
    pop bx;
    mov bx, 0h;
    increment:
    inc cx;
    mov si, offset mainloop;
    
    ;Delay for 1,3 seconds
    push cx;
    push dx;
    push bx;

    mov ah, 0h;
    int 01Ah;
    mov bx, dx;
    
    Timer:
    mov ah, 0h;
    int 01Ah;
    
    sub dx, bx;
    sub dx, 017h;
    
    jl Timer;
    
    pop bx;
    pop dx;
    pop cx;
    
    jmp si;
CSEG ends
end Begin
