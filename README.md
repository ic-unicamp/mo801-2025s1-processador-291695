# Projeto de um processador RISC-V multiciclo

Nesse projeto, os alunos desenvolverão um processador RISC-V simples multiciclo. A intenção principal é dominar questões básicas do desenvolvimento de hardware, como a definição de um conjunto de instruções, a implementação da máquina de estados de um processador multiciclo e a verificação do funcionamento do processador.

## Objetivos

1. Implementar um processador RISC-V simples multiciclo em Verilog sintetizável. 
2. Implementar um conjunto de testes para verificar o funcionamento do processador.
3. Executar programas implementados em C no processador.

## Especificação

Seu processador deve implementar as instruções RV32I, que é o conjunto mais simples de instruções RISC-V. A implementação deve ser multiciclo, ou seja, cada instrução pode levar um número diferente de ciclos de clock para ser executada. Você pode se inspirar na implementação multiciclo do livro "Computer Organization and Design" de David Patterson e John Hennessy.

Você pode utilizar um toolchain pronto ou montar o seu próprio toolchain ([dica de geração](https://github.com/riscv-collab/riscv-gnu-toolchain)). Alternativamente, para esse primeiro trabalho, você pode utilizar um [montador online](https://riscvasm.lucasteske.dev) (existem outros, fique à vontade para utilizar o que achar mais conveniente).

Como método de encerramento do programa, você pode utilizar a instrução *ebreak*, que encerra o simulador.

Seu código deve ser sintetizávelvel, isso significa que deve ser possível gerar um circuito lógico a partir do seu código. A verificação será feita através do iverilog.

## Algumas informações extras

* Você pode criar novos arquivos, o script de execução está configurado para compilar todos os arquivos .v presentes no diretório.
* Vocë pode criar novos testes, utilize a nomenclatura dos arquivos da pasta *test*: Crie um arquivo testeNN.mem que contém o mapa de memória com as instruções a executar e os dados necessários; Crie um arquivo chamado saidaNN.ok que contém a saída experada do teste. O script run-all.sh irá executar cada um dos testes e também comparar com o arquivo de saída esperada.
* Seu código está sendo simulado com o iverilog. É importante que seu código seja sintetizável.
* Leia o arquivo de testbench (tb.v) para entender o funcionamento do teste, veja os comentários do arquivo. Em especial, merecem destaque: 1) Toda simulação começa com um reset; 2) A simulação pode parar se forem alcançadas 4000 unidades de tempo (2000 ciclos de clock) ou se a instrução *ebreak* for executada ou se for feito algum acesso à posição de memória 4092, que é a última palavra existente na memória declarada. Qualquer um desses métodos é suficiente para encerrar a simulação.
* O testbench também monitora todos os acessos à memória que tiverem o bit 11 do endereço com valor 1. Esses acessos são impressos na tela.

## Entrega

Você deve entregar o seu projeto através do Github Classroom, bastando fazer um *commit* e *push* do seu código. os testes serão executados automaticamente. A data limite para entrega é o último dia do mês.

Seu código será avaliado com mais testes do que os que estão dispnoíveis aqui.

## Problemas identificados na execução

1. PC = PC + 4: O próximo endereço é calculado, ele chega a ser armazenado em ALUResult, mas, por algum motivo, não reflete em PC. Os sinais para propagação desse sinal para PC estão todos corretos e ResultSrc[1:0] está correto também, mas acaba que o registrador do PC nunca recebe o valor e o próximo endereço nunca é chamado.
2. Para a operação BEQ, a unidade de controle precisa "receber" o sinal zero como 1 para definir pcwrite = 1. Porém, precisaria de mais um ciclo para concluir essa operação e Zero recebe 1 na hora em que o estado muda para Fetch.

## Execução correta

Como não é possível checar a execução completa de um conjunto de instruções, apenas validei algumas operações que estão listadas a seguir:

1. addi (7d008113)
2. add (000000b3)
3. beq (00000a63)
4. lw (00002083) - tentei validar essa operação, mas não consigo ter certeza dos resultados e ciclos, apenas dos sinais de controle.

## Dificuldades gerais

1. Ainda não entendi ao certo como fica a memória de instruções e dados. Entendo que o professor disponibilizou um módulo referente a memória que tem as funcionalidades de leitura e escrita e que isso deveria bastar, mas não estou entendendo como conectar os sinais de address, data_in e data_out de forma coerente no circuito. Criei um módulo individual para cada parte do processador usando a nomenclatura disponibilizada no livro. De forma geral, ficou clara a conexão de fios e módulos, exceto desses relacionados à memória.

2. Não entendi também como deveria funcionar os tempos de ciclos, tentei seguir de forma fiel a descrição e ilustrações do livro, mas ainda assim, para algumas instruções, como expliquei acima, pareceu faltar um ciclo para completar a operação.