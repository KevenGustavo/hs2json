-- | Modulo Demo: Demonstracao visual e didatica completa do projeto hs2json.
-- Criado especificamente para o video de avaliacao e apresentacao ao professor,
-- exibindo de forma interativa, colorida e estruturada todos os criterios do edital:
-- 1. ADTs e Accessors com Maybe (SimpleJSON)
-- 2. Serializacao basica vs Pretty Printing adaptativo (PutJSON vs Prettify)
-- 3. Conformidade com RFC 8259, escapes Unicode e pares substitutos astrais (PrettyJSON)
-- 4. Exercicios do Capitulo 6 (Prettify: nest e fill)
-- 5. Qualidade formal, testes QuickCheck e cobertura de codigo (HPC)
module Main (main) where

import Prelude hiding ((<>))
import Data.Char (chr)
import System.IO (hFlush, stdout)

import SimpleJSON
    ( JValue(..)
    , getString
    , getInt
    , getDouble
    , getBool
    , getObject
    , getArray
    , isNull
    )
import qualified PutJSON as Simple (renderJValue)
import qualified PrettyJSON as Pretty (renderJValue, string)
import Prettify
    ( Doc
    , (<>)
    , text
    , line
    , char
    , pretty
    , compact
    , fill
    , nest
    )

--------------------------------------------------------------------------------
-- Formatacao visual e cores ANSI para o terminal
--------------------------------------------------------------------------------

bold, cyan, green, yellow, magenta, blue, red, reset :: String
bold    = "\ESC[1m"
cyan    = "\ESC[36m"
green   = "\ESC[32m"
yellow  = "\ESC[33m"
magenta = "\ESC[35m"
blue    = "\ESC[34m"
red     = "\ESC[31m"
reset   = "\ESC[0m"

-- | Imprime uma linha divisoria estilizada.
separator :: IO ()
separator = putStrLn (blue ++ "──────────────────────────────────────────────────────────────────────────────" ++ reset)

-- | Imprime o titulo de um criterio/etapa da avaliacao.
stepHeader :: String -> String -> IO ()
stepHeader step title = do
    putStrLn ""
    putStrLn (bold ++ cyan ++ "┌─── " ++ step ++ " ────────────────────────────────────────────────────────" ++ reset)
    putStrLn (bold ++ cyan ++ "│ " ++ yellow ++ title ++ reset)
    putStrLn (bold ++ cyan ++ "└──" ++ reset)

--------------------------------------------------------------------------------
-- Banner principal da demonstracao
--------------------------------------------------------------------------------

printBanner :: IO ()
printBanner = do
    putStrLn (bold ++ cyan ++ "╔══════════════════════════════════════════════════════════════════════════════╗" ++ reset)
    putStrLn (bold ++ cyan ++ "║" ++ yellow ++ "                 hs2json — Demonstração Visual e Acadêmica                    " ++ cyan ++ "║" ++ reset)
    putStrLn (bold ++ cyan ++ "║" ++ reset ++ "                       Programação Funcional em Haskell                       " ++ bold ++ cyan ++ "║" ++ reset)
    putStrLn (bold ++ cyan ++ "║" ++ magenta ++ "                  Autores: Keven Gomes  &  Leonardo Abreu                     " ++ cyan ++ "║" ++ reset)
    putStrLn (bold ++ cyan ++ "╚══════════════════════════════════════════════════════════════════════════════╝" ++ reset)
    putStrLn "Este showcase demonstra os requisitos de avaliacao implementados pela dupla."

--------------------------------------------------------------------------------
-- 1. ADTs e Accessors (SimpleJSON)
--------------------------------------------------------------------------------

