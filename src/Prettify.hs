-- | Modulo Prettify: biblioteca de combinadores para formatacao de documentos (pretty printing).
-- Baseada no modelo de álgebra de documentos de Philip Wadler e Real World Haskell.
-- Permite construir arvores de layout flexivel (tipo Doc) e renderiza-las com controle de colunas.
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

-- | Representacao interna de um documento como uma arvore sintatica.
-- Os nos internos combinam documentos (Concat e Union), enquanto as
-- folhas representam o conteudo textual bruto ou comandos de quebra.
data Doc = Empty                -- ^ Documento vazio (elemento neutro da concatenacao).
         | Char Char            -- ^ Caractere literal individual.
         | Text String          -- ^ Sequencia de texto literal.
         | Line                 -- ^ Quebra de linha rigida (hard line break).
         | Concat Doc Doc       -- ^ Concatenacao sequencial de dois documentos.
         | Union Doc Doc        -- ^ Escolha entre duas alternativas de layout (esquerda = achatada, direita = original).
           deriving (Show, Eq)

--------------------------------------------------------------------------------
-- Construtores basicos
--------------------------------------------------------------------------------

-- | Cria um documento vazio.
empty :: Doc
empty = Empty

-- | Envolve um caractere individual em um documento.
char :: Char -> Doc
char = Char

-- | Converte uma string em documento. Strings vazias sao simplificadas
-- para 'Empty', evitando criar nos desnecessarios na arvore.
text :: String -> Doc
text "" = Empty
text s  = Text s

-- | Converte um valor de ponto flutuante em texto formatado.
double :: Double -> Doc
double d = text (show d)

-- | Cria uma quebra de linha rigida, sempre respeitada na saida final.
line :: Doc
line = Line

--------------------------------------------------------------------------------
-- Combinadores de concatenacao e agregacao
--------------------------------------------------------------------------------

-- | Operador de concatenacao de documentos.
-- 'Empty' atua como identidade matematica: x <> empty = x e empty <> y = y.
-- Isso simplifica a arvore em tempo de construcao.
(<>) :: Doc -> Doc -> Doc
Empty <> y     = y
x     <> Empty = x
x     <> y     = x `Concat` y

-- | Auxiliar de reducao para listas de documentos usando foldr com 'empty' como caso base.
fold :: (Doc -> Doc -> Doc) -> [Doc] -> Doc
fold f = foldr f empty

-- | Concatena horizontalmente uma lista de documentos em sequencia direta (analogo ao concat de listas).
hcat :: [Doc] -> Doc
hcat = fold (<>)

-- | Concatena dois documentos inserindo uma quebra de linha suave entre eles.
(</>) :: Doc -> Doc -> Doc
x </> y = x <> softline <> y

-- | Combina uma lista de documentos separando-os por espacos se couberem na linha,
-- ou quebrando em linhas separadas caso estourem a largura.
fsep :: [Doc] -> Doc
fsep = fold (</>)

--------------------------------------------------------------------------------
-- Mecanismo de layout flexivel (Union, softline, flatten)
--------------------------------------------------------------------------------

-- | Uma quebra de linha suave (softline).
-- Se a linha couber na largura da tela, vira um espaco (' ');
-- se ultrapassar o limite, transforma-se em uma quebra de linha real ('Line').
softline :: Doc
softline = group line

-- | Cria uma bifurcacao de layout: guarda a versao em linha unica (achatada por 'flatten')
-- no lado esquerdo da 'Union', e a versao original (com quebras) no lado direito.
-- O renderizador 'pretty' tentara usar o lado esquerdo se ele couber na largura informada.
group :: Doc -> Doc
group x = flatten x `Union` x

-- | Substitui todas as quebras de linha ('Line') por espacos simples ('Char \' \''),
-- unificando linhas consecutivas em uma unica linha corrida.
flatten :: Doc -> Doc
flatten (x `Concat` y) = flatten x `Concat` flatten y
flatten Line           = Char ' '
flatten (x `Union` _)  = flatten x
flatten other          = other

