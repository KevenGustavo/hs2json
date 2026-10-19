-- | Modulo PrettyJSON: renderizador de valores JSON (JValue) para a representacao
-- estruturada de documentos (Doc) da biblioteca Prettify.
-- Trata regras de escape conformes a RFC 8259, suporte a caracteres Unicode
-- com codificacao hexadecimal de 4 digitos e pares substitutos (surrogate pairs),
-- alem de formatacao com quebras de linha flexiveis para arrays e objetos.
module PrettyJSON
    ( renderJValue
    , string
    ) where

import Prelude hiding ((<>))

import Numeric (showHex)
import Data.Char (ord)
import Data.Bits (shiftR, (.&.))

import SimpleJSON (JValue(..))
import Prettify (Doc, (<>), char, double, fsep, hcat, punctuate, text)

--------------------------------------------------------------------------------
-- Funcao principal de renderizacao
--------------------------------------------------------------------------------

-- | Converte qualquer valor 'JValue' em um documento 'Doc' formatavel.
renderJValue :: JValue -> Doc
renderJValue (JBool True)  = text "true"
renderJValue (JBool False) = text "false"
renderJValue JNull         = text "null"
renderJValue (JNumber num) = double num
renderJValue (JString str) = string str
renderJValue (JArray ary)  = series '[' ']' renderJValue ary
renderJValue (JObject obj) = series '{' '}' field obj
  where
    field (name, val) = string name
                     <> text ": "
                     <> renderJValue val

--------------------------------------------------------------------------------
-- Delimitadores e colecoes (Arrays e Objetos)
--------------------------------------------------------------------------------

-- | Envolve um documento entre caracteres delimitadores (ex: aspas, colchetes ou chaves).
enclose :: Char -> Char -> Doc -> Doc
enclose left right x = char left <> x <> char right

-- | Combinador generico para formatacao de colecoes (arrays e objetos).
-- Recebe o caractere de abertura, o de fechamento, uma funcao que sabe renderizar
-- cada item, e a lista de itens. Usa 'punctuate' com virgula e 'fsep' para
-- quebrar linhas suavemente quando a colecao nao couber em uma unica linha.
series :: Char -> Char -> (a -> Doc) -> [a] -> Doc
series open close item = enclose open close
                       . fsep . punctuate (char ',') . map item

--------------------------------------------------------------------------------
-- Renderizacao e escape de Strings (RFC 8259)
--------------------------------------------------------------------------------

-- | Renderiza uma string JSON completa entre aspas duplas, processando
-- individualmente cada caractere para aplicar as regras de escape necessarias.
string :: String -> Doc
string = enclose '"' '"' . hcat . map oneChar

-- | Processa um unico caractere:
-- 1. Se estiver na tabela 'simpleEscapes', emite o escape simples (ex: \n, \t, \").
-- 2. Senao, se for um caractere de controle (< ' ') ou fora do ASCII padrao (> 0xFF), escapa em hexadecimal.
-- 3. Caso contrario, emite o caractere ASCII imprimivel literal.
oneChar :: Char -> Doc
oneChar c = case lookup c simpleEscapes of
    Just r -> text r
    Nothing | mustEscape c -> hexEscape c
            | otherwise    -> char c
  where
    mustEscape ch = ch < ' ' || ch == '\x7f' || ch > '\xff'

-- | Tabela de associacao contendo os escapes mais comuns da especificacao JSON.
simpleEscapes :: [(Char, String)]
simpleEscapes = zipWith ch "\b\n\f\r\t\\\"/" "bnfrt\\\"/"
  where
    ch a b = (a, ['\\', b])

--------------------------------------------------------------------------------
-- Escapes hexadecimais Unicode e Pares Substitutos (Surrogate Pairs)
--------------------------------------------------------------------------------

-- | Codifica um numero em formato hexadecimal com 4 digitos precedido por "\u" (\uXXXX).
-- Utiliza 'showHex' do modulo Numeric e preenche com zeros a esquerda ('0') se necessario.
smallHex :: Int -> Doc
smallHex x = text "\\u"
          <> text (replicate (4 - length h) '0')
          <> text h
  where
    h = showHex x ""

-- | Codificacao de caracteres fora do Basic Multilingual Plane (pontos de codigo > 0xFFFF).
-- O JSON requer que caracteres maiores que 16 bits sejam representados como dois valores
-- UTF-16 de 16 bits (pares substitutos): um surrogate alto (lead) e um baixo (trail).
-- Realizamos a divisao binaria usando 'shiftR' e mascara bit a bit ('.&.') com 0x3ff (10 bits).
astral :: Int -> Doc
astral n = smallHex (a + 0xd800) <> smallHex (b + 0xdc00)
  where
    a = (n `shiftR` 10) .&. 0x3ff  -- 10 bits mais significativos
    b = n .&. 0x3ff                -- 10 bits menos significativos

-- | Converte um caractere para seu valor numerico ('ord') e decide se basta
-- um escape hexadecimal simples de 4 digitos ou se e necessario gerar o par substituto.
hexEscape :: Char -> Doc
hexEscape c
    | d < 0x10000 = smallHex d
    | otherwise   = astral (d - 0x10000)
  where
    d = ord c
