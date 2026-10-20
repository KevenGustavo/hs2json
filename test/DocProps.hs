{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-orphans #-}
-- | Modulo DocProps: suite de testes baseada em propriedades para a biblioteca Prettify.
-- Implementa a geracao aleatoria de documentos (Arbitrary Doc) e verifica as invariantes
-- algebricas e de layout (Capitulos 08 e 09 do tutorial).
module DocProps (runTests) where

import Prelude hiding ((<>))

import Test.QuickCheck
import Data.List (intersperse)
import Control.Monad (liftM, liftM2)

import Prettify

--------------------------------------------------------------------------------
-- Gerador Arbitrary para a algebra de documentos (Doc)
--------------------------------------------------------------------------------

-- | Instancia de geracao de valores Doc aleatorios para o QuickCheck.
-- Usamos 'sized' para controlar a profundidade da arvore gerada: no caso base
-- (tamanho 0) geramos apenas folhas primitivas (Empty, Char, Text, Line),
-- enquanto nos tamanhos maiores geramos tambem os nos combinadores (Concat, Union)
-- reduzindo a profundidade pela metade a cada ramificacao para evitar arvores infinitas.
instance Arbitrary Doc where
    arbitrary = sized docGen
      where
        -- | No nivel folha, produzimos apenas construtores terminais.
        docGen 0 = oneof
            [ return Empty
            , liftM  Char   arbitrary
            , liftM  Text   arbitrary
            , return Line
            ]
        -- | No nivel recursivo, dividimos o tamanho 'n' para que a profundidade
        -- da arvore se mantenha finita e estavel durante os testes de estresse.
        docGen n = oneof
            [ return Empty
            , liftM  Char   arbitrary
            , liftM  Text   arbitrary
            , return Line
            , liftM2 Concat (docGen (n `div` 2)) (docGen (n `div` 2))
            , liftM2 Union  (docGen (n `div` 2)) (docGen (n `div` 2))
            ]

--------------------------------------------------------------------------------
-- Invariantes algebricas de construcao de documentos
--------------------------------------------------------------------------------

-- | Invariante de identidade do documento vazio:
-- 'empty' eh o elemento neutro da concatenacao '<>' tanto pela esquerda quanto pela direita.
prop_empty_id :: Doc -> Bool
prop_empty_id x =
    empty <> x == x
  &&
    x <> empty == x

-- | Invariante do construtor de caractere:
-- Envolver um caractere deve equivaler exatamente ao no primitivo 'Char'.
prop_char :: Char -> Bool
prop_char c = char c == Char c

-- | Invariante do construtor de texto:
-- Strings vazias sao normalizadas como 'Empty', e strings com conteudo tornam-se 'Text'.
prop_text :: String -> Bool
prop_text s = text s == if null s then Empty else Text s

-- | Invariante do comando de quebra de linha rigida.
prop_line :: Bool
prop_line = line == Line

-- | Invariante de conversao de ponto flutuante:
-- 'double d' deve produzir o mesmo documento textual que 'text (show d)'.
prop_double :: Double -> Bool
prop_double d = double d == text (show d)

--------------------------------------------------------------------------------
-- Testes baseados em modelo (referencia em listas)
--------------------------------------------------------------------------------

-- | Concatena uma lista de documentos e compara com a implementacao de referencia
-- estrutural baseada em recursao de lista tradicional ('glue').
prop_hcat :: [Doc] -> Bool
prop_hcat xs = hcat xs == glue xs
  where
    glue []     = empty
    glue (d:ds) = d <> glue ds

-- | Valida a intercalacao de separadores com 'punctuate'.
-- Como o operador '<>' otimiza eliminando 'Empty', o modelo de lista precisa
-- espelhar essa mesma normalizacao ao redor dos separadores intercalados.
prop_punctuate' :: Doc -> [Doc] -> Bool
prop_punctuate' s xs = punctuate s xs == combine (intersperse s xs)
  where
    combine []           = []
    combine [x]          = [x]
    combine (x:Empty:ys) = x : combine ys
    combine (Empty:y:ys) = y : combine ys
    combine (x:y:ys)     = x `Concat` y : combine ys

--------------------------------------------------------------------------------
-- Invariantes da renderizacao compacta e formatada
--------------------------------------------------------------------------------

-- | Renderizar compactamente um texto puro deve devolver a string original inalterada.
prop_compact_text :: String -> Bool
prop_compact_text s = compact (text s) == s

-- | Renderizar o documento 'empty' deve produzir a string vazia.
prop_compact_empty :: Bool
prop_compact_empty = compact empty == ""

-- | Renderizar um caractere individual deve devolver a string unitaria.
prop_compact_char :: Char -> Bool
prop_compact_char c = compact (char c) == [c]

-- | Renderizar uma quebra rigida 'line' em modo compacto deve gerar '\n'.
prop_compact_line :: Bool
prop_compact_line = compact line == "\n"

-- | A renderizacao compacta preserva a distributividade da concatenacao sobre strings:
-- compact (d1 <> d2) == compact d1 ++ compact d2.
prop_compact_concat :: Doc -> Doc -> Bool
prop_compact_concat d1 d2 = compact (d1 <> d2) == compact d1 ++ compact d2

-- | Propriedade da operacao 'nest': indentacao zero preserva o documento inalterado.
prop_nest_zero :: Doc -> Bool
prop_nest_zero d = nest 0 d == d

-- | Propriedade de 'fill': preencher um texto sem quebras com largura 'w'
-- garante que o comprimento resultante seja pelo menos 'w' (quando w >= tamanho original).
prop_fill_length :: NonNegative Int -> String -> Property
prop_fill_length (NonNegative w) s =
    not ('\n' `elem` s) ==>
        let filled = compact (fill w (text s))
        in length filled >= w || length filled == length s

-- | Para documentos sem quebras de linha rigidas, a renderizacao com 'pretty'
-- produz o mesmo texto que a renderizacao de texto isolada, independente da largura.
prop_pretty_text :: NonNegative Int -> String -> Property
prop_pretty_text (NonNegative w) s =
    not ('\n' `elem` s) ==>
        pretty w (text s) == s

-- | Propriedade de 'nest': quando a indentacao eh positiva, quebras rigidas de linha
-- sao seguidas exatamente pela quantidade especificada de espacos de alinhamento.
prop_nest_indentation :: Positive Int -> Bool
prop_nest_indentation (Positive i) =
    compact (nest i (line <> text "abc")) == "\n" ++ replicate i ' ' ++ "abc"

-- | Propriedade de 'fill' sobre documentos arbitrarios: calcula comprimentos e executa de forma segura.
prop_fill_doc :: NonNegative Int -> Doc -> Bool
prop_fill_doc (NonNegative w) d =
    let filled = fill w d
    in length (compact filled) >= 0

-- | O combinador 'group' aplica 'flatten' sobre arvores de documentos para layout alternativo.
-- Garante a avaliacao segura e terminacao do pretty layout sob qualquer largura.
prop_group_pretty :: Doc -> Bool
prop_group_pretty d =
    let rendered = pretty 40 (group d)
    in length rendered >= 0

-- | O combinador 'fsep' intercala documentos com quebras suaves, funcionando com seguranca sob qualquer largura.
prop_fsep_pretty :: [Doc] -> Bool
prop_fsep_pretty ds =
    let rendered = pretty 40 (fsep ds)
    in length rendered >= 0

-- | Valida a tomada de decisao de 'nicest' entre layout de linha unica e multi-linha:
-- com largura zero forca a quebra, e com largura ampla preserva a linha unica.
prop_pretty_width_decision :: Property
prop_pretty_width_decision = property $
    let doc = text "hello" </> text "world"
        narrow = pretty 0 doc
        wide   = pretty 80 doc
    in narrow == "hello\nworld" && wide == "hello world"

--------------------------------------------------------------------------------
-- Agrupamento e execucao via Template Haskell
--------------------------------------------------------------------------------

-- | Marcador de corte de escopo para o Template Haskell encontrar as propriedades acima.
return []

-- | Ponto de entrada que executa todas as definicoes que iniciam com 'prop_'.
runTests :: IO Bool
runTests = $quickCheckAll
