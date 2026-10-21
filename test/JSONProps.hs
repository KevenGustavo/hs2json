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

return []

runTests :: IO Bool
runTests = $quickCheckAll