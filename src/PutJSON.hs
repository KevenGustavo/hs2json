-- | Renderizador JSON simples para String.
-- Pendente: implementar renderJValue e putJValue para serializacao basica de JValue.
module PutJSON
    ( renderJValue
    , putJValue
    ) where

import SimpleJSON (JValue)

renderJValue :: JValue -> String
renderJValue = undefined

putJValue :: JValue -> IO ()
putJValue = undefined
