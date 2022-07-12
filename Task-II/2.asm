;Vadim Čeremisinov 4 grupė
;Parašykite programą, kuri atlieka operaciją XOR 
;dviems beveik bet kokio ilgio dvejetainiams skaičiams, esantiems failuose, 
;ir išveda rezultatą į trečią failą.


.model small		    
readBufsize     EQU 16	
.stack 100h		
.data            
	howManyTimesRead DB 0
    
    skaitytiPirmoFailoPavadinima        DB 50 dup (?)
   	pirmasSkaitytiBufferi    	 DB readBufsize dup (0)
   	readhandle1      DW ?   
   	
    skaitytiAntroFailoPavadinima        DB 50 dup (?)                      
    antrasSkaitytiBufferi    	 DB readBufsize dup (0)
    readhandle2      DW ?         
    
    rasytiFailoPavadinima        DB 50 dup (?)
    writeHandle      DW ?
    
    programosPaskirtis             DB 'Si programa atlieka XOR operacija dviem beveik bet kokio ilgio dvejetainiams skaiciams, esantiems failuose, ir isveda operacijos rezultata i trecia faila.$'   
    sekmingoSkaiciavimuIvykdymoPranesimas   DB 'Skaiciavimai ivykdyti sekmingai, prasome patikrinti tPrograma buvo ivykdyta be klaidu, rezultatu ieskokite faile $'
.code

main:                  
    mov ax, @data
    mov ds, ax  
    	
	mov si, 0
	mov bh, 0   
		
	lea di, skaitytiPirmoFailoPavadinima
	call failoPavadinimoPaieska
	cmp bh, 0FFh
	je nutraukti
	
	lea di, skaitytiAntroFailoPavadinima
	call failoPavadinimoPaieska
	cmp bh, 0FFh
	je nutraukti 
	
	lea di, rasytiFailoPavadinima
	call failoPavadinimoPaieska
	cmp bh, 0FFh
	je nutraukti  
	
	
	mov ax, 3D00h                  
	lea dx, skaitytiPirmoFailoPavadinima
	int 21h
	jc nutraukti                   
	mov readhandle1, ax            
	
	mov ax, 3D00h
	lea dx, skaitytiAntroFailoPavadinima
	int 21h
	jc nutraukti                    
	mov readhandle2, ax          
	 
	mov ah, 3Ch                   
	mov cx, 0                      
	lea dx, rasytiFailoPavadinima
	int 21h
	jc nutraukti                    
	mov writeHandle, ax            
	
	jmp skaitytiFaila 
        
	skaitytiFaila:
	    call isvalytiBufferi
	    mov bh, 0
	    call irasytIBufferi    
	    cmp bh, 0FFh
	    je nutraukti
	    cmp ax, 0       
	    je uzbaigimas
		jmp ivestiesApdorojimas
		
	nutraukti:   
    	mov ah, 09h  
        lea dx, programosPaskirtis
        int 21h
        jmp null
	
	
	ivestiesApdorojimas:
	    mov cx, ax          
	    lea si, pirmasSkaitytiBufferi
	    lea di, antrasSkaitytiBufferi
	    iterating:
    	    mov dl, [si]
    	    mov dh, [di]
    	    call makeMoreNumbers
    	    cmp dl, '1'     
    	    ja nutraukti
    	    cmp dh, '1'
    	    ja nutraukti
    	    cmp dl, '0'
    	    jb nutraukti
    	    cmp dh, '0'
    	    jb nutraukti
    	    sub dl, '0'
    	    sub dh, '0'
    	    xor dl, dh
    	    add dl, '0'          
    	    mov [si], dl       
    	    inc si
    	    inc di
    	    loop iterating	
    	    jmp rasytiRezultataIFaila
	
	rasytiRezultataIFaila:
	    mov cx, ax           
	    mov bx, writeHandle  
	    call rasytiIsBufferio
	    cmp dh, 0FFh
	    je nutraukti  
	    cmp ax, readBufsize   
	    je skaitytiFaila
		
	uzbaigimas:           
	
	mov ah, 3Eh
	mov bx, writeHandle   
	int 21h
	jc nutraukti
	
	mov ah, 3Eh
	mov bx, readhandle1    
	int 21h
	jc nutraukti
	
	mov ah, 3Eh
	mov bx, readhandle2     
	int 21h
	jc nutraukti
	
	mov ah, 09h
	lea dx, sekmingoSkaiciavimuIvykdymoPranesimas
	int 21h
	
	mov ah, 09h
	lea dx, rasytiFailoPavadinima
	int 21h
    
