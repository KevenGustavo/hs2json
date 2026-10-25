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

## 7. Ambiguidade e conflito do operador `(<>)` com o `Prelude` moderno

**Problema:** No livro *Real World Haskell*, o operador de concatenação `<>` pertencia exclusivamente à biblioteca `Prettify`. No entanto, em versões modernas da biblioteca `base` do Haskell (GHC 9.4+), o operador `<>` foi promovido para o `Prelude` como parte da typeclass `Semigroup`. Isso gerou erros de compilação por ambiguidade de escopo nos módulos `Prettify.hs` e `PrettyJSON.hs`.

**Solução:** Adicionamos explicitamente a diretiva `import Prelude hiding ((<>))` no topo de todos os módulos que manipulam a álgebra de documentos `Doc`.

**Aprendizado:** Compreendemos a evolução histórica do ecossistema Haskell e como a promoção de abstrações algébricas (`Semigroup` e `Monoid`) para o `Prelude` exige atenção ao portar códigos legados para compiladores modernos.

## 8. Codificação de caracteres do Plano Astral em Pares Substitutos UTF-16 (RFC 8259)

**Problema:** A especificação RFC 8259 estabelece que caracteres Unicode fora do *Basic Multilingual Plane* (pontos de código $> 0xFFFF$, como o emoji 🚀 `U+1F680`) não podem ser serializados com escapes simples de 4 dígitos, exigindo a divisão obrigatória em dois valores UTF-16 de 16 bits (pares substitutos: *lead* e *trail surrogate*). O Haskell trata `String` como listas de `Char` de 32 bits, sem decomposição automática.

**Solução:** Implementamos a função `astral` no módulo `PrettyJSON.hs` utilizando manipulação binária com a biblioteca `Data.Bits`. Subtraímos `0x10000` do ponto de código e usamos deslocamento de 10 bits à direita (`shiftR 10`) com máscara bit a bit `.&. 0x3ff` para compor o par alto (offset `0xD800`) e o par baixo (offset `0xDC00`).

**Aprendizado:** Aprofundamos o conhecimento em aritmética de bits em Haskell funcional puro e dominamos as regras estritas de codificação de caracteres do padrão Unicode e da especificação JSON.

## 9. Falha de modelo no teste de `punctuate` contra `intersperse`

**Problema:** No Capítulo 8 do tutorial, a tentativa de validar a função `punctuate` comparando sua saída diretamente com a função padrão `intersperse` sobre listas falhou no QuickCheck. O gerador produziu contraexemplos contendo o documento vazio `Empty`.

**Solução:** Investigando a causa da falha, identificamos que o operador `<>` da `Prettify` realiza uma simplificação algébrica em tempo de construção eliminando nós `Empty` ($Empty <> x = x$), enquanto o `intersperse` de listas mantém todos os elementos vazios. Desenvolvemos o modelo normalizador `combine` em `test/DocProps.hs` para reconciliar as listas antes da comparação.

**Aprendizado:** Compreendemos que testes baseados em propriedades usando oráculos ou modelos de lista exigem que o modelo reflita com exatidão as invariantes algébricas da estrutura testada.

## 10. Discrepância entre "Testes 100% Verdes" e Cobertura Real no HPC

**Problema:** Após a escrita da primeira suíte de testes com QuickCheck, todos os testes passavam com 100% de sucesso. No entanto, ao gerar o relatório com Haskell Program Coverage (`cabal test --enable-coverage`), descobrimos que funções centrais de layout da biblioteca (`fits`, `pretty`, `nicest`, `compact`) possuíam cobertura inferior a 20%, pois os testes cobriam apenas construtores da árvore sem exercitar a renderização de strings.

**Solução:** Criamos propriedades invariantes adicionais em `test/PrettyProps.hs` focadas na saída renderizada, como a verificação de largura máxima e a propriedade `prop_pretty_vs_compact_tokens` (que garante equivalência de tokens entre `compact` e `pretty 80`), elevando a cobertura final para 97% a 100%.

**Aprendizado:** Aprendemos na prática que uma suíte com 100% de aprovação pode esconder grandes lacunas de teste se não for auditada por métricas de cobertura estrutural de código como o HPC.

## Considerações finais

O desenvolvimento do projeto hs2json proporcionou uma aplicação prática e aprofundada de conceitos fundamentais da Programação Funcional:
- Modelagem de dados expressiva com tipos algébricos e casamento de padrões;
- Tratamento seguro de ausência de dados e erros via tipo `Maybe`;
- Álgebra de combinadores de documentos para pretty printing com algoritmos de layout adaptativo;
- Manipulação binária de baixo nível para conformidade rigorosa com normas internacionais (RFC 8259);
- Verificação formal baseada em propriedades matemáticas com QuickCheck;
- Auditoria de qualidade e completude com relatórios de cobertura do HPC.

A divisão do trabalho em duas trilhas complementares (Leonardo na modelagem e testes básicos; Keven na álgebra de layout, escapes complexos e cobertura avançada) permitiu superar desafios técnicos reais de engenharia de software funcional e consolidar um repositório robusto, modular e com zero advertências do compilador.