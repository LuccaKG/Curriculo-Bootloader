#include <stdio.h>
#include "BMPconfigs.h"

void fillHeader(BFHeader *bf, FILE *fp) {
	// leremos BitmapFileHeader
	fread(&bf->signature, 2, 1, fp); // fread lê dados binarios de um arquivo
	fread(&bf->imageSize, 4, 1, fp);
	fread(&bf->reserved1, 2, 1, fp);
	fread(&bf->reserved2, 2, 1, fp);
	fread(&bf->pixelDataOffset, 4, 1, fp);
	// note que a cada chamada de fread, ele atualiza o 'cursor' sequencialmente com base no tamanho lido na chamada anterior
	
	// leremos agora BitmapInfoHeader
	fread(&bf->BIHeader.headerSize, 4, 1, fp);
	fread(&bf->BIHeader.imageWidth, 4, 1, fp);
	fread(&bf->BIHeader.imageHeigth, 4, 1, fp);
	fread(&bf->BIHeader.planes, 2, 1, fp);
	fread(&bf->BIHeader.bitsPerPixel, 2, 1, fp);
	fread(&bf->BIHeader.compression, 4, 1, fp);
	fread(&bf->BIHeader.imageRawSize, 4, 1, fp);
	fread(&bf->BIHeader.horizontalResolution, 4, 1, fp);
	fread(&bf->BIHeader.verticalResolution, 4, 1, fp);
	fread(&bf->BIHeader.colorPallete, 4, 1, fp);
	fread(&bf->BIHeader.importantColors, 4, 1, fp);
}

// função que le um bit e retorna se é 1 ou 0 
int checkBit(unsigned char ch, int position) {
	// Utiliza um AND bit a bit entre o byte e uma máscara de bits
	// A máscara é criada deslocando 1 para a posição desejada
	if (ch & (1 << position)) {
		return 1;
	}
	else {
		return 0;
	}
}
