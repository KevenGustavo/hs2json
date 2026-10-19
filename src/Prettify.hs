-- | Biblioteca de formatacao e combinadores de documentos (tipo abstrato Doc).
-- Pendente: implementar combinadores de construcao (empty, char, text, double, line, (<>), hcat, fsep, (</>), punctuate),
-- operadores de layout (group, softline, fill, nest) e renderizadores (compact, pretty, fits).
module Prettify
    ( Doc(..)
    , empty
    , char
    , text
    , double
    , line
    , (<>)
    , hcat
    , fsep
    , (</>)
    , punctuate
    , group
    , softline
    , compact
    , pretty
    , fill
    , nest
    ) where

import Prelude hiding ((<>))

data Doc = Empty
         | Char Char
         | Text String
         | Line
         | Concat Doc Doc
         | Union Doc Doc
           deriving (Show, Eq)

empty :: Doc
empty = undefined

char :: Char -> Doc
char = undefined

text :: String -> Doc
text = undefined

double :: Double -> Doc
double = undefined

line :: Doc
line = undefined

(<>) :: Doc -> Doc -> Doc
(<>) = undefined

hcat :: [Doc] -> Doc
hcat = undefined

fsep :: [Doc] -> Doc
fsep = undefined

(</>) :: Doc -> Doc -> Doc
(</>) = undefined

punctuate :: Doc -> [Doc] -> [Doc]
punctuate = undefined

group :: Doc -> Doc
group = undefined

softline :: Doc
softline = undefined

compact :: Doc -> String
compact = undefined

pretty :: Int -> Doc -> String
pretty = undefined

fill :: Int -> Doc -> Doc
fill = undefined

nest :: Int -> Doc -> Doc
nest = undefined
