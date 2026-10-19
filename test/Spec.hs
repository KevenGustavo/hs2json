module Main (main) where

import Control.Monad (unless)
import System.Exit (exitFailure)

import qualified DocProps
import qualified JSONProps
import qualified PrettyProps

-- | Agregador: cada modulo de teste exporta 'runTests :: IO Bool'.
-- Nao precisa mexer aqui ao adicionar propriedades novas (prefixo prop_).
main :: IO ()
main = do
    results <- sequence
        [ JSONProps.runTests
        , DocProps.runTests
        , PrettyProps.runTests
        ]
    let passed = and results
    if passed
        then putStrLn "Passou em todos os testes."
        else putStrLn "Alguns testes falharam."
    unless passed exitFailure
