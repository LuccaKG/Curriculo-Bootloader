#include <stdio.h>
#include <stdlib.h>
#include "BMPconfigs.h"

BFHeader bf;

/* 
na main abaixo, argc é o Argument-Counter (conta quantos argumentos há na chamada da função via terminal)
e argv[] é a propria lista de argumentos. Exemplo abaixo:

Se você tem um programa chamado prog e você o executa como:

prog arg1 arg2 arg3

Então, dentro do programa:

argc será 4 (inclui a chamada do programa).
argv[0] será "prog".
argv[1] será "arg1".
argv[2] será "arg2".
argv[3] será "arg3".
*/
int main(int argc, char* argv[]) {
    FILE* fp;
    char arg[] = "C:\\Users\\lucca\\OneDrive\\Documentos\\cv.bmp";

    // fopen_s é uma versão mais segura de fopen. Ela tenta abrir o arquivo especificado e retorna 0 em caso de sucesso.
    // Se bem-sucedida, o ponteiro para o arquivo é armazenado na variável fp. "rb' quer dizer que leremos um arquivo binário.
    /*
    Sobre o tipo errno_t:
    errno_t é um tipo de dado definido na linguagem C (especialmente no ambiente Microsoft quando se usa o MSVC) para representar códigos de erro.

Ele é frequentemente utilizado com funções seguras (as que têm o sufixo _s), que são uma extensão da biblioteca C padrão criada para abordar
preocupações comuns de segurança relacionadas a buffer overflows e outros tipos de vulnerabilidades. Estas funções retornam um valor errno_t em 
vez de configurar a variável global errno (que é o que muitas funções padrão C fazem quando encontram um erro).

Por exemplo, a função fopen_s retorna um errno_t. Se a função foi bem-sucedida, ela retornará 0. Caso contrário, retornará um código de erro 
específico.

O errno_t é, em muitos casos, apenas um typedef para int. No entanto, é uma boa prática usar o tipo errno_t quando se trabalha com as
funções seguras, pois torna o código mais claro e mostra explicitamente que uma função está retornando um código de erro, 
e não algum outro tipo de valor inteiro.

*/

    errno_t err = fopen_s(&fp, arg, "rb");
    if (err != 0 || fp == NULL) {
        printf("Erro ao abrir a imagem. Código de erro: %d\n", err);  // imprime o código de erro
        return 0;
    }

    fillHeader(&bf, fp);

    printf("%s\n", bf.signature);
    printf("%X\n", bf.imageSize);
    printf("%hX\n", bf.reserved1);
    printf("%hX\n", bf.reserved2);
    printf("%X\n", bf.pixelDataOffset);
    // %X é para ler no formato Hexadecimal
    

    fclose(fp);  // sempre feche o arquivo quando terminar de usá-lo

    return 0;
}