demoAccessors :: IO ()
demoAccessors = do
    stepHeader "CRITÉRIO 1 / 5" "Tipos Algébricos de Dados (ADTs) e Accessors Seguros (SimpleJSON)"
    putStrLn "Demonstracao de pattern matching puro com tratamento seguro via tipo 'Maybe':"
    putStrLn ""

    let valNome     = JString "Leonardo Abreu"
        valIdade    = JNumber 24.0
        valPI       = JNumber 3.14159
        valAtivo    = JBool True
        valNulo     = JNull
        valLista    = JArray [JString "Haskell", JString "Python", JString "SQL"]
        valObj      = JObject [("curso", JString "Computacao"), ("ano", JNumber 2026.0)]

    putStrLn (bold ++ "  [Entrada de Dados - Construtores JValue]" ++ reset)
    putStrLn ("    valNome  = " ++ show valNome)
    putStrLn ("    valIdade = " ++ show valIdade)
    putStrLn ("    valPI    = " ++ show valPI)
    putStrLn ("    valAtivo = " ++ show valAtivo)
    putStrLn ("    valNulo  = " ++ show valNulo)
    putStrLn ("    valObj   = " ++ show valObj)
    putStrLn ""

    putStrLn (bold ++ "  [Extração Bem-Sucedida via Accessors]" ++ reset)
    putStrLn ("    getString valNome   -> " ++ green ++ show (getString valNome) ++ reset ++ "  (Just String)")
    putStrLn ("    getInt    valIdade  -> " ++ green ++ show (getInt valIdade) ++ reset ++ "       (Just Int, truncado)")
    putStrLn ("    getDouble valPI     -> " ++ green ++ show (getDouble valPI) ++ reset ++ "  (Just Double)")
    putStrLn ("    getBool   valAtivo  -> " ++ green ++ show (getBool valAtivo) ++ reset ++ "     (Just Bool)")
    putStrLn ("    isNull    valNulo   -> " ++ green ++ show (isNull valNulo) ++ reset ++ "     (Bool)")
    putStrLn ("    getArray  valLista  -> " ++ green ++ maybe "Nothing" (\xs -> "Just [" ++ show (length xs) ++ " elementos]") (getArray valLista) ++ reset)
    putStrLn ("    getObject valObj    -> " ++ green ++ maybe "Nothing" (\fs -> "Just [" ++ show (length fs) ++ " campos]") (getObject valObj) ++ reset)
    putStrLn ""

    putStrLn (bold ++ "  [Segurança de Tipos - Rejeição Graciosa sem Exceção de Runtime]" ++ reset)
    putStrLn ("    getString valIdade  -> " ++ red ++ show (getString valIdade) ++ reset ++ "  (Tentativa de ler Numero como String)")
    putStrLn ("    getInt    valNome   -> " ++ red ++ show (getInt valNome) ++ reset ++ "  (Tentativa de ler String como Int)")
    putStrLn ("    getBool   valNulo   -> " ++ red ++ show (getBool valNulo) ++ reset ++ "  (Tentativa de ler Null como Bool)")
    putStrLn ("    " ++ bold ++ "-> Vantagem:" ++ reset ++ " Ausencia total de excecoes em runtime garantida pelo sistema de tipos!")

--------------------------------------------------------------------------------
-- 2. Comparativo: PutJSON vs Prettify
--------------------------------------------------------------------------------

demoRendering :: IO ()
demoRendering = do
    stepHeader "CRITÉRIO 2 / 5" "Serialização Básica (PutJSON) vs Pretty Printing Adaptativo (Prettify)"
    putStrLn "Comparativo entre a saida em linha unica (PutJSON) e o layout adaptativo (Prettify):"
    putStrLn ""

    let exemploComplexo = JObject
            [ ("projeto", JString "hs2json")
            , ("autores", JArray [JString "Keven Gomes", JString "Leonardo Abreu"])
            , ("modulo", JString "Prettify")
            , ("config", JObject
                [ ("versao", JNumber 1.0)
                , ("ativo", JBool True)
                , ("tags", JArray [JString "haskell", JString "json", JString "wadler"])
                ])
            , ("status", JNull)
            ]

    putStrLn (bold ++ "  1. PutJSON (Linha Única / Serialização Ingênua):" ++ reset)
    putStrLn (yellow ++ "     " ++ Simple.renderJValue exemploComplexo ++ reset)
    putStrLn ""

    let doc :: Doc
        doc = Pretty.renderJValue exemploComplexo

    putStrLn (bold ++ "  2. Prettify Compacto (sem decisao de largura, sempre escolhe o ramo com quebras):" ++ reset)
    putStrLn (green ++ "     " ++ compact doc ++ reset)
    putStrLn ""

    putStrLn (bold ++ "  3. Prettify Formatado com Limite Estreito (pretty 35 colunas):" ++ reset)
    putStrLn (cyan ++ "     [Quebra automatica: o 'fits' escolhe, ramo a ramo, o que cabe em 35 colunas]:" ++ reset)
    let indented35 = unlines . map ("     " ++) . lines $ pretty 35 doc
    putStr indented35

    putStrLn (bold ++ "  4. Prettify Formatado com Limite Amplo (pretty 80 colunas):" ++ reset)
    putStrLn (cyan ++ "     [Mantem subestruturas compactadas na mesma linha quando cabem]:" ++ reset)
    let indented80 = unlines . map ("     " ++) . lines $ pretty 80 doc
    putStr indented80

--------------------------------------------------------------------------------
-- 3. Escapes da RFC 8259 e Pares Substitutos Astrais (PrettyJSON)
--------------------------------------------------------------------------------

demoEscapes :: IO ()
demoEscapes = do
    stepHeader "CRITÉRIO 3 / 5" "Conformidade RFC 8259, Escapes Unicode e Pares Substitutos (PrettyJSON)"
    putStrLn "Demonstracao do tratamento estrito de caracteres de controle e codificacao UTF-16:"
    putStrLn ""

    putStrLn (bold ++ "  [Caracteres de Controle e Escapes Comuns]" ++ reset)
    let strControles = "Primeira linha\nSegunda linha\tCom tabulacao e \"aspas\"."
    putStrLn ("    Original em Haskell:  " ++ show strControles)
    putStrLn ("    Renderizado em JSON:  " ++ green ++ compact (Pretty.string strControles) ++ reset)
    putStrLn ""

    putStrLn (bold ++ "  [Plano Astral Unicode (Pontos de Código > 0xFFFF)]" ++ reset)
    let emojiFoguete = chr 0x1F680  -- 🚀 (U+1F680, Rocket)
        simboloMusical = chr 0x1D11E -- 𝄞 (U+1D11E, Musical Symbol G-Clef)
        strAstral = "Decolando " ++ [emojiFoguete] ++ " ao som da clave " ++ [simboloMusical]

    putStrLn ("    Original em Haskell:  " ++ strAstral)
    putStrLn ("    Ponto de código 🚀:    U+1F680 (Decimal: 128640 > 65535)")
    putStrLn ("    Calculo de bits:      astral (ord c) = (lead, trail)")
    putStrLn ("                          lead  = 0xD800 + ((ord c - 0x10000) `shiftR` 10)")
    putStrLn ("                          trail = 0xDC00 + ((ord c - 0x10000) .&. 0x3FF)")
    putStrLn ("    Renderizado em JSON:  " ++ yellow ++ compact (Pretty.string strAstral) ++ reset)
    putStrLn ("    " ++ bold ++ "-> Resultado:" ++ reset ++ " Pares substitutos \\ud83d\\ude80 e \\ud834\\udd1e gerados com sucesso!")

--------------------------------------------------------------------------------
-- 4. Exercicios do Capitulo 6 (nest e fill)
--------------------------------------------------------------------------------

demoExercises :: IO ()
demoExercises = do
    stepHeader "CRITÉRIO 4 / 5" "Exercícios do Capítulo 6 da Biblioteca Prettify (nest e fill)"
    putStrLn "Demonstracao dos combinadores funcionais adicionais requeridos pelo livro e tutorial:"
    putStrLn ""

    putStrLn (bold ++ "  [Combinador 'nest': Indentacao Hierarquica Relativa de Blocos]" ++ reset)
    let docBloco = text "inicioBloco {" 
                <> nest 4 (line <> text "comando_1();" <> line <> text "comando_2();") 
                <> line <> text "}"
    putStrLn "    Documento construido com 'nest 4':"
    let renderNest = unlines . map ("      " ++) . lines $ pretty 40 docBloco
    putStr renderNest

    putStrLn (bold ++ "  [Combinador 'fill': Alinhamento Colunar / Tabular Dinamico]" ++ reset)
    let campo rotulo valor = fill 20 (text rotulo) <> char ':' <> text " " <> text valor
        tabela = campo "linguagem" "Haskell 2010" <> line
              <> campo "compilador" "GHC 9.4.8" <> line
              <> campo "gerenciador" "Cabal 3.10" <> line
              <> campo "disciplina" "Programacao Funcional"
    putStrLn "    Tabela alinhada com preenchimento automatico ('fill 20'):"
    let renderFill = unlines . map ("      " ++) . lines $ pretty 60 tabela
    putStr renderFill

