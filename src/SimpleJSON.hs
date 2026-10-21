-- | Tipo JValue e funcoes de extracao seguras (accessors).
-- Pendente: implementar funcoes getString, getInt, getDouble, getBool, getObject, getArray e isNull.
module SimpleJSON
    ( JValue(..)
    , getString
    , getInt
    , getDouble
    , getBool
    , getObject
    , getArray
    , isNull
    ) where

data JValue = JString String
            | JNumber Double
            | JBool Bool
            | JNull
            | JObject [(String, JValue)]
            | JArray [JValue]
              deriving (Eq, Ord, Show)

getString :: JValue -> Maybe String
getString (JString s) = Just s
getString _           = Nothing

getInt :: JValue -> Maybe Int
getInt (JNumber n) = Just (truncate n)
getInt _           = Nothing

getDouble :: JValue -> Maybe Double
getDouble (JNumber n) = Just n
getDouble _           = Nothing

getBool :: JValue -> Maybe Bool
getBool (JBool b) = Just b
getBool _         = Nothing

getObject :: JValue -> Maybe [(String, JValue)]
getObject = undefined

getArray :: JValue -> Maybe [JValue]
getArray = undefined

isNull :: JValue -> Bool
isNull = undefined
