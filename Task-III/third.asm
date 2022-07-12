.model small
.stack 100h
.data
	senasIP dw ?
	senasCS dw ?

	regAX dw ?
	regBX dw ?
	regCX dw ?
	regDX dw ?
	regSP dw ? 
	regBP dw ?
	regSI dw ?
	regDI dw ?	
	
	reg_bxsi db "BX + SI$"
	reg_bxdi db "BX + DI$"
	reg_bpsi db "BP + SI$"
	reg_bpdi db "BP + DI$"
	reg_si db "SI$" 
	reg_di db "DI$"
	reg_bp db "BP$"
	
	reg_ax db "AX$"
	reg_al db "AL$"
	reg_ah db "AH$"
	reg_bx db "BX$"
	reg_bl db "BL$"
	reg_bh db "BH$"
	reg_cx db "CX$"
	reg_cl db "CL$"
	reg_ch db "CH$"
	reg_dx db "DX$"
	reg_dl db "DL$"
	reg_dh db "DH$"
	reg_sp db "SP$"
	
	baitas1 db ?
	baitas2 db ?
	baitas3 db ?
	baitas4 db ?
	baitas5 db ?
	baitas6 db ?
	

	bitasS db ?
	bitasW db ?
	bitasMOD db ?
	bitasRM db ?
	
	;
	pranesimas db "Zingsnio rezimo pertraukimas! ", 13, 10, '$'
	add_komanda db "ADD $"
	byte_ptr db "byte ptr $"
	word_ptr db "word ptr $"	
	
	plius db " + $" 
	lygu db " = $"
	brac_open db "[$"
	brac_close db "]$"	
	dvitaskis db ":$"
	kablelis db ",$"	
	enteris db 13,10,"$"
	tarpas db " $"
	
	number dw 1111h
	
.code
;
PrintString MACRO tekstas 
	push ax
	push dx
	mov dx, offset tekstas
	mov ah, 9
	int 21h
	pop dx
	pop ax
ENDM
;
TikrinkRM MACRO _rm, tekstas  
	mov al, _rm
	mov dx, offset tekstas
	call printRM
ENDM
TikrinkRM_value MACRO _rm, tekstas, reiksme 
	mov al, _rm
	mov dx, offset tekstas
	mov bx, reiksme
	call printRM
ENDM
TikrinkRM_1 MACRO _rm, tekstas1, reiksme1
	mov al, _rm
	mov dx, offset tekstas1
	mov bx, reiksme1
	call extra
ENDM

TikrinkRM_2 MACRO _rm, tekstas1, reiksme1, tekstas2, reiksme2
	push bx
	mov al, _rm
	mov dx, offset tekstas1
	mov bx, reiksme1
	call extra
	mov dx, offset tekstas2
	mov bx, reiksme2
	call extra
	pop bx
ENDM

TikrinkREG MACRO _reg, tekstas
	mov al, _reg
	mov dx, offset tekstas
	call printREG
ENDM

pradzia:
	mov ax, @data
	mov ds, ax
	
	mov ax, 0
	mov es, ax
	
	mov ax, es:[4] 
	mov bx, es:[6]
	
	mov senasCS, bx
	mov senasIP, ax
	
	;
	mov ax, cs; 
	mov bx, offset pertraukimas
	
	;
	mov es:[4], bx
	mov es:[6], ax
	
	;
	pushf
	pop ax
	or ax, 100h
	push ax
	popf
	
	;
	mov bx, offset number
	add word ptr [bx], 123h
	add dx, 2h
	add bx, 111h
	add ax, bx
	mov bx, offset number
	mov si, 0
	add word ptr [bx+si], 1111h
	inc ax

	pushf
	pop ax
	and ax, 0FEFFh
	push ax
	popf
	
	mov ax, senasIP
	mov bx, senasCS
	mov es:[4], ax
	mov es:[6], bx
	
	mov ah, 4Ch
	mov al, 0
	int 21h
	
