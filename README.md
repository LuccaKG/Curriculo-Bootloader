# Currículo-Bootloader 
Para praticar os estudos de arquivos poliglotas, criei um arquivo que tanto pode ser lido como .pdf - contendo meu currículo - quanto executado como um bootloader, apresentando uma imagem monocromática .bmp de resolução 320x200 junto de uma mensagem. O bootloader será armazenado em disquete utilizando o sistema de arquivos FAT12 e operará em arquitetura x86 modo-real.

### Bootloader
![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/cf41fa11-aeef-4bb6-b9c9-e779bde306a8)

## Como utilizar o projeto

### Gerando Bootloader

- [x] Tenha em mãos a imagem monocromática em formato .bmp que deseja utilizar (não utilize imagens com sequências >= 255 pixels iguais antes do final da representação da imagem, conforme detalhado no tópico *Possíveis melhorias 🔍*)
- [x] Abra o terminal no path "Curriculo Bootloader\Compressor RLE para BMP\Compressor_RLE_BMP\x64\Debug\" e execute "Compressor_RLE_BMP.exe <picture_path>" para comprimir sua imagem. A saída deve ser algo no formato abaixo

     ![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/5aeb86ac-0ced-48e2-a511-ba06672b53fb)
- [x] Copie a saída e adicione depois do último valor o número 255, que será útil para o funcionamento da lógica em Assembly que gerará o binário bootloader
- [x] Abra o script "Curriculo Bootloader\Bootloader\Bootloader.asm" com o editor de texto de sua preferência
- [x] Modifique *OEMname* e *volumeLabel* conforme sua preferência para identificação do projeto

     ![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/7c83082d-fa88-4284-8662-631a49b43e70)
- [x] No trecho de definição de variáveis, modifique a mensagem conforme queira
      
     ![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/6f648956-746e-4bc1-a6c5-61245e059378)
- [x] No final do código, na definição de *dados*, substitua com seus respectivos dados de compressão copiados anteriormente. Note que o script foi implementado para representar a imagem byte a byte, por isso
      cada sequência é representada por um dado do tipo *db*, o que justifica a 2ª instrução pedindo para evitarmos imagens com sequências de pixels >= 255 antes do final da representação
      
     ![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/f831ab08-f434-48c4-b029-54fcf660a8f6)
- [x] Se desejar, faça as alterações necessárias na cor da fonte, do fundo etc
- [x] Após essas alterações, salve o arquivo e faça a montagem utilizando o FASM ou qualquer assembler de sua preferência, gerando um arquivo .bin
- [x] Utilize o .bin gerado como bootloader em sua máquina física ou virtual. Atente-se ao fato de que o bootloader foi programado para ser armazenado em um disquete (floppy). 

### Injetando código Bootloader no PDF

Dividiremos o código assembly para bootloader que desenvolvemos anteriormente em 2:

- [x] Primeira parte contendo as definições do FAT12
- [x] Segunda parte contendo o bootloader de fato
      
Como a maioria dos leitores de PDF (incluindo o Adobe Reader) permite a inserção de alguns poucos bytes antes do cabeçalho sem comprometer a leitura, é lá que posicionaremos as definições do FAT12. Depois, já abaixo do cabeçalho do PDF, criaremos um objeto stream que abrigará todo o resto do bootloader. 

#### Inserindo a configuração FAT12 antes do cabeçalho PDF

Faremos essa alteração utilizando o editor Hexadecimal HxD. Como é possível ver na coluna "Texto decodificado", toda a configuração FAT12 foi posicionada antes do cabeçalho *%PDF-1.5*.

![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/d9d6620b-e0d8-4b41-a550-102782c96234)

#### Inserindo demais partes do Bootloader como objeto stream no PDF

Primeiro, editando o arquivo PDF com o Notepad++, adicionamos um dicionario vazio <<>> e em seguida criamos um objeto stream após o cabeçalho. Seu index será 47, pois o PDF já contava com objetos numerados de 0 a 46.

![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/c252a4d3-315f-4333-8d18-88582e6ab237)

Note que é possível ver a inserção feita anteriormente da configuração FAT12.

Feito isso, com auxílio do HxD, conseguimos copiar os valores hexadecimais correspondentes aos trechos de código do bootloader (Bootloader.bin) e inserir no PDF entre o trecho onde a coluna "Texto decodificado" aponta o início (stream) e o fim do objeto stream (endstream), como é de nosso interesse. É importante notar que a primeira linha do código assembly é um *jmp main* e pelo HxD é possível ver que ele aponta para o início do código Bootloader. Com essas modificações no PDF, talvez este endereço apontado precise ser corrigido via HxD - é também pertinente frisar que devemos fazer com que esse valor aponte para (endereço início do bootloader - 2 bytes), por conta do deslocamento relativo levando em consideração o espaço ocupado pela própria instrução *jmp*.

