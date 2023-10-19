# Currículo-Bootloader [em desenvolvimento]
Para praticar os estudos de arquivos poliglotas, criei um arquivo que tanto pode ser lido como .pdf - contendo meu currículo - quanto executado como um bootloader, apresentando uma imagem monocromática .bmp junto de uma mensagem.

## Estrutura Bootloader 🚀

### Bootloader:
Um bootloader é um software crucial que é executado cada vez que um computador ou dispositivo é ligado. Ele inicializa o hardware e carrega o sistema operacional na memória RAM, preparando o sistema para operar corretamente. Uma característica importante é que, para ser reconhecido pela BIOS durante o processo de inicialização, o bootloader deve estar localizado no Master Boot Record (MBR) de um dispositivo de armazenamento e ter exatamente 512 bytes.

### Master Boot Record (MBR):
O MBR é o primeiro setor de um dispositivo de armazenamento e contém o bootloader e a tabela de partições do disco. Ele desempenha um papel fundamental no processo de inicialização, uma vez que a BIOS ou o firmware UEFI leem o MBR para encontrar o bootloader e dar início ao processo de carregamento do sistema operacional.

### Interrupções Assembly na BIOS:
As interrupções em Assembly são mecanismos que facilitam a comunicação entre o software e o hardware, em particular com a BIOS (Sistema Básico de Entrada e Saída).

***Texto:*** Por meio da interrupção int 0x10, podemos realizar várias operações relacionadas à exibição de vídeo, incluindo escrever caracteres na tela.

***Imagem:*** A mesma interrupção int 0x10 pode ser empregada para configurar modos gráficos e controlar a apresentação de pixels, possibilitando a exibição de imagens.

#### Exemplo Assembly

<table align="center">
<tr>
<td>

```assembly
; Exemplo para exibir um caractere na tela
mov ah, 0x0E ; Define a função de escrita de caractere
mov al, 'A'  ; Especifica o caractere a ser mostrado
int 0x10     ; Invoca a interrupção para exibir o caractere
```
</td>
</tr>
</table>

Mais informações sobre interrupções na BIOS podem ser acessadas em: http://www.x-hacker.org/ng/bios/ng1d0.html

### Bootloader Multistage

Como a representação de texto + imagem ultrapassará os 512 bytes limitantes, precisaremos utilizar o método de Bootloader Multistage.


Um bootloader multistage (ou multietapa) refere-se a um processo de inicialização em que a sequência de boot é dividida em várias fases ou etapas, com cada fase sendo responsável por uma tarefa específica no processo de inicialização. Esta abordagem é frequentemente usada porque o primeiro estágio do bootloader tem restrições de tamanho e, por isso, pode não ser capaz de conter todo o código necessário para inicializar completamente um sistema.

Vamos detalhar um pouco mais sobre essa abordagem:

#### Primeira etapa (ou primeiro estágio):

Localizado no Master Boot Record (MBR) ou em um espaço de inicialização similar.
Devido à restrição de tamanho (o MBR tem apenas 512 bytes), este estágio geralmente contém apenas código suficiente para carregar o próximo estágio do bootloader.
Identifica e carrega o segundo estágio do bootloader de uma localização específica no disco.


#### Segunda etapa (ou segundo estágio):

Localizado em uma região mais flexível do disco.
Tem mais espaço e, portanto, pode realizar tarefas mais complexas, como identificar e carregar um sistema operacional específico, configurar o hardware necessário ou até mesmo exibir um menu para o usuário escolher entre múltiplos sistemas operacionais.
Pode também, em alguns sistemas, ter um terceiro estágio ou mais, caso a complexidade do processo de inicialização o exija.
Um exemplo clássico de um bootloader multistage é o GRUB (GRand Unified Bootloader). No primeiro estágio, o GRUB simplesmente identifica e carrega o próximo estágio do bootloader. No segundo estágio, ele pode apresentar um menu ao usuário para escolher um sistema operacional, inicializar esse sistema operacional, entre outras tarefas.

A abordagem multistage permite uma maior flexibilidade e modularidade na inicialização, pois cada estágio pode ser otimizado para uma tarefa específica, sem sobrecarregar ou complicar excessivamente qualquer estágio individual. Utilizaremos o sistema de arquivos ***FAT12*** - comumente usado em disquetes e algumas partições de inicialização - para armazenar o bootloader. 


## Estrutura BMP 🖼️

Inicialmente, busquei entender como é estruturado o formato .bmp, entendendo a informação contida em cada offset de memória, dispostos conforme abaixo:


### File header

Este bloco de bytes está no início do arquivo e é usado para identificar o arquivo. Uma aplicação típica lê este bloco primeiro para garantir que o arquivo 
seja realmente um arquivo BMP e que não esteja danificado. Os primeiros 2 bytes do formato de arquivo BMP são o caractere "B" seguido do caractere "M" em codificação ASCII. Todos os valores inteiros são 
armazenados no formato little-endian (ou seja, byte menos significativo primeiro).

![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/78266633-337d-481e-897e-7590c6511167)

### Info header
![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/dd5449b3-747f-4e39-a41f-28831f9b8612)

Para mais informações sobre os atributos listados, acesse: https://en.wikipedia.org/wiki/BMP_file_format

## Compressão RLE (Run-Length Encoding) 📦

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

