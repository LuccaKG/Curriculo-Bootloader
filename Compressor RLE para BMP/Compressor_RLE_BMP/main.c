#include <stdio.h>
#include <stdlib.h>
#include "BMPconfigs.h"

BFHeader bf;

/* 
na main abaixo, argc � o Argument-Counter (conta quantos argumentos h� na chamada da fun��o via terminal)
e argv[] � a propria lista de argumentos. Exemplo abaixo:

Se voc� tem um programa chamado prog e voc� o executa como:

prog arg1 arg2 arg3

Ent�o, dentro do programa:

argc ser� 4 (inclui a chamada do programa).
argv[0] ser� "prog".
argv[1] ser� "arg1".
argv[2] ser� "arg2".
argv[3] ser� "arg3".
*/
int main(int argc, char* argv[]) {
    FILE* fp;
    char arg[] = "C:\\Users\\lucca\\OneDrive\\Documentos\\cv.bmp";

    // fopen_s � uma vers�o mais segura de fopen. Ela tenta abrir o arquivo especificado e retorna 0 em caso de sucesso.
    // Se bem-sucedida, o ponteiro para o arquivo � armazenado na vari�vel fp. "rb' quer dizer que leremos um arquivo bin�rio.
    /*
    Sobre o tipo errno_t:
    errno_t � um tipo de dado definido na linguagem C (especialmente no ambiente Microsoft quando se usa o MSVC) para representar c�digos de erro.

Ele � frequentemente utilizado com fun��es seguras (as que t�m o sufixo _s), que s�o uma extens�o da biblioteca C padr�o criada para abordar
preocupa��es comuns de seguran�a relacionadas a buffer overflows e outros tipos de vulnerabilidades. Estas fun��es retornam um valor errno_t em 
vez de configurar a vari�vel global errno (que � o que muitas fun��es padr�o C fazem quando encontram um erro).

Por exemplo, a fun��o fopen_s retorna um errno_t. Se a fun��o foi bem-sucedida, ela retornar� 0. Caso contr�rio, retornar� um c�digo de erro 
espec�fico.

O errno_t �, em muitos casos, apenas um typedef para int. No entanto, � uma boa pr�tica usar o tipo errno_t quando se trabalha com as
fun��es seguras, pois torna o c�digo mais claro e mostra explicitamente que uma fun��o est� retornando um c�digo de erro, 
e n�o algum outro tipo de valor inteiro.

*/

    errno_t err = fopen_s(&fp, arg, "rb");
    if (err != 0 || fp == NULL) {
        printf("Erro ao abrir a imagem. C�digo de erro: %d\n", err);  // imprime o c�digo de erro
        return 0;
    }

    fillHeader(&bf, fp);

    printf("%s\n", bf.signature);
    printf("%X\n", bf.imageSize);
    printf("%hX\n", bf.reserved1);
    printf("%hX\n", bf.reserved2);
    printf("%X\n", bf.pixelDataOffset);
    // %X � para ler no formato Hexadecimal
    

    fclose(fp);  // sempre feche o arquivo quando terminar de us�-lo

    return 0;
}


