# hs2json

> 🎥 **Vídeo de apresentação:** [Assistir no YouTube](https://youtu.be/2yAba-uxtFU) 
>
> Demonstração do funcionamento do projeto, da arquitetura,
> dos testes automatizados e das dificuldades encontradas.

Biblioteca Haskell desenvolvida para representar dados JSON (`JValue`), serializá-los com formatação legível através de uma biblioteca própria de *pretty printing* (`Prettify`) e validar propriedades e invariantes via **QuickCheck**.

Projeto desenvolvido para a disciplina de **Programação Funcional**, pela dupla [**Keven Gomes**](https://github.com/KevenGustavo) e [**Leonardo Ferreira**](https://github.com/leonardo-ferreira16).

## Sumário

- [Requisitos e instalação](#️-requisitos-e-instalação)
- [Como executar](#-como-executar-o-projeto)
- [Arquitetura](#-arquitetura-do-projeto)
- [Exemplos de saída](#exemplos-de-saída)
- [Testes automatizados e cobertura](#testes-automatizados)
- [Principais dificuldades](#-principais-dificuldades)
- [Histórico de commits e divisão do trabalho](#-histórico-de-commits-e-divisão-do-trabalho)
- [Autores](#-autores)

---

## 🛠️ Requisitos e Instalação

### 1. Dependências do Sistema Operacional (Linux / Ubuntu / Debian)
Para compilar o GHC e linkar bibliotecas de precisão e runtime, instale os seguintes pacotes do sistema:

```bash
sudo apt update
sudo apt install -y build-essential curl libffi-dev libffi8 libgmp-dev libgmp10 libncurses-dev pkg-config zlib1g-dev git
```

> **Atenção:** O pacote `libgmp-dev` é mandatório para compilar programas em Haskell (suporte a GMP/inteiros de precisão arbitrária). Sem ele, o linker reportará erro `cannot find -lgmp`.

### 2. Instalação da Toolchain Haskell (GHCup)
A forma recomendada e padrão oficial para instalar o compilador (**GHC**) e o gerenciador de pacotes/build (**Cabal**) é via **GHCup**:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
```
Durante a instalação:
- Aceite os caminhos padrão (`~/.ghcup`).
- Quando perguntado sobre o **Stack**, responda **N** (não será utilizado).
- Quando perguntado sobre o **HLS** (Haskell Language Server), responda **S** (útil para VS Code / editores).

Após concluir, feche e reabra o terminal (ou execute `source ~/.ghcup/env`) e confirme as versões:
```bash
ghc --version      # versão testada: 9.4.8 (9.4.x ou superior)
cabal --version    # cabal-install version 3.x ou superior
```

> O arquivo `cabal.project.freeze` fixa a versão de `base` em 4.17.2.1, que corresponde ao **GHC 9.4.8**. Se usar outra versão do GHC, instale a 9.4.8 com `ghcup install ghc 9.4.8 && ghcup set ghc 9.4.8`.

### 3. Dependências Haskell do Projeto
As dependências do ecossistema Haskell são gerenciadas e resolvidas automaticamente pelo Cabal (`hs2json.cabal`):
- `base >= 4.14 && < 5`
- `QuickCheck` (para a suíte de testes baseada em propriedades)

As versões exatas ficam travadas em `cabal.project.freeze`, o equivalente em Haskell a um arquivo de *lock*. O `requirements.txt` apenas documenta essas dependências.

---

## 🚀 Como Executar o Projeto

Clone o repositório e atualize o índice do Hackage (necessário na primeira vez):
```bash
git clone https://github.com/KevenGustavo/hs2json.git
cd hs2json
cabal update
```

### Compilar
```bash
cabal build
```

### Executar a demonstração simples
```bash
cabal run hs2json-exe
```

### Executar a demonstração visual completa
Apresenta passo a passo os accessors, a serialização simples versus o *pretty printing*, os escapes da RFC 8259 (incluindo pares substitutos), os exercícios `nest`/`fill` e um resumo dos testes:
```bash
cabal run hs2json-demo
```

### Executar a suíte de testes (QuickCheck)
```bash
cabal test
```

### Executar testes com relatório de cobertura (HPC)
```bash
cabal test --enable-coverage
```
O relatório HTML é gerado em `dist-newstyle/build/.../hpc/vanilla/html/`.

### Carregar no REPL interativo (GHCi)
```bash
cabal repl                 # Carrega a biblioteca principal
cabal repl hs2json-test    # Carrega a suíte de testes
```

---

## 📂 Arquitetura do Projeto

```
hs2json/
├── hs2json.cabal           # Configuração de build, módulos expostos e dependências
├── cabal.project.freeze    # Versões travadas das dependências
├── DIFICULDADES.md         # Dificuldades encontradas e como foram superadas
├── app/
│   ├── Main.hs             # Executável hs2json-exe (demo simples)
│   └── Demo.hs             # Executável hs2json-demo (demo visual completa)
├── src/
│   ├── SimpleJSON.hs       # Definição do tipo JValue e accessors seguros
│   ├── PutJSON.hs          # Serialização simples de JValue para String
│   ├── Prettify.hs         # Biblioteca de combinadores de documentos (Doc)
│   └── PrettyJSON.hs       # Renderizador JSON com suporte a quebras e escapes
└── test/
    ├── Spec.hs             # Agregador principal da suíte executada por cabal test
    ├── JSONGen.hs          # Instância Arbitrary para JValue (recursão controlada)
    ├── JSONProps.hs        # Propriedades de teste para SimpleJSON e PutJSON
    ├── DocProps.hs         # Propriedades de teste para Prettify
    └── PrettyProps.hs      # Propriedades de teste para PrettyJSON
```

### Módulos

| Módulo | Responsabilidade | Principais definições |
|---|---|---|
| `SimpleJSON` | Representação dos dados | `JValue` (`JString`, `JNumber`, `JBool`, `JNull`, `JObject`, `JArray`) e accessors `getString`, `getInt`, `getDouble`, `getBool`, `getObject`, `getArray`, `isNull`, todos retornando `Maybe` |
| `PutJSON` | Renderização simples em uma linha | `renderJValue`, `putJValue` |
| `Prettify` | Álgebra de documentos com layout adaptativo | `Doc` (`Empty`, `Char`, `Text`, `Line`, `Concat`, `Union`), `<>`, `hcat`, `fsep`, `punctuate`, `compact`, `pretty`, `fill`, `nest` |
| `PrettyJSON` | JSON legível e conforme a RFC 8259 | `renderJValue`, `string`, `simpleEscapes`, `smallHex`, `astral`, `series` |

---

## Exemplos de saída

### Serialização simples (`PutJSON`)

```bash
cabal run hs2json-exe
```

```text
=== Demonstracao hs2json ===
JSON gerado:
{"nome": "Leonardo", "idade": 24.0, "estudante": true, "linguagens": ["Haskell", "Python", "SQL"], "endereco": {"cidade": "Sao Luis", "estado": "MA"}, "observacao": "Aprendendo \"Haskell\"", "telefone": null}
```

### Pretty printing (`PrettyJSON` + `Prettify`)

O mesmo tipo de valor renderizado com `pretty 40`, que quebra as linhas conforme a largura disponível:

```haskell
ghci> putStr (pretty 40 (PrettyJSON.renderJValue valor))
{"nome": "Leonardo",
"linguagens": ["Haskell", "Python" ],
"obs": "café\n", "ok": true }
```

Quanto menor a largura, mais quebras de linha o algoritmo (`Union` + `fits`) escolhe. Use `compact` para a saída sem quebras.

---

## Testes automatizados

O projeto utiliza o **QuickCheck** (com `$quickCheckAll` via Template Haskell) para verificar propriedades das implementações. Todas as propriedades são executadas por `cabal test` em poucos segundos.

| Arquivo | O que verifica |
|---|---|
| `JSONProps.hs` | Accessors (`getString`, `getInt`, `getDouble`, `getBool`, `getObject`, `getArray`), `isNull`, exclusividade de tipos e renderização simples |
| `DocProps.hs` | `Arbitrary Doc`, identidade de `Empty`, modelo de listas para `punctuate` e `hcat`, invariantes de `compact` e layout |
| `PrettyProps.hs` | Escapes da RFC 8259, pares substitutos para caracteres astrais, delimitadores de coleções, largura máxima de linha e equivalência de tokens entre `compact` e `pretty 80` |

O gerador `Arbitrary JValue` (`JSONGen.hs`) limita a recursão com `sized` e ``resize (n `div` 2)``, evitando estouro de memória.

Para executar:

```bash
cabal test                          # roda todas as propriedades
cabal test --enable-coverage        # inclui o relatório HPC
```

A suíte termina com `exitFailure` se qualquer propriedade falhar. Com a cobertura (HPC), as funções centrais de layout (`fits`, `pretty`, `nicest`, `compact`) ficam entre 97% e 100%.

---

## 🧗 Principais dificuldades

Resumo das principais dificuldades. O relato completo, com problema, solução e aprendizado de cada uma, está em [**DIFICULDADES.md**](DIFICULDADES.md).

| # | Dificuldade | Como foi superada |
|---|---|---|
| 1 | `cabal.project.freeze` incompatível com o GHC instalado | Instalação do GHC 9.4.8 via GHCup |
| 2 | Funções com `undefined` compilam, mas falham na execução | Implementação por casamento de padrões e recarga no GHCi |
| 3 | Recursão descontrolada no gerador `Arbitrary JValue` | `sized` + ``resize (n `div` 2)``, validado com 1.000 execuções |
| 4 | Conflito do operador `<>` com o `Semigroup` do `Prelude` moderno | `import Prelude hiding ((<>))` em `Prettify` e `PrettyJSON` |
| 5 | Pares substitutos UTF-16 para caracteres fora do plano básico (RFC 8259) | Função `astral` com `shiftR` e `.&.` do `Data.Bits` |
| 6 | O teste de `punctuate` contra `intersperse` falhava com `Empty` | Modelo `combine` em `DocProps.hs` refletindo a simplificação de `<>` |
| 7 | Testes 100% verdes, mas com baixa cobertura no HPC | Novas propriedades sobre a saída renderizada, chegando a 97%–100% |

---

## 🌿 Histórico de commits e divisão do trabalho

O repositório segue o padrão **Conventional Commits** (`feat:`, `test:`, `docs:`, `chore:`), com commits pequenos e incrementais que acompanham a evolução dos tutoriais. Para consultar:

```bash
git log --oneline
```

| Autor | Foco |
|---|---|
| [Leonardo Ferreira](https://github.com/leonardo-ferreira16) | `SimpleJSON`, `PutJSON`, demo inicial, gerador `Arbitrary JValue` e propriedades dos accessors |
| [Keven Gomes](https://github.com/KevenGustavo) | `Prettify`, `PrettyJSON`, `DocProps`, `PrettyProps`, cobertura HPC e demo visual |

---

## 👥 Autores

- [**Keven Gomes**](https://github.com/KevenGustavo)
- [**Leonardo Ferreira**](https://github.com/leonardo-ferreira16)
