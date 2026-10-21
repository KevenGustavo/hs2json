-- | Renderizador JSON simples para String.
module PutJSON
    ( renderJValue
    , putJValue
    ) where

import Data.List (intercalate)
import SimpleJSON (JValue(..))

renderJValue :: JValue -> String
renderJValue (JString s) = show s
renderJValue (JNumber n) = show n
renderJValue (JBool True) = "true"
renderJValue (JBool False) = "false"
renderJValue JNull = "null"

renderJValue (JArray xs) =
    "[" ++ intercalate ", " (map renderJValue xs) ++ "]"

renderJValue (JObject obj) =
    "{" ++ intercalate ", " (map renderPair obj) ++ "}"
    where
        renderPair (k, v) = show k ++ ": " ++ renderJValue v

putJValue :: JValue -> IO ()
putJValue v = putStrLn (renderJValue v)