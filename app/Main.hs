module Main (main) where

import SimpleJSON
import PutJSON (putJValue)

main :: IO ()
main = do
    putStrLn "=== Demonstracao hs2json ==="
    putStrLn "JSON gerado:"

    putJValue (JObject
        [ ("nome", JString "Leonardo")
        , ("idade", JNumber 24)
        , ("estudante", JBool True)
        , ("linguagens", JArray
            [ JString "Haskell"
            , JString "Python"
            , JString "SQL"
            ])
        , ("endereco", JObject
            [ ("cidade", JString "Sao Luis")
            , ("estado", JString "MA")
            ])
        , ("observacao", JString "Aprendendo \"Haskell\"")
        , ("telefone", JNull)
        ])