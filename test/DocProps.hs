{-# LANGUAGE TemplateHaskell #-}
-- | Gerador e propriedades para o tipo Doc e combinadores do Prettify.
-- Pendente: implementar instancia Arbitrary Doc e propriedades de invariantes de construcao
-- (identidade de empty com (<>), combinacao de hcat, punctuate, etc.).
module DocProps (runTests) where

import Test.QuickCheck ()
import Test.QuickCheck.All (quickCheckAll)

return []

runTests :: IO Bool
runTests = $quickCheckAll
