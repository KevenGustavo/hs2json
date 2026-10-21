# hs2json

> 🎥 **Vídeo de apresentação:** _a definir_
>
> Demonstração do funcionamento do projeto, da arquitetura,
> dos testes automatizados e das dificuldades encontradas.

Biblioteca Haskell desenvolvida para representar dados JSON (`JValue`), serializá-los com formatação legível através de uma biblioteca própria de *pretty printing* (`Prettify`) e validar propriedades e invariantes via **QuickCheck**.

Projeto desenvolvido para a disciplina de **Programação Funcional** (dupla: **Keven Gomes** e **Leonardo Abreu**).

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
ghc --version      # The Glorious Glasgow Haskell Compilation System, version 9.4.x ou superior
cabal --version    # cabal-install version 3.x ou superior
```

### 3. Dependências Haskell do Projeto
As dependências do ecossistema Haskell são gerenciadas e resolvidas automaticamente pelo Cabal (`hs2json.cabal`):
- `base >= 4.14 && < 5`
- `QuickCheck` (para a suíte de testes baseada em propriedades)

---

## 🚀 Como Executar o Projeto

Atualize o índice do Hackage (necessário na primeira vez):
```bash
cabal update
```

### Compilar
```bash
cabal build
```

### Executar a demonstração
```bash
cabal run hs2json-exe
```

### Executar a suíte de testes (QuickCheck)
```bash
cabal test
```

### Executar testes com relatório de cobertura (HPC)
```bash
cabal test --enable-coverage
```

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
├── app/
│   └── Main.hs             # Ponto de entrada do executável hs2json-exe
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

## Exemplo de saída

O programa demonstra a construção e a serialização de um objeto JSON contendo diferentes tipos de dados, incluindo objetos aninhados e arrays.

Para executar:

```bash
cabal run hs2json-exe
```

Exemplo de saída:

```text
=== Demonstracao hs2json ===
JSON gerado:
{"nome": "Leonardo", "idade": 24.0, "estudante": true, "linguagens": ["Haskell", "Python", "SQL"], "endereco": {"cidade": "Sao Luis", "estado": "MA"}, "observacao": "Aprendendo \"Haskell\"", "telefone": null}
```

O módulo `PutJSON` produz uma representação simples em uma linha, enquanto `Prettify` e `PrettyJSON` fornecem os recursos de construção e formatação de documentos.

## Testes automatizados

O projeto utiliza o QuickCheck para verificar propriedades das implementações.

As propriedades incluem:

- Recuperação de strings, números, booleanos, arrays e objetos;
- Verificação de valores nulos e de tipos incompatíveis;
- Geração aleatória de estruturas JSON com recursividade controlada;
- Renderização de valores JSON;
- Propriedades da biblioteca de pretty printing.

Para executar todos os testes:

```bash
cabal test
```

Os resultados são apresentados no terminal, indicando quais propriedades passaram e quantos casos foram testados.

---

## 👥 Autores

- **Keven Gomes**
- **Leonardo Abreu**

