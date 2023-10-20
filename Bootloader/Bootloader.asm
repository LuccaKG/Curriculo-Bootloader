; Inicialização do bootloader
jmp short main        ; Desvio de curta distância para a etiqueta "main". Isso efetivamente pula o header e começa a execução.
nop                   ; Nenhuma operação. Preenchimento para manter o alinhamento. A instrução nop diz ao processador para simplesmente avançar para a próxima instrução sem fazer nada. É uma ferramenta útil para controle de fluxo, temporização, alinhamento e depuração.

; Configurações do FAT12 BPB (BIOS Parameter Block)

OEMname: db "_LuccaSO"         ; Nome do OEM. Identifica o sistema que formatou o volume.
bytesPerSector: dw 512         ; Bytes por setor. Normalmente 512.
sectPerCluster: db 1           ; Setores por cluster.
reservedSectors: dw 1          ; Número de setores reservados no início do volume. Normalmente 1 para FAT12.
numFATs: db 2                  ; Número de tabelas FAT no volume. Quase sempre 2.
numRootDirEntries: dw 224      ; Número de entradas no diretório raiz.
numSectors: dw 2880            ; Total de setores no volume.
mediaType: db 0xF0             ; Byte de tipo de mídia. 0xF0 é típico para disquetes.
numFATSectors: dw 9            ; Número de setores por tabela FAT.
sectorsPerTrack: dw 18         ; Setores por trilha. Para disquetes, muitas vezes é 18.
numHeads: dw 2                 ; Número de cabeças ou lados. Para disquetes, é geralmente 2.
numHiddenSectors: dd 0         ; Número de setores antes do início do volume. 0 para disquetes.
numSectorsHuge: dd 0           ; Para FAT12/FAT16, isso é sempre 0.
driveNum: db 0                 ; Número de drive. 0 para disquetes.
reserved: db 0                 ; Byte reservado. Sempre 0.
extendedBootSignature: db 0x29 ; Assinatura usada para validar os próximos três campos.
volumeID: dd 0xa1b2c3d4        ; ID do volume. Valor aleatório gerado durante a formatação.
volumeLabel: db "  LuccaSO  "  ; Rótulo do volume. Normalmente mostrado em sistemas de diretório.
fileSysType: db "FAT12   "     ; Tipo de sistema de arquivos. Apenas informativo.

;os nops podem ser usados para garantir que, quando o arquivo for interpretado como um PDF (ou qualquer outro formato), esses bytes 
; não causem efeitos colaterais adversos na visualização ou funcionamento do arquivo.
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop
nop


main:
mov [drvnum], dl        ; Copia o número do drive de boot do registrador DL para a variável drvnum
mov ax, 0x7C00          ; Carrega AX com o endereço padrão de carregamento do bootloader
mov ds, ax              ; Define o segmento de dados para o início do bootloader
mov ax, 0x7C0           ; Carrega AX com a representação simplificada do endereço
mov es, ax              ; Define o segmento extra para o início do bootloader
sub ax, 0x200           ; Subtrai 512 do AX, configurando espaço para a pilha
mov sp, ax              ; Configura o ponteiro da pilha 512 bytes antes do bootloader
mov bp, ax              ; Configura o ponteiro base para o mesmo local que o ponteiro da pilha


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

; seção principal do código
; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; modo de vídeo 0x13 escolhido - resolução 320x200
xor ax, ax 
mov al, 0x13
int 0x10

; Colocando fundo branco para facilitar, pois a figura principal na imagem estará representada em pixels pretos
; assim podemos apenas nos preocupar com eles
call FundoBranco

; Escrevendo frase
call EscreveFrase

; espaço acabou, utilizaremos a parte 2
; Chama parte 2 do bootloader
call Parte2Init

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
int 0x10

popa             ; Restaura os valores dos registros a partir da pilha (na ordem inversa: DI, SI, BP, SP, BX, DX, CX, AX)
mov sp, bp       ; Restaura o valor original do Stack Pointer a partir do BP
pop bp           ; Restaura o valor original do Base Pointer a partir da pilha
ret              ; Retorna para a instrução que vem depois da chamada para "FundoBranco"