null:
    mov ax, 4C00h
    int 21h 
    
    
proc failoPavadinimoPaieska
    
    mov bl, 0             
    mov al, es:[81h+si]
    cmp al, ' '
    je ignoruotiTarpus
    jmp nextIteration
    
	ignoruotiTarpus:   
    	inc si
    	mov al, es:[81h+si]
    	cmp al, ' '
        je ignoruotiTarpus
	
    nextIteration: 
        mov al, es:[81h+si]
        cmp al, ' '              
        je procedurosUzbaigimas
        cmp es:[81h+si], '?/'  
        je programosPaskirtiesPranesimoIskvietimas   
        cmp al, 0dh               
        je procedurosUzbaigimas
        mov ds:[di], al            
        inc bl               
        inc di
        inc si
        jmp nextIteration
        
    programosPaskirtiesPranesimoIskvietimas:
        mov bh, 0FFh              
        inc bl
        jmp procedurosUzbaigimas
        
    procedurosUzbaigimas:
        mov al, 0
        mov ds:[di], al            
        cmp bl, 0
        je programosPaskirtiesPranesimoIskvietimas               
        inc di       
        mov al, '$'
        mov ds:[di], al
        DEC di 
        ret
        
failoPavadinimoPaieska endp

proc irasytIBufferi           
    mov cx, readBufsize
    
    mov ah, 3Fh
    lea dx, pirmasSkaitytiBufferi      
    mov bx, readhandle1
    int 21h
    jc readErrorException
	push ax
	
    mov ah, 3Fh
    mov cx, readBufsize
    lea dx, antrasSkaitytiBufferi      
    mov bx, readhandle2
    int 21h
    jc readErrorException
	pop dx
	
	cmp ax, 0
	je ivestiesKlaiduPatikra
	cmp dx, 0
	je ivestiesKlaiduPatikra
	
	grazintiIvestiesKlaiduPatikra:
	inc howManyTimesRead
	cmp ax, dx
	jb perejimas
	jmp irasytIBufferiUzbaigimas
	
	perejimas:
	    mov ax, dx
    
    irasytIBufferiUzbaigimas:
        ret  
        
    readErrorException:     
        mov bh, 0FFh
        mov ax, 0       
        jmp irasytIBufferiUzbaigimas
		
	ivestiesKlaiduPatikra:
	cmp howManyTimesRead, 0
	je readErrorException
	jmp grazintiIvestiesKlaiduPatikra
        
irasytIBufferi endp

proc rasytiIsBufferio
    mov ah, 40h
    lea dx, pirmasSkaitytiBufferi           
    int 21h
    jc writeErrorException    
    cmp cx, ax
    jne writeErrorException
    
    rasytiIsBufferioUzbaigimas:          
        ret
    
    writeErrorException:
        mov dh, 0FFh       
        jmp rasytiIsBufferioUzbaigimas
rasytiIsBufferio endp

proc makeMoreNumbers 
	cmp dl, 0
	je incdl
	cmp dh, 0
	je incdh
	return:
	
	ret
	
	incdl:
        mov dl, '0'
        jmp return
            
    incdh:
        mov dh, '0'
        jmp return
makeMoreNumbers endp

proc isvalytiBufferi
	mov cx, readBufsize
	lea bx, pirmasSkaitytiBufferi
	lea bp, antrasSkaitytiBufferi
	mov al, 0
	clear:
	mov ds:[bx], al
	mov ds:[bp], al
	inc bx
	inc bp
	loop clear
	ret
isvalytiBufferi endp
	
        
end main
