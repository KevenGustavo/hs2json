{-# LANGUAGE TemplateHaskell #-}
-- | Propriedades para SimpleJSON e PutJSON.
-- Pendente: definir propriedades QuickCheck (prop_...) testando extratores (getString, getInt, etc.)
-- e corretude da serializacao de PutJSON.
module JSONProps (runTests) where

import Test.QuickCheck ()
import Test.QuickCheck.All (quickCheckAll)

-- Escreva aqui as propriedades 'prop_...' ANTES do 'return []'.

return []

runTests :: IO Bool
runTests = $quickCheckAll
