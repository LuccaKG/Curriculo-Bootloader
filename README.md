# Curriculo-Bootloader [em desenvolvimento]
Para praticar os estudos de arquivos poliglotas, criei um arquivo que tanto pode ser lido como .pdf - contendo meu currículo - quanto executado como um bootloader, apresentando uma imagem monocromática .bmp junto de uma mensagem.

## Estrutura BMP

Inicialmente, busquei entender como é estruturado o formato .bmp, entendendo a informação contida em cada offset de memória, dispostos conforme abaixo:


### File header

Este bloco de bytes está no início do arquivo e é usado para identificar o arquivo. Uma aplicação típica lê este bloco primeiro para garantir que o arquivo 
seja realmente um arquivo BMP e que não esteja danificado. Os primeiros 2 bytes do formato de arquivo BMP são o caractere "B" seguido do caractere "M" em codificação ASCII. Todos os valores inteiros são 
armazenados no formato little-endian (ou seja, byte menos significativo primeiro).

![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/78266633-337d-481e-897e-7590c6511167)

### Info header
![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/dd5449b3-747f-4e39-a41f-28831f9b8612)

Para mais informações sobre os atributos listados, acesse: https://en.wikipedia.org/wiki/BMP_file_format

## Compressão RLE (Run-Length Encoding)

De posse deste conhecimento, construí em C um programa compressor RLE, uma vez que esse método de compressão é muito eficiente para arquivos com significativas repetições de sequências, como
é o caso de uma imagem monocromática .bmp.


RLE é um método de compressão sem perda de dados que codifica o arquivo de acordo com as repetições de dados presentes. Por exemplo, imagine uma imagem monocromática de dimensões 1x10, onde cada pixel é
representado por um rótulo que pode ser 'B' (branco) ou 'P' (preto) e estão distribuidos conforme abaixo:

<pre>
<div align="center">BBBBPPPBBB</div>
</pre>

Utilizando RLE, podemos codificar essa imagem como:

<pre>
<div align="center">4B3P3B</div>
</pre>

O que representa uma taxa de compressão de 40%. Para arquivos maiores, essa taxa pode chegar a valores altíssimos! Todavia, um arquivo que não seja representado por dados que contenham grandes cadeias de repetições não é adequado para o algoritmo RLE e pode inclusive ter seu tamanho aumentado.