-- | Intercala um documento pontuador (como virgula) entre os elementos de uma lista de documentos.
punctuate :: Doc -> [Doc] -> [Doc]
punctuate _ []     = []
punctuate _ [d]    = [d]
punctuate p (d:ds) = (d <> p) : punctuate p ds

--------------------------------------------------------------------------------
-- Renderizadores
--------------------------------------------------------------------------------

-- | Renderizador compacto: lineariza o documento ignorando alternativas de layout
-- e sem adicionar espacos extras. Ideal para transmissao eficiente em rede.
-- Utiliza uma lista como pilha de processamento iterativo para evitar recursao profunda.
compact :: Doc -> String
compact x = transform [x]
  where
    transform [] = ""
    transform (d:ds) =
        case d of
            Empty        -> transform ds
            Char c       -> c : transform ds
            Text s       -> s ++ transform ds
            Line         -> '\n' : transform ds
            a `Concat` b -> transform (a:b:ds)
            _ `Union` b  -> transform (b:ds)  -- Em modo compacto, escolhe sempre a versao direita direta

-- | Renderizador agradavel (pretty printer): formata o documento respeitando um limite
-- maximo de colunas por linha (width). Decide dinamicamente entre layouts em linha unica ou multi-linha.
pretty :: Int -> Doc -> String
pretty width x = best 0 [x]
  where
    -- 'best col stack': percorre a pilha de documentos mantendo 'col' (coluna atual na linha).
    best col (d:ds) =
        case d of
            Empty        -> best col ds
            Char c       -> c : best (col + 1) ds
            Text s       -> s ++ best (col + length s) ds
            Line         -> '\n' : best 0 ds  -- Apos quebra, reinicia a contagem de colunas para 0
            a `Concat` b -> best col (a:b:ds)
            a `Union` b  -> nicest col (best col (a:ds))
                                       (best col (b:ds))
    best _ _ = ""

    -- 'nicest' escolhe o ramo 'a' (achatado) se ele couber nas colunas restantes; senao escolhe 'b'.
    nicest col a b
        | (width - least) `fits` a = a
        | otherwise                = b
      where
        least = min width col

-- | Determina se uma cadeia de caracteres renderizada cabe em 'w' colunas antes da proxima quebra de linha.
fits :: Int -> String -> Bool
w `fits` _        | w < 0 = False       -- Estourou o limite de largura
_ `fits` ""               = True        -- Terminou a string sem estourar
_ `fits` ('\n':_)         = True        -- Encontrou quebra de linha: a linha atual coube com sucesso
w `fits` (_:cs)           = (w - 1) `fits` cs

--------------------------------------------------------------------------------
-- Exercicios do Capitulo 6: fill e nest
--------------------------------------------------------------------------------

-- | 'fill width doc': adiciona espacos em branco a direita de um documento ate que
-- ele ocupe no minimo 'width' colunas. Se o documento ja for maior ou igual, nao altera nada.
fill :: Int -> Doc -> Doc
fill width d
    | len < width = d <> text (replicate (width - len) ' ')
    | otherwise   = d
  where
    len = docLength d

    -- Calcula o comprimento horizontal ocupado pelo documento
    docLength Empty        = 0
    docLength (Char _)     = 1
    docLength (Text s)     = length s
    docLength Line         = 0
    docLength (Concat a b) = docLength a + docLength b
    docLength (Union a _)  = docLength a

-- | 'nest i doc': adiciona suporte a indentacao. Toda vez que uma quebra de linha ('Line')
-- ocorrer dentro do documento, adiciona 'i' espacos apos a quebra, alinhando o bloco seguinte.
nest :: Int -> Doc -> Doc
nest i d
    | i <= 0    = d
    | otherwise = indent d
  where
    spaces = replicate i ' '
    indent (Concat a b) = Concat (indent a) (indent b)
    indent (Union a b)  = Union (indent a) (indent b)
    indent Line         = Line `Concat` text spaces
    indent other        = other
