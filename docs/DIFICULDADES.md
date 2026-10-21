# Dificuldades Encontradas — hs2json

## 1. Incompatibilidade de versões do GHC

**Problema:** Durante a configuração inicial do ambiente, o comando `cabal build` apresentou um erro de resolução de dependências. O arquivo `cabal.project.freeze` exigia a biblioteca `base` na versão 4.17.2.1, incompatível com o compilador inicialmente instalado.

**Solução:** Foi utilizado o GHCup para instalar e ativar a versão 9.4.8 do GHC, permitindo a compilação do projeto sem alterar suas dependências.

**Aprendizado:** Compreendemos a importância da compatibilidade entre compilador, bibliotecas e dependências em projetos Haskell.

## 2. Funções não implementadas (`undefined`)

**Problema:** Durante os testes da função `getBool`, encontramos a exceção `Prelude.undefined`, pois a implementação ainda estava pendente.

**Solução:** Substituímos o `undefined` pelas implementações com casamento de padrões (*pattern matching*) e recarregamos o GHCi utilizando `:r`.

**Aprendizado:** Entendemos que um programa Haskell pode compilar mesmo contendo `undefined`, mas a execução dessas expressões provoca erros.

## 3. Problemas com importação de módulos

**Problema:** Ao testar a função `renderJValue` no GHCi, recebemos o erro `Variable not in scope`.

**Solução:** Importamos o módulo `PutJSON`, disponibilizando a função no ambiente interativo.

**Aprendizado:** Aprendemos como funciona a organização e a importação de módulos em Haskell.

## 4. Erros de sintaxe no GHCi

**Problema:** Ao tentar executar expressões JSON em várias linhas, o interpretador apresentou erros como `parse error on input ','`.

**Solução:** Utilizamos expressões em uma única linha e os comandos `:{` e `:}` para permitir entradas multilinhas.

**Aprendizado:** Compreendemos melhor as diferenças entre escrever código em arquivos Haskell e executá-lo diretamente no GHCi.

## 5. Controle da recursividade no QuickCheck

**Desafio:** A geração de valores JSON aleatórios exigiu atenção especial, pois arrays e objetos podem conter outros valores JSON, criando estruturas recursivas.

**Solução:** Implementamos o gerador utilizando `sized`, `resize` e redução do tamanho recursivo por meio de `n div 2`.

**Validação:** Executamos um teste de estresse com 1.000 execuções, concluído com sucesso.

**Aprendizado:** Entendemos a importância de controlar o tamanho dos dados gerados para evitar consumo excessivo de memória.

## 6. Warning de importação redundante

**Problema:** Durante a implementação das propriedades de teste, o compilador apresentou um aviso `-Wunused-imports`, indicando que uma importação do módulo `Test.QuickCheck.All` era redundante.

**Solução:** Removemos a importação desnecessária e executamos novamente os testes.

**Aprendizado:** Aprendemos a interpretar avisos do compilador e melhorar a organização do código.

## Considerações finais

O desenvolvimento do projeto hs2json proporcionou uma aplicação prática de conceitos de Programação Funcional, como casamento de padrões, tipos algébricos, recursividade e testes automatizados.

As dificuldades encontradas foram importantes para compreender melhor o funcionamento do Haskell e desenvolver habilidades de depuração, organização de código e utilização de ferramentas como Git, Cabal, GHCi e QuickCheck.