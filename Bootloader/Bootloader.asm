; zerando registradores de segmento
xor ax, ax 
mov ds, ax ; segmento de dados
mov es, ax ; segmento extra 
mov ss, ax ; segmento de pilha

; Gerando modo de vídeo
; Int 10h, 00h            Set Video Mode

    ; Sets the video mode.

        ; Entry   AH = 00h
                ; AL = Video mode

        ; Return  Nothing


  ; On the EGA, MCGA, and VGA, the display memory is not erased by a
  ; mode set if the high bit of AL is set.


  ; Host memory affected by a mode set:
        ; 0040h:0049h     Current video mode
        ; 0040h:004Ah     No. of columns on screen
        ; 0040h:004Ch     Length of active screen buffer
        ; 0040h:004Eh     Start offset of current display page
        ; 0040h:0050h     Cursor positions
        ; 0040h:0060h     Cursor mode
        ; 0040h:0062h     Current display page
        ; 0040h:0063h     Base host address of port
        ; 0040h:0065h     Current mode
        ; 0040h:0066h     Current color
        ; 0040h:0084h     No. of character rows

; seção principal (main) do código
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; modo de vídeo 0x13 escolhido - resolução 320x200
mov al, 0x13
int 0x10

; Colocando fundo branco para facilitar, pois a figura principal na imagem estará representada em pixels pretos
; assim podemos apenas nos preocupar com eles
call FundoBranco

; Escrevendo frase
call EscreveFrase

; Desenho
;call Desenho

jmp $ ; cria um loop infinito de execução. Pula sempre para a posição atual

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


FundoBranco:
; primeiro trecho salva o estado da máquina ao entrar na função
push bp          ; Salva o valor atual do BP (Base Pointer) na pilha
mov bp, sp       ; Copia o valor atual do SP (Stack Pointer) para o BP
pusha            ; Salva todos os valores dos registros principais na pilha (AX, CX, DX, BX, SP, BP, SI, DI)

;implementa fundo branco utilizando interrupção 'write pixel'
; Int 10h, 0Ch            Write Pixel

    ; Writes a pixel dot of a specified color at a specified screen
    ; coordinate.

        ; Entry   AH = 0Ch
                ; AL = Pixel color
                ; CX = Horizontal position of pixel
                ; DX = Vertical position of pixel
                ; BH = Display page number (graphics modes with more
                     ; than 1 page)

        ; Return  Nothing
		
xor cx, cx ; começa na posição horizontal 0 
mov dx, 30 ; pos. vertical. Deixa um espaço no topo para escrita do texto posteriormente
mov ah, 0x0C
mov al, 0x0F ; define pixel branco

recomeca: ; valores acima nao mudam com as iterações
int 0x10
inc cx ; vai para a prox. posição horizontal
cmp cx, 320 ; verifica se cx chegou na resolução maxima 320 
je zeraHoriz ; se chegar na res. maxima, zera horizontal
jmp recomeca

; restaura o estado da máquina antes de sair
fim:
popa             ; Restaura os valores dos registros a partir da pilha (na ordem inversa: DI, SI, BP, SP, BX, DX, CX, AX)
mov sp, bp       ; Restaura o valor original do Stack Pointer a partir do BP
pop bp           ; Restaura o valor original do Base Pointer a partir da pilha
ret              ; Retorna para a instrução que vem depois da chamada para "FundoBranco"

; implementando zeraHoriz, que zera o indice da linha a cada troca de linha (0->319)
zeraHoriz:
xor cx, cx
inc dx
cmp dx, 200 ; compara a res. vertical com o limite
je fim
jmp recomeca


EscreveFrase:
push bp          ; Salva o valor atual do BP (Base Pointer) na pilha
mov bp, sp       ; Copia o valor atual do SP (Stack Pointer) para o BP
pusha            ; Salva todos os valores dos registros principais na pilha (AX, CX, DX, BX, SP, BP, SI, DI)

; implementação da escrita
; Int 10h, 13h            Write Character String                           many

    ; Writes a string of characters with specified attributes to any
    ; display page.

        ; Entry   AH    = 13h
                ; AL    = Subservice (0-3)
                ; BH    = Display page number
                ; BL    = Attribute (Subservices 0 and 1)
                ; CX    = Length of string
                ; DH    = Row position where string is to be written
                ; DL    = Column position where string is to be written
                ; ES:BP = Pointer to string to write

        ; Return  Nothing
; The service has four subservices, as follows:

        ; AL=00h: Assign all characters the attribute in BL; do not
                ; update cursor
        ; AL=01h: Assign all characters the attribute in BL; update
                ; cursor
        ; AL=02h: Use attributes in string; do not update cursor
        ; AL=03h: Use attributes in string; update cursor
		
mov ah, 0x13
mov al, 0x01
xor bx, bx
mov bl, 0x0F ; define cor branca para o texto 
mov cx, 11
mov dh, 0x1C
mov dl, 0x04
mov bp, mensagem ; move para bp o endereço de mensagem (o offset)
add bp, 0x7C00 ; adiciona em BP o endereço inicial do bootloader (padrao), para que o endereço seja o real na memoria
int 0x10

popa             ; Restaura os valores dos registros a partir da pilha (na ordem inversa: DI, SI, BP, SP, BX, DX, CX, AX)
mov sp, bp       ; Restaura o valor original do Stack Pointer a partir do BP
pop bp           ; Restaura o valor original do Base Pointer a partir da pilha
ret              ; Retorna para a instrução que vem depois da chamada para "FundoBranco"

; Variáveis
mensagem: db "Hire me! ;D"

; Finalizando
times (510 - ($ - $$)) db 0x00 ; Preenchendo o resto do programa com 0s para completar os 512 bytes necessarios. $ representa a pos. atual e $$ a pos. inicial.  
dw 0xAA55 ; os dois ultimos bytes precisam ser preenchidos assim. É uma assinatura para bootloader