Parte2Init:
; Int 13h, 02h            Read Sectors into Memory                          all

    ; Reads one or more sectors from a fixed or floppy disk into memory.

        ; Entry   AH    = 02h
                ; AL    = Number of sectors to read
                ; CH    = Cylinder number (10 bit value; upper 2 bits in CL)
                ; CL    = Starting sector number
                ; DH    = Head number
                ; DL    = Drive number
                ; ES:BX = Address of memory buffer

        ; Return  AH = Status of operation (See Service 01h)
                ; AL = Number of sectors read
                ; CF   Set if error, else cleared

mov ah, 2           ; Configura AH para ler setores em memória
mov al, 3           ; Indica que três setores serão lidos
mov ch, 0           ; Cilindro inicial definido como 0
mov cl, 2           ; Número do setor inicial definido como 2. pois o 1 ja está carregado
mov dh, 0           ; Número da cabeça (head) definido como 0
mov dl, [drvnum]    ; Usa o número do drive de boot armazenado anteriormente
mov bx, stage2      ; Define onde os setores lidos serão armazenados na memória
int 0x13            ; Chama a interrupção do BIOS para ler os setores
jmp stage2          ; Pula para o início do código do segundo estágio



; Variáveis
mensagem: db "Hire me! ;D"
drvnum: db 0 ; é bom armazenar esse valor numa variavel pois dl pode ser sobrescrito

; Finalizando
times (510 - ($ - $$)) db 0x00 ; Preenchendo o resto do programa com 0s para completar os 512 bytes necessarios. $ representa a pos. atual e $$ a pos. inicial.  
dw 0xAA55 ; os dois ultimos bytes precisam ser preenchidos assim. É uma assinatura para bootloader
; FIM DA PARTE 1



; INICIO DA PARTE 2

stage2: 

call Desenho
final: 
jmp $

Desenho:
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

push bp
mov bp, sp
pusha

xor ax, ax
mov ds, ax
mov si, ax

push 0x0F ; cor branca (inicial na imagem) [sp + 0x06]
push 0x00 ; X - Horizontal
push 199 ; Y - Vertical [sp + 0x02]
push 0x00 ; Num. de repetições [sp]

mov di, sp 
mov bl, byte [0x7C00 + dados + si] ; repetições

inicio: 
mov dx, [di + 0x02] ; Vertical

volta1:
xor bh, bh 
mov cx, [di + 0x04]
mov al, [di + 0x06]
mov ah, 0x0C
int 0x10
dec bl ; diminui uma repetição
mov [di], bl ; salvo as reps que faltam
cmp bl, 0
je trocaCor
volta2: 
xor ax, ax 
mov ax, word[di+0x04]
inc ax 
cmp ax, 319
je preparaRetorno
mov [di + 0x04], ax 
jmp volta1

preparaRetorno:
xor ax, ax 
mov [di + 0x04], ax 
mov ax, [di + 0x02]
dec ax 
mov [di + 0x02], ax 
inc si 
mov bl, byte [0x7C00 + dados + si] 
cmp bl, 0xFF
je final 
jmp inicio 

trocaCor:
mov al, [di +0x06]
cmp al, 0x0F ; compara se é branco
je preto
mov al, 0x0F
jmp salva

preto:
mov al, 0x00
 
salva:
mov [di + 0x06], al 
inc si 
mov bl, byte[0x7c00 + dados + si] 
cmp bl, 255
je final 
mov [di], bl 
jmp volta2




popa
mov sp, bp
pop bp
ret

dados: db 65, 222, 33,65, 221, 34,65, 221, 34,65, 220, 35,65, 220, 35,65, 219, 36,65, 218, 37,65, 217, 38,65, 217, 38,65, 216, 39,65, 215, 40,65, 214, 41,65, 100, 24, 89, 42
       db 65, 93, 38, 81, 43,65, 89, 44, 78, 44,65, 91, 42, 77, 45,65, 93, 41, 75, 46,65, 97, 1, 2, 3, 1, 32, 71, 48,65, 107, 29, 69, 50,65, 108, 2, 1, 25, 68, 51,65, 112, 24
	   db 66, 53,65, 116, 20, 64, 55,65, 119, 17, 59, 60,65, 122, 14, 51, 68,65, 126, 9, 47, 73,66, 127, 7, 44, 76,74, 122, 2, 42, 80,82, 153, 85,87, 143, 90,91, 134, 95,96
	   db 121, 103,100, 105, 115,101, 76, 2, 26, 115,103, 69, 13, 22, 113,109, 39, 2, 9, 1, 9, 18, 22, 111,107, 38, 9, 9, 2, 3, 20, 15, 1, 5, 111,107, 37, 12, 10, 25, 19, 110
	   db 106, 37, 5, 3, 3, 13, 27, 18, 108,105, 65, 27, 15, 108,105, 67, 26, 14, 108,107, 65, 28, 13, 107,104, 69, 28, 4, 3, 5, 107,103, 70, 36, 5, 106,101, 1, 2, 60, 47, 4, 105
	   db 103, 56, 22, 2, 9, 5, 16, 3, 104,103, 95, 16, 3, 103,101, 64, 3, 30, 16, 4, 102,101, 62, 3, 30, 19, 3, 102,101, 95, 19, 3, 102,100, 84, 2, 1, 29, 2, 102,100, 64, 2, 13
	   db 36, 4, 101,97, 71, 48, 3, 101,96, 29, 6, 37, 48, 3, 101,96, 30, 9, 34, 47, 2, 102,95, 25, 17, 32, 2, 10, 35, 2, 102,94, 12, 2, 3, 1, 11, 16, 27, 9, 6, 35, 2, 102,94, 1
	   db 2, 8, 9, 49, 53, 2, 102,93, 1, 1, 10, 2, 2, 3, 36, 4, 9, 22, 12, 21, 2, 102,92, 12, 7, 2, 1, 1, 7, 38, 42, 6, 8, 2, 102,91, 2, 1, 10, 10, 10, 21, 14, 19, 2, 140,90, 2
	   db 1, 11, 7, 2, 2, 1, 30, 13, 18, 2, 38, 1, 102,89, 3, 1, 11, 5, 1, 38, 10, 18, 2, 37, 1, 1, 1, 102,88, 4, 2, 9, 6, 1, 38, 11, 16, 1, 39, 4, 101,87, 16, 6, 2, 35, 12, 16
	   db 1, 41, 3, 101,87, 15, 2, 2, 1, 4, 2, 3, 7, 10, 10, 16, 14, 2, 41, 3, 101,87, 15, 2, 6, 3, 46, 13, 2, 9, 7, 27, 2, 101,87, 15, 3, 5, 2, 29, 1, 18, 12, 2, 7, 7, 29, 2, 101
	   db 88, 3, 3, 8, 2, 6, 1, 26, 3, 21, 10, 2, 5, 14, 4, 6, 15, 2, 101,93, 9, 2, 60, 5, 4, 4, 17, 2, 7, 8, 4, 2, 2, 101,92, 81, 3, 27, 14, 5, 98,92, 8, 1, 74, 1, 18, 5, 1, 10
	   db 1, 5, 7, 97,92, 20, 3, 48, 10, 18, 16, 11, 102,92, 67, 19, 15, 21, 5, 101,92, 12, 7, 49, 13, 7, 33, 5, 102,92, 14, 5, 17, 2, 29, 15, 11, 28, 5, 102,91, 17, 4, 45, 18, 33
	   db 4, 6, 102,91, 16, 6, 41, 22, 30, 6, 7, 101,91, 17, 1, 1, 6, 34, 33, 14, 15, 7, 101,91, 17, 2, 1, 3, 31, 67, 7, 101,91, 18, 5, 20, 77, 8, 101,92, 16, 6, 24, 73, 8, 101
	   db 93, 16, 8, 22, 72, 8, 101,93, 17, 5, 27, 2, 3, 64, 7, 102,93, 16, 7, 35, 59, 8, 102,93, 17, 2, 41, 56, 9, 102,94, 17, 3, 43, 52, 7, 104,95, 64, 49, 8, 104,95, 66, 45
	   db 10, 104,96, 67, 42, 9, 106,96, 70, 38, 11, 105,98, 69, 36, 11, 106,96, 73, 32, 13, 106,97, 73, 29, 13, 108,98, 74, 25, 14, 109,97, 77, 20, 17, 109,99, 78, 7, 1, 4, 20
	   db 111,100, 109, 111,98, 111, 111,99, 111, 110,99, 108, 113,99, 108, 113,98, 109, 113,100, 106, 114,101, 104, 115,101, 105, 114,103, 103, 114,103, 102, 115,107, 97, 116
	   db 107, 96, 117,108, 1, 3, 90, 118,111, 85, 124,113, 77, 130,113, 73, 134,117, 2, 4, 59, 138,124, 56, 140,133, 16, 11, 5, 2, 4, 149,132, 14, 13, 2, 159, 255