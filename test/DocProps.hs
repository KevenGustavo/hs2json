{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-orphans #-}
-- | Modulo DocProps: suite de testes baseada em propriedades para a biblioteca Prettify.
-- Implementa a geracao aleatoria de documentos (Arbitrary Doc) e verifica as invariantes
-- algebricas basicas (Capitulo 08 do tutorial).
module DocProps (runTests) where

import Prelude hiding ((<>))

import Test.QuickCheck
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
-- Agrupamento e execucao via Template Haskell
--------------------------------------------------------------------------------

-- | Marcador de corte de escopo para o Template Haskell encontrar as propriedades acima.
return []

-- | Ponto de entrada que executa todas as definicoes que iniciam com 'prop_'.
runTests :: IO Bool
runTests = $quickCheckAll
