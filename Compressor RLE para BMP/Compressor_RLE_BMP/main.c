#include <stdio.h>
#include <stdlib.h>
#include <math.h>
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
    errno_t err; // variavel que receberá o código de saída do fopen_s após tentativa de abrir o arquivo
    int totalWidth; // calcula o numero de bits necessarios para definir uma linha
    int bytesPerRow; // numero de bytes necessarios para representar uma linha em BMP 
    int x, y; // definindo coordenadas do plano cartesiano para depois percorrer a imagem
    int byteAtual = 0; // variavel auxiliar para anotar posição do byte analisado
    int bitCounter = 0; // variavel auxiliar para ajudar a percorrer bit a bit

    /*
    Para permitir uma execução adequada via terminal, vamos configurar as condições para argc e argv
    */
    if (argc < 2) { // se só tiver um argumento, a imagem comprimida será a padrão
        err = fopen_s(&fp, arg, "rb");
    }
    else { // caso contrario, mesmo que tenham muitos parametros de entrada, trabalharemos no primeiro 
        err = fopen_s(&fp, argv[1], "rb");

    }

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

    if (err != 0 || fp == NULL) {
        printf("Erro ao abrir a imagem. Código de erro: %d\n", err);  // imprime o código de erro
        return 0;
    }

    fillHeader(&bf, fp);

    /*printf("%s\n", bf.signature);
    printf("%X\n", bf.imageSize);
    printf("%hX\n", bf.reserved1);
    printf("%hX\n", bf.reserved2);
    printf("%X\n", bf.pixelDataOffset);*/
    // %X é para ler no formato Hexadecimal

    if (bf.BIHeader.bitsPerPixel != 1) {
        printf("Esse compressor só funciona para imagens monocromáticas!\n");
        fclose(fp);
        return 0;
    } 

    /*
    Para o formato BMP, cada linha deve ocupar um numero de bytes (bytesPerRow) multiplo de 4, algo que nem sempre ocorrerá após o cálculo de 
    'totalWidth'. Assim, se o cálculo nao ocupar um numero de bytes multiplo de 4, preenchemos o que faltar com '0' com a tecnica chamada
    'padding'.
    O calculo de bytesPerRow é dado por: ceil(totalWidth/32) * 4
    */
    totalWidth = bf.BIHeader.bitsPerPixel * bf.BIHeader.imageWidth;
    bytesPerRow = ceil(totalWidth / 32) * 4; 
    /*printf("Largura total: %d\n", bytesPerRow);*/

    /*
    O fseek() é uma função da biblioteca padrão em C (e também em algumas outras linguagens) usada para mudar a posição do indicador de
    arquivo (ou "cursor") de um stream de arquivo. Com o fseek(), você pode mover-se para um ponto específico em um arquivo, 
    o que é útil para ler, escrever ou modificar o arquivo fora da sequência padrão.

    Aqui está a sintaxe do fseek():
    int fseek(FILE *stream, long int offset, int whence);

    stream: É um ponteiro para o arquivo.
    offset: É o número de bytes que você deseja mover a partir da posição especificada por whence.
    whence: É a posição a partir da qual o offset é aplicado. Pode ter um dos seguintes valores:
    SEEK_SET: Começa a mover a partir do início do arquivo.
    SEEK_CUR: Começa a mover a partir da posição atual do cursor no arquivo.
    SEEK_END: Começa a mover a partir do final do arquivo.
    */
    fseek(fp, bf.pixelDataOffset, SEEK_SET); // Utilizamos para posicionar o cursor no ponto em que os dados dos pixels começam a ser
                                               // apresentados (a partir do endereço pixelDataOffset)
    
    // percorrendo a imagem
    for (y = 0; y < bf.BIHeader.imageHeigth; y++) { // percorrendo toda a altura da imagem
        for (x = 0; x < bytesPerRow; x++) { // percorrendo toda a largura da imagem
            fread(&byteAtual, 1, 1, fp);
            for (bitCounter = 7; bitCounter >= 0; bitCounter--) {
                printf("%d\n", checkBit(byteAtual, bitCounter));
            }
        }
    }

    fclose(fp);  // sempre feche o arquivo quando terminar de usá-lo

    return 0;
}


