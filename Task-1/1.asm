.MODEL SMALL 
.STACK 100H
.DATA 
pirmasPranesimas DB 'Si programa skaiciuoja didziuju raidziu kieki ivestoje simboliu eiluteje. Prasau iveskite simboliu eilute: $'
antrasPranesimas DB 0DH,0AH,'Didziuju raidziu kiekis eiluteje yra :$'
treciasPranesimas DB 0DH,0AH,'Jus ivedete daugiau, nei 99 didziuju raidziu $'

.CODE 
strt:

;
MOV AX,@DATA 
MOV DS,AX 

LEA DX,pirmasPranesimas 
MOV AH,9  
INT 21H  
 


mov bX,0    
ciklo_pradzia:
MOV AH,1   
INT 21h
cmp al,0dh  
je Isvedimas1  

cmp al,'A'
JL ciklo_pabaiga  
CMP al,'Z'
JG ciklo_pabaiga  
INC bx    
 
cmp bx,99
JG Isvedimas2   

ciklo_pabaiga:
jmp ciklo_pradzia
Isvedimas1:
LEA DX,antrasPranesimas   
MOV AH,9   
INT 21H   
CMP bx,9
JLE Isvedimas3
 
     

   mov ax, bx
   mov bl, 10
   div bl  
                
   xor dx, dx
   mov dl, ah
   push dx   
   
      
   
   mov ah, 02h
   mov dl, al
   add dl, '0'
   int 21h
   pop dx 
   add dl, '0'
   int 21h



jmp exit_program 
Isvedimas3:
mov dl,bl   
add dl,'0'  
MOV AH,2   
INT 21H

jmp exit_program 
 
Isvedimas2:
LEA DX,treciasPranesimas   
MOV AH,9   
INT 21H   
 
exit_program:
MOV AH,4CH  
INT 21H
 
end strt

