#pragma once /* essa diretiva faz com que esse header seja compilado apenas uma vez, mesmo que seja incluido em outros arquivos
posteriormente. Torna a compilação mais eficiente*/
#include <stdio.h>

/* 
O BITMAPINFOHEADER é uma estrutura que descreve as características dimensionais e de cores da imagem em um arquivo BMP (Bitmap). 
Ele vem imediatamente após o BITMAPFILEHEADER no formato BMP.
*/
struct BitmapInfoHeader {
	unsigned int headerSize; // tamanho do header. TEM que ser 0x28 ou 40 [decimal]. Offset 0x0E
	unsigned int imageWidth; // largura da imagem (em pixels). Offset 0x12
	unsigned int imageHeigth; // altura da imagem (em pixels). Offset 0x16
							/* note que, pela spec do formato BMP, altura e largura podem sim ser valores negativos, porém
							como utilizarei para um projeto especifico e conhecido, utilizarei certamente
							valores positivos */
	unsigned short planes; // numero de planos de cores. TEM que ser = 1. Offset 0x1A
	unsigned short bitsPerPixel; // numero de bits por pixel (color depth). Como trabalharemos com imagem monocromatica, o valor será 1. Offset 0x1C
	unsigned int compression; // tipo de compressão, costumeiramente = 0. Offset 0x1E
	unsigned int imageRawSize; // tamanho 'cru' da imagem. Pode ser 0. Offset 0x22
	unsigned int horizontalResolution; // Pixel por metro. Pode ser negativo. Offset 0x26
	unsigned int verticalResolution; // Pixel por metro. Pode ser negativo. Offset 0x2A
	unsigned int colorPallete; // numero de cores na paleta. Costumeiramente = 0. Offset 0x2E
	unsigned int importantColors; // numero de cores importantes. Costumeiramente = 0. Offset 0x32
};	

/*
O file header de um arquivo BMP (Bitmap) é a parte inicial do arquivo que contém informações meta sobre a imagem. 
Ele é usado para identificar o arquivo e descrever sua estrutura. 
*/
struct BitmapFileHeader {
	unsigned char signature[2]; // Assinatura do formato. Endereço offset 0x00 ocupando 2 bytes (cada char ocupa 1 byte)
	unsigned int imageSize; // Tamanho do arquivo. Offset 0x02 (int ocupa 4 bytes)
	short reserved1; // 2 bytes reservados. Offset 0x06
	short reserved2; // 2 bytes reservados. Offset 0x08
	unsigned int pixelDataOffset; // Armazena o endereço onde começarão as infos sobre os pixels da imagem. Localizado no offset 0x0A
	struct BitmapInfoHeader BIHeader; // recebe os parametros do infoHeader, que ocuparão os offsets seguintes
};

typedef struct BitmapFileHeader BFHeader; // 'apelido' 
typedef struct BitmapInfoHeader BIHeader; // 'apelido' 

/* 
Função que preencherá os headers. Recebe um ponteiro para o FileHeader e a imagem analisada
*/
void fillHeader(BFHeader* bf, FILE* fp); // função aqui declarada, mas sera definida num arquivo bmp.c
int checkBit(unsigned char *ch, int position);// Função que percorrerá cada bit de um byte e retornará um int dizendo se o bit é 0 ou 1
