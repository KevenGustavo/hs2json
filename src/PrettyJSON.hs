-- | Modulo PrettyJSON: renderizador JSON baseado na algebra de documentos Doc.
-- Implementa a formatacao de strings com caracteres de escape basicos (RFC 8259).
module PrettyJSON
    ( renderJValue
    , string
    , enclose
    ) where

import Prelude hiding ((<>))

import SimpleJSON (JValue(..))
import Prettify (Doc, (<>), char, double, text, hcat)

--------------------------------------------------------------------------------
-- Delimitadores e strings
--------------------------------------------------------------------------------

-- | Envolve um documento entre dois delimitadores de caracteres.
enclose :: Char -> Char -> Doc -> Doc
enclose left right x = char left <> x <> char right

-- | Renderiza uma string JSON entre aspas duplas aplicando escape a cada caractere.
string :: String -> Doc
string = enclose '"' '"' . hcat . map oneChar

-- | Tabela de associacao com caracteres de escape simples padronizados pela RFC 8259.
simpleEscapes :: [(Char, String)]
simpleEscapes = zipWith ch "\b\n\f\r\t\\\"/" "bnfrt\\\"/"
  where
    ch a b = (a, ['\\', b])

-- | Escapa um caractere individual usando a tabela de escapes simples ou mantem literal.
oneChar :: Char -> Doc
oneChar c = case lookup c simpleEscapes of
    Just r  -> text r
    Nothing -> char c

--------------------------------------------------------------------------------
-- Ponto de entrada do renderizador (suporte inicial a primitivos)
--------------------------------------------------------------------------------

-- | Converte um valor JSON primitivo para um documento Doc.
renderJValue :: JValue -> Doc
renderJValue (JBool True)  = text "true"
renderJValue (JBool False) = text "false"
renderJValue JNull         = text "null"
renderJValue (JNumber num) = double num
renderJValue (JString str) = string str
renderJValue (JArray _)    = text "[]"
renderJValue (JObject _)   = text "{}"