pertraukimas:
	mov regAX, ax				
	mov regBX, bx
	mov regCX, cx
	mov regDX, dx
	mov regSP, sp
	mov regBP, bp
	mov regSI, si
	mov regDI, di

	pop si
	pop di
	push di
	push si

	mov ax, cs:[si]
	mov bx, cs:[si+2]
	mov cx, cs:[si+4]
	
	mov baitas1, al
	mov baitas2, ah
	mov baitas3, bl
	mov baitas4, bh
	mov baitas5, cl
	mov baitas6, ch
		
	mov al, baitas1
	mov ah, baitas2
	
	push ax
	and al, 0FCh
	cmp al, 80h 
	jne pert_pabaiga_jump
	pop ax
	
	push ax
	and al, 02h
	mov bitasS, al 
	pop ax
	
	push ax
	and al, 01h
	mov bitasW, al 
	pop ax
	
	push ax
	and ah, 0C0h
	mov bitasMOD, ah
	pop ax
	
	push ax
	and ah, 07h
	mov bitasRM, ah
	pop ax
		
	jmp komandos_analize
	pert_pabaiga_jump:
	jmp pert_pabaiga
	
	komandos_analize:
	;
	PrintString pranesimas
	
	mov ax, di
	call printZodinisRegistras
	PrintString dvitaskis
	mov ax, si
	call printZodinisRegistras
	PrintString tarpas
	
	mov al, baitas1
	call printBaitinisRegistras
	mov al, baitas2
	call printBaitinisRegistras

	tikrinti_poslinki:
	cmp bitasMOD, 0C0h
	je inbitasMOD11
	
	cmp bitasMOD, 0
	jne test_kiek_offset_print
	
	cmp bitasRM, 06h
	je print_2_offset_bytes ; 
	jmp no_print_offset_bytes
	
	test_kiek_offset_print:
		cmp bitasMOD, 040h
		je print_1_offset_byte
	print_2_offset_bytes:
		mov al, baitas6
		call printBaitinisRegistras
		mov al, baitas5
		call printBaitinisRegistras
		jmp no_print_offset_bytes
	print_1_offset_byte:
		mov al, baitas5
		call printBaitinisRegistras

	no_print_offset_bytes:
		PrintString tarpas
		
	jmp komandos_isvedimas
	;	
	inbitasMOD11:
	PrintString tarpas
	PrintString add_komanda
	
	cmp bitasW, 0
	jne w_1
	PrintString tarpas
	jmp tikrinu_rm_w_0
	
	w_1:
	
	TikrinkRM_value 00h, reg_ax,regAX
	TikrinkRM_value 01h, reg_cx,regCX
	TikrinkRM_value 02h, reg_dx,regDX
	TikrinkRM_value 03h, reg_bx,regBX
	TikrinkRM_value 04h, reg_sp,regSP
	TikrinkRM_value 05h, reg_bp,regBP
	TikrinkRM_value 06h, reg_si,regSI
	TikrinkRM_value 07h, reg_di,regDI
	PrintString enteris
	jmp pert_pabaiga
		
	tikrinu_rm_w_0:
	
	TikrinkRM_value 00h, reg_ax,regAX
	TikrinkRM_value 01h, reg_cx,regCX
	TikrinkRM_value 02h, reg_dx,regDX
	TikrinkRM_value 03h, reg_bx,regBX
	TikrinkRM_value 04h, reg_sp,regSP
	TikrinkRM_value 05h, reg_bp,regBP
	TikrinkRM_value 06h, reg_si,regSI
	TikrinkRM_value 07h, reg_di,regDI
	PrintString enteris
	jmp pert_pabaiga
	
	komandos_isvedimas:
	PrintString add_komanda
	cmp bitasW, 0
	je w0
	
	PrintString word_ptr
	jmp mod_rm_analize
	
	w0:
	PrintString byte_ptr

	mod_rm_analize:
	PrintString brac_open
		
	cmp bitasMOD, 0
	jne rm_analize
	cmp bitasRM, 06h
	je su_2_b_offset ; 
	
	rm_analize:
	TikrinkRM 00h, reg_bxsi
	TikrinkRM 01h, reg_bxdi
	TikrinkRM 02h, reg_bpsi
	TikrinkRM 03h, reg_bpdi
	TikrinkRM 04h, reg_si
	TikrinkRM 05h, reg_di
	TikrinkRM 06h, reg_bp
	TikrinkRM 07h, reg_bx
					
	tikr_offset:
		cmp bitasMOD, 0
		je be_offset_jmp
	su_offset:
		PrintString plius
		cmp bitasMOD, 80h
		je su_2_b_offset
	su_1_b_offset:
		mov al, baitas5
		call printBaitinisRegistras
		jmp be_offset
	su_2_b_offset:
		mov al, baitas6
		call printBaitinisRegistras
		mov al, baitas5
		call printBaitinisRegistras
	PrintString brac_close
	PrintString kablelis
	PrintString tarpas
	
	jmp ignoruoti
	be_offset_jmp:
	jmp be_offset
	ignoruoti:
	
	cmp bitasS, 2
	JNE jei_ne_1
	PrintString tarpas
	mov al, baitas3
	call printBaitinisRegistras
	jmp praleist1
	jei_ne_1:
	PrintString tarpas
	mov al, baitas4
	call printBaitinisRegistras
	mov al, baitas3
	call printBaitinisRegistras
	praleist1:
	PrintString tarpas
			
	;
	cmp bitasMOD, 0
	jne value
	cmp bitasRM, 06h
	je pert_pabaiga_temp
	jmp value
	pert_pabaiga_temp:
	jmp pert_pabaiga_NL

	be_offset:
	PrintString brac_close
	PrintString kablelis
	
	cmp bitasS, 2
	JNE jei_ne_2
	PrintString tarpas
	mov al, baitas3
	call printBaitinisRegistras
	jmp praleist2
	jei_ne_2:
	PrintString tarpas
	mov al, baitas4
	call printBaitinisRegistras
	mov al, baitas3
	call printBaitinisRegistras
	praleist2:
	PrintString tarpas
	
	value:
	
	TikrinkRM_2 00h, reg_bx, regBX, reg_si, regSI
	TikrinkRM_2 01h, reg_bx, regBX, reg_di, regDI
	TikrinkRM_2 02h, reg_bp, regBP, reg_si, regSI
	TikrinkRM_2 03h, reg_bp, regBP, reg_di,regDI
	TikrinkRM_1 04h, reg_si, regSI
	TikrinkRM_1 05h, reg_di, regDI
	TikrinkRM_1 06h, reg_bp, regBP
	TikrinkRM_1 07h, reg_bx, regBX	
		
	pert_pabaiga_NL:
	call printRM_reiksme
	PrintString enteris
	pert_pabaiga:
		
	mov ax, regAX
	mov bx, regBX
	mov cx, regCX
	mov dx, regDX
	mov sp, regSP
	mov bp, regBP
	mov si, regSI
	mov di, regDI
