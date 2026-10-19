{-# LANGUAGE TemplateHaskell #-}
-- | Propriedades para renderizacao PrettyJSON e formatadores Prettify.
-- Pendente: implementar propriedades testando escapes de strings, delimitadores de arrays/objetos,
-- e propriedades de consistencia de compact e pretty.
module PrettyProps (runTests) where

import Test.QuickCheck ()
import Test.QuickCheck.All (quickCheckAll)

return []

runTests :: IO Bool
runTests = $quickCheckAll