Nesta etapa fica evidente a importância do operador "nop" repetido no início do código assembly a fim de garantir o alinhamento do fluxo de execução, uma vez que entre a configuração FAT12 e o início do Bootloader agora existe uma série de bytes relativos ao PDF; ou seja, ele ajudou funcionando como um marcador de onde seriam colocados os bytes relacionados ao PDF.

![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/e0e98077-cb0c-4e27-bd0d-885e9382bde9)

**E pronto! Agora já é possível utilizar o mesmo arquivo para ser lido como um .pdf ou executado como um Bootloader** 🥳 🚀 📄

## Estrutura Bootloader 🚀

### Bootloader
Um bootloader é um software crucial que é executado cada vez que um computador ou dispositivo é ligado. Ele inicializa o hardware e carrega o sistema operacional na memória RAM, preparando o sistema para operar corretamente. Uma característica importante é que, para ser reconhecido pela BIOS durante o processo de inicialização, o bootloader deve estar localizado no Master Boot Record (MBR) de um dispositivo de armazenamento e ter exatamente 512 bytes.

### Master Boot Record (MBR)
O MBR é o primeiro setor de um dispositivo de armazenamento e contém o bootloader e a tabela de partições do disco. Ele desempenha um papel fundamental no processo de inicialização, uma vez que a BIOS ou o firmware UEFI leem o MBR para encontrar o bootloader e dar início ao processo de carregamento do sistema operacional.

### Interrupções Assembly na BIOS
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

#### Primeira etapa (ou primeiro estágio)

Localizado no Master Boot Record (MBR) ou em um espaço de inicialização similar.
Devido à restrição de tamanho (o MBR tem apenas 512 bytes), este estágio geralmente contém apenas código suficiente para carregar o próximo estágio do bootloader.
Identifica e carrega o segundo estágio do bootloader de uma localização específica no disco.


#### Segunda etapa (ou segundo estágio)

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

## Estrutura PDF 📄

Um arquivo PDF (Portable Document Format) é composto de uma série de objetos que definem seu conteúdo e apresentação. Esses objetos podem ser:

* Objetos Simples: Números, strings, arrays, etc.
* Objetos de Dicionário: Contêm informações sobre o documento e suas páginas.
* Objetos de Stream: Contêm dados grandes, como imagens ou conteúdo de página.
* Objetos Indiretos: Usados para referenciar outros objetos.
* Tabela Xref: Uma tabela de referência cruzada que permite ao leitor acessar rapidamente qualquer objeto no PDF.
* Trailer: Contém um dicionário com referências ao catálogo e à tabela Xref.
* Além disso, cada PDF começa com um cabeçalho que indica a versão do PDF.

### Arquivos Poliglotas e PDFs

Arquivos poliglotas são arquivos que são válidos em mais de um formato de arquivo. No contexto dos PDFs, os arquivos poliglotas foram explorados para embutir conteúdo malicioso que pode ser executado em certas circunstâncias.

Uma das maneiras pelas quais os invasores tentaram injetar código em arquivos PDF foi inserindo bytes entre a versão do PDF e o cabeçalho. A especificação do PDF é bastante flexível, e muitos leitores de PDF eram tolerantes a conteúdos adicionais ou irregularidades na estrutura do arquivo. Isso permitiu que invasores inserissem código ou outros dados em lugares que, tecnicamente, não deveriam afetar a leitura do PDF. Se o software que estava lendo o PDF não processasse esses bytes adicionais de maneira segura, ele poderia ser explorado.

Com o tempo, muitos desses vetores de ataque foram mitigados à medida que os leitores de PDF se tornaram mais rigorosos na maneira como interpretam e processam arquivos, e as vulnerabilidades específicas foram corrigidas. 

## Possíveis melhorias 🔍

Como fazemos a análise byte a byte de cada linha da imagem no código Assembly, trabalhamos com o tipo de variável 'db' para armazenar as sequências de pixels iguais da compressão RLE:

![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/a2650f6e-0821-4f80-ab07-af25dd8f4620)

Utilizar variáveis do tipo 'dw' (ou maior) distorceria essa análise byte a byte - esse é o motivo de, no código do compressor RLE em C, descartarmos sequências >= 255. Todavia, como encerramos a execução do programa quando tais sequências longas aparecem, precisamos utilizar fotos que não apresentem sequências tão extensas intermediárias, pois a compressão se encerraria antes da conclusão real da codificação da imagem.

![image](https://github.com/LuccaKG/Curriculo-Bootloader/assets/122898459/ea198092-9bac-464b-929c-c2e0a850e523)

Uma possível solução para conseguirmos representar qualquer imagem sem essa preocupação é alterar o script RLE em C para quebrar sequências longas em duas; por exemplo, uma sequência de 280 pixels pretos poderia ser codificada como 255 + 25. Para isso seria necessário, além da quebra, a implementação de uma sinalização para diferenciar sequências adjacentes que sejam ou não representantes de mudanças de cor dos pixels. Além disso, seria necessário também adaptar a lógica implementada em Assembly para levar em consideração tais sinalizações na representação da imagem.





