-- | Renderizador de JValue para Doc baseado na biblioteca Prettify.
-- Pendente: implementar regras de escape (Unicode, ASCII de controle, aspas),
-- formatacao de arrays/objetos com series e renderJValue.
module PrettyJSON
    ( renderJValue
    ) where

import SimpleJSON (JValue)
import Prettify (Doc)

renderJValue :: JValue -> Doc
renderJValue = undefined
