-- | Gerador Arbitrary para JValue.
-- Pendente: implementar instancia Arbitrary JValue utilizando sized e resize (n `div` 2) (listOf ...)
-- nos casos recursivos (JObject e JArray) para evitar consumo excessivo de memoria, alem de shrink.
module JSONGen () where

import SimpleJSON ()
