#include <stdio.h>
#include <stdlib.h>
#include <math.h>
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
    errno_t err; // variavel que receber� o c�digo de sa�da do fopen_s ap�s tentativa de abrir o arquivo
    int totalWidth; // calcula o numero de bits necessarios para definir uma linha
    int bytesPerRow; // numero de bytes necessarios para representar uma linha em BMP 
    int x, y; // definindo coordenadas do plano cartesiano para depois percorrer a imagem
    int byteAtual = 0; // variavel auxiliar para anotar posi��o do byte analisado
    int bitCounter = 0; // variavel auxiliar para ajudar a percorrer bit a bit

    /*
    Para permitir uma execu��o adequada via terminal, vamos configurar as condi��es para argc e argv
    */
    if (argc < 2) { // se s� tiver um argumento, a imagem comprimida ser� a padr�o
        err = fopen_s(&fp, arg, "rb");
    }
    else { // caso contrario, mesmo que tenham muitos parametros de entrada, trabalharemos no primeiro 
        err = fopen_s(&fp, argv[1], "rb");

    }

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

    if (err != 0 || fp == NULL) {
        printf("Erro ao abrir a imagem. C�digo de erro: %d\n", err);  // imprime o c�digo de erro
        return 0;
    }

    fillHeader(&bf, fp);

    /*printf("%s\n", bf.signature);
    printf("%X\n", bf.imageSize);
    printf("%hX\n", bf.reserved1);
    printf("%hX\n", bf.reserved2);
    printf("%X\n", bf.pixelDataOffset);*/
    // %X � para ler no formato Hexadecimal

    if (bf.BIHeader.bitsPerPixel != 1) {
        printf("Esse compressor s� funciona para imagens monocrom�ticas!\n");
        fclose(fp);
        return 0;
    } 

    /*
    Para o formato BMP, cada linha deve ocupar um numero de bytes (bytesPerRow) multiplo de 4, algo que nem sempre ocorrer� ap�s o c�lculo de 
    'totalWidth'. Assim, se o c�lculo nao ocupar um numero de bytes multiplo de 4, preenchemos o que faltar com '0' com a tecnica chamada
    'padding'.
    O calculo de bytesPerRow � dado por: ceil(totalWidth/32) * 4
    */
    totalWidth = bf.BIHeader.bitsPerPixel * bf.BIHeader.imageWidth;
    bytesPerRow = ceil(totalWidth / 32) * 4; 
    /*printf("Largura total: %d\n", bytesPerRow);*/

    /*
    O fseek() � uma fun��o da biblioteca padr�o em C (e tamb�m em algumas outras linguagens) usada para mudar a posi��o do indicador de
    arquivo (ou "cursor") de um stream de arquivo. Com o fseek(), voc� pode mover-se para um ponto espec�fico em um arquivo, 
    o que � �til para ler, escrever ou modificar o arquivo fora da sequ�ncia padr�o.

    Aqui est� a sintaxe do fseek():
    int fseek(FILE *stream, long int offset, int whence);

    stream: � um ponteiro para o arquivo.
    offset: � o n�mero de bytes que voc� deseja mover a partir da posi��o especificada por whence.
    whence: � a posi��o a partir da qual o offset � aplicado. Pode ter um dos seguintes valores:
    SEEK_SET: Come�a a mover a partir do in�cio do arquivo.
    SEEK_CUR: Come�a a mover a partir da posi��o atual do cursor no arquivo.
    SEEK_END: Come�a a mover a partir do final do arquivo.
    */
    fseek(fp, bf.pixelDataOffset, SEEK_SET); // Utilizamos para posicionar o cursor no ponto em que os dados dos pixels come�am a ser
                                               // apresentados (a partir do endere�o pixelDataOffset)
    
    // percorrendo a imagem
    for (y = 0; y < bf.BIHeader.imageHeigth; y++) { // percorrendo toda a altura da imagem
        for (x = 0; x < bytesPerRow; x++) { // percorrendo toda a largura da imagem
            fread(&byteAtual, 1, 1, fp);
            for (bitCounter = 7; bitCounter >= 0; bitCounter--) {
                printf("%d\n", checkBit(byteAtual, bitCounter));
            }
        }
    }

    fclose(fp);  // sempre feche o arquivo quando terminar de us�-lo

    return 0;
}