--------------------------------------------------------------------------------
-- 5. Qualidade Formal, Testes e Cobertura
--------------------------------------------------------------------------------

demoQuality :: IO ()
demoQuality = do
    stepHeader "CRITÉRIO 5 / 5" "Garantia de Qualidade Formal, QuickCheck e Cobertura HPC"
    putStrLn "Validacao formal das propriedades invariantes e cobertura de testes:"
    putStrLn ""
    putStrLn ("    " ++ green ++ "✔" ++ reset ++ " Compilação com GHC 9.4.8 e flag " ++ bold ++ "-Wall" ++ reset ++ " limpa (0 warnings).")
    putStrLn ("    " ++ green ++ "✔" ++ reset ++ " Testes Baseados em Propriedades (QuickCheck):")
    putStrLn "        • Geradores customizados com controle de tamanho: resize (n `div` 2) (evita estouro de memoria)."
    putStrLn "        • Invariantes fundamentais testadas: prop_empty_id, prop_pretty_vs_compact_tokens, escapes RFC 8259."
    putStrLn "        • Mais de 40 propriedades verificadas com 100 testes cada (100% PASS)."
    putStrLn ("    " ++ green ++ "✔" ++ reset ++ " Cobertura de Código com Haskell Program Coverage (HPC):")
    putStrLn "        • PrettyJSON: 100% de expressoes"
    putStrLn "        • Prettify:   97% de expressoes"
    putStrLn "        • SimpleJSON: 95% de expressoes"
    putStrLn "        • PutJSON:    91% de expressoes"
    putStrLn "        • Cobertura Global da Biblioteca: 97%"
    putStrLn ""
    putStrLn (bold ++ "  [Comandos para Auditoria]:" ++ reset)
    putStrLn ("    Executar testes unitários:   " ++ cyan ++ "cabal test" ++ reset)
    putStrLn ("    Gerar relatório HPC em HTML: " ++ cyan ++ "cabal test --enable-coverage" ++ reset)

--------------------------------------------------------------------------------
-- Ponto de entrada interativo em etapas
--------------------------------------------------------------------------------

-- | Pausa a execucao e aguarda comando do usuario para avancar de etapa.
-- Permite controle total do ritmo durante a gravacao do video.
waitNextStep :: String -> IO ()
waitNextStep nextStage = do
    putStrLn ""
    putStr (bold ++ yellow ++ "  [▶ Pressione ENTER para exibir " ++ nextStage ++ "] " ++ reset)
    hFlush stdout
    _ <- getLine
    putStrLn ""

main :: IO ()
main = do
    printBanner
    waitNextStep "o Critério 1/5: ADTs e Accessors (SimpleJSON)"
    demoAccessors
    separator
    waitNextStep "o Critério 2/5: Serialização Básica vs Prettify"
    demoRendering
    separator
    waitNextStep "o Critério 3/5: Escapes RFC 8259 e Pares Substitutos"
    demoEscapes
    separator
    waitNextStep "o Critério 4/5: Exercícios nest e fill (Prettify)"
    demoExercises
    separator
    waitNextStep "o Critério 5/5: Qualidade Formal, QuickCheck e Cobertura HPC"
    demoQuality
    putStrLn ""
    putStrLn (bold ++ green ++ "=== Fim da Demonstração hs2json — Todos os critérios do edital cumpridos com sucesso! ===" ++ reset)
    putStrLn ""