iret

printRM proc
	cmp al, bitasRM 
	jne netinka_jmp
	push ax
	mov ah, 9
	int 21h
	pop ax
	cmp bitasMOD, 0C0h
	jne netinka
		;
		PrintString kablelis
		PrintString tarpas
		
		jmp praleisti1
		netinka_jmp:
		jmp netinka
		praleisti1:
		
		push ax
		push bx
		cmp bitasS, 2
		JNE ne_1
		mov al, baitas3
		call printBaitinisRegistras
		jmp praleisti2
		ne_1:
		mov al, baitas4
		call printBaitinisRegistras
		mov al, baitas3
		call printBaitinisRegistras
		praleisti2:
		PrintString tarpas
		pop bx
		pop ax
		
		push ax
		push bx
		mov ah, 9
		int 21h
		PrintString lygu
		cmp bitasW, 1
		je w_didesnis
		mov ax, bx
		call printBaitinisRegistras
		jmp pabaigti_spausdinima
		w_didesnis:
		mov ax, bx
		call printBaitinisRegistras
		mov al, ah
		call printBaitinisRegistras
		
		pabaigti_spausdinima:
		pop bx
		pop ax
	netinka:
		ret
endp

printRM_reiksme proc
	push ax
	push dx
	push bx
	
	cmp bitasMOD, 0
	jne baigti
	Cmp bitasRM, 0
	jne baigti
	
	PrintString tarpas
	PrintString brac_open
	PrintString reg_bxsi
	PrintString brac_close
	PrintString lygu
	
	MOV ax, regBX
	MOV dx, ax
	MOV ax, regSI
	ADD dx, ax
	mov bx, dx
	
	MOV ax, ds:[bx]
	call printZodinisRegistras
	PrintString tarpas
	
	baigti:
	pop bx
	pop dx
	pop ax
	ret
endp

printZodinisRegistras proc
	push ax
	mov al, ah
	call printBaitinisRegistras
	pop ax
	call printBaitinisRegistras
	RET
endp

printBaitinisRegistras proc
	push ax
	push cx
	
	push ax
	mov cl, 4
	shr al, cl
	call printHexSkaitmuo
	pop ax
	call printHexSkaitmuo
		
	pop cx
	pop ax
	RET
endp

printHexSkaitmuo proc
	push ax
	push dx
	;
	and al, 0Fh 
	cmp al, 9
	jbe PrintHexSkaitmuo_0_9
	jmp PrintHexSkaitmuo_A_F
	
	PrintHexSkaitmuo_A_F: 
	sub al, 10 
	add al, 41h
	mov dl, al
	mov ah, 2
	int 21h
	jmp PrintHexSkaitmuo_grizti
	
	
	PrintHexSkaitmuo_0_9: 
	mov dl, al
	add dl, 30h
	mov ah, 2 
	int 21h
	
	printHexSkaitmuo_grizti:
	pop dx
	pop ax
	RET
endp	

extra proc
	push ax
	cmp al, bitasRM 
	jne netinka2
	PrintString tarpas
	push ax
	call printRM
	PrintString lygu
	mov ax, bx
	call printZodinisRegistras
		PrintString kablelis
		pop ax
		PrintString brac_open
		call printRM
		PrintString brac_close
		PrintString lygu
		mov ax, [bx]
		call PrintZodinisRegistras
	netinka2:
	pop ax
	ret
endp
END