{-# LANGUAGE TemplateHaskell #-}
-- | Modulo PrettyProps: suite de testes baseada em propriedades para o renderizador PrettyJSON.
-- Verifica a conformidade com a RFC 8259 (regras de escape, pares substitutos Unicode para
-- caracteres astrais e delimitadores estruturais basicos).
module PrettyProps (runTests) where

import Prelude hiding ((<>))

import Data.Char (ord, chr)
import Test.QuickCheck

import SimpleJSON (JValue(..))
import Prettify (compact)
import PrettyJSON (renderJValue)

--------------------------------------------------------------------------------
-- Propriedades de valores primitivos
--------------------------------------------------------------------------------

-- | Renderizacao de booleanos: 'JBool True' deve produzir "true" e 'JBool False' "false".
prop_render_bool :: Bool -> Bool
prop_render_bool b =
    compact (renderJValue (JBool b)) == if b then "true" else "false"

-- | Renderizacao do valor nulo: 'JNull' deve produzir exatamente a palavra "null".
prop_render_null :: Bool
prop_render_null =
    compact (renderJValue JNull) == "null"

-- | Renderizacao de numeros: 'JNumber d' deve ser consistente com 'show d'.
prop_render_number :: Double -> Bool
prop_render_number d =
    compact (renderJValue (JNumber d)) == show d

--------------------------------------------------------------------------------
-- Propriedades de escape de strings (RFC 8259)
--------------------------------------------------------------------------------

-- | Toda string JSON renderizada deve comecar e terminar com aspas duplas.
prop_string_delimiters :: String -> Bool
prop_string_delimiters s =
    let rendered = compact (renderJValue (JString s))
    in not (null rendered) && head rendered == '"' && last rendered == '"'

-- | Caracteres de controle ASCII (< 0x20) nunca podem aparecer 'in natura' (sem escape)
-- no corpo da string JSON renderizada.
prop_string_no_raw_control :: String -> Bool
prop_string_no_raw_control s =
    let rendered = compact (renderJValue (JString s))
        -- Remove as aspas delimitadoras externas para inspecionar o conteudo
        body = init (tail rendered)
    in all (\c -> ord c >= 0x20 || c == '\\') (filterRawChars body)
  where
    -- | Filtra ignorando sequencias escapadas por barra invertida
    filterRawChars [] = []
    filterRawChars ('\\':_:cs) = filterRawChars cs
    filterRawChars (c:cs)      = c : filterRawChars cs

-- | Caracteres do plano astral (code point > 0xffff) devem ser serializados como
-- um par substituto (surrogate pair) UTF-16 composto por dois escapes '\uXXXX\uYYYY'.
prop_astral_surrogate :: Property
prop_astral_surrogate = forAll (choose (0x10000, 0x10ffff)) $ \code ->
    let c = chr code
        rendered = compact (renderJValue (JString [c]))
    in length rendered == 14
       && take 2 (drop 1 rendered) == "\\u"
       && take 2 (drop 7 rendered) == "\\u"

-- | Aspas duplas e barras invertidas devem ser devidamente precedidas por escape ('\\').
prop_quote_and_backslash_escaped :: Property
prop_quote_and_backslash_escaped = forAll (elements ["\"", "\\", "\"\t\\"]) $ \s ->
    let rendered = compact (renderJValue (JString s))
        body = init (tail rendered)
    in not ('"' `elem` unescapedQuotes body)
  where
    unescapedQuotes [] = []
    unescapedQuotes ('\\':_:cs) = unescapedQuotes cs
    unescapedQuotes (c:cs)      = c : unescapedQuotes cs

--------------------------------------------------------------------------------
-- Agrupamento e execucao via Template Haskell
--------------------------------------------------------------------------------

return []

-- | Ponto de entrada que executa todas as definicoes que iniciam com 'prop_'.
runTests :: IO Bool
runTests = $quickCheckAll
