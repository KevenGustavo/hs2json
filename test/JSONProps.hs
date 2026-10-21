{-# LANGUAGE TemplateHaskell #-}

module JSONProps (runTests) where

import Test.QuickCheck
import SimpleJSON
import JSONGen ()

prop_getString :: String -> Bool
prop_getString s =
    getString (JString s) == Just s

prop_getBool :: Bool -> Bool
prop_getBool b =
    getBool (JBool b) == Just b

prop_getDouble :: Double -> Bool
prop_getDouble d =
    getDouble (JNumber d) == Just d

prop_getInt :: Int -> Property
prop_getInt n =
    abs (toInteger n) < 2^(50 :: Int) ==>
    getInt (JNumber (fromIntegral n)) == Just n

prop_getObject :: [(String, JValue)] -> Bool
prop_getObject obj =
    getObject (JObject obj) == Just obj

prop_getArray :: [JValue] -> Bool
prop_getArray xs =
    getArray (JArray xs) == Just xs

prop_isNull :: JValue -> Bool
prop_isNull v =
    isNull v == (v == JNull)

prop_exclusive :: JValue -> Bool
prop_exclusive v =
    length (filter id
        [ isJust' (getString v)
        , isJust' (getDouble v)
        , isJust' (getBool v)
        , isJust' (getObject v)
        , isJust' (getArray v)
        , isNull v
        ]) == 1
    where
        isJust' = maybe False (const True)

prop_wrongAccessor :: String -> Bool
prop_wrongAccessor s =
    getBool (JString s) == Nothing
    && not (isNull (JString s))

return []

runTests :: IO Bool
runTests = $quickCheckAll