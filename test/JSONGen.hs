{-# OPTIONS_GHC -Wno-orphans #-}

module JSONGen () where

import Test.QuickCheck
import SimpleJSON (JValue(..))

instance Arbitrary JValue where
    arbitrary = sized genJValue

    shrink (JArray xs) =
        xs ++ [JArray ys | ys <- shrink xs]

    shrink (JObject ps) =
        map snd ps ++ [JObject qs | qs <- shrink ps]

    shrink _ = []

genJValue :: Int -> Gen JValue
genJValue n
    | n <= 0    = scalar
    | otherwise = oneof [scalar, recursive]
    where
        scalar = oneof
            [ JString <$> arbitrary
            , JNumber <$> arbitrary
            , JBool   <$> arbitrary
            , pure JNull
            ]

        smaller = genJValue (n `div` 2)

        field = (,) <$> arbitrary <*> smaller

        recursive = oneof
            [ JObject <$> resize (n `div` 2) (listOf field)
            , JArray  <$> resize (n `div` 2) (listOf smaller)
            ]