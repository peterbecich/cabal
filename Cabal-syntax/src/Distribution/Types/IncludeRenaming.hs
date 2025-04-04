{-# LANGUAGE DeriveDataTypeable #-}
{-# LANGUAGE DeriveGeneric #-}

module Distribution.Types.IncludeRenaming
  ( IncludeRenaming (..)
  , defaultIncludeRenaming
  , isDefaultIncludeRenaming
  ) where

import Distribution.Compat.Prelude
import Prelude ()

import Distribution.Types.ModuleRenaming

import qualified Distribution.Compat.CharParsing as P
import Distribution.Parsec
import Distribution.Pretty
import Text.PrettyPrint (text)
import qualified Text.PrettyPrint as Disp

-- ---------------------------------------------------------------------------
-- Module renaming

-- | A renaming on an include: (provides renaming, requires renaming)
data IncludeRenaming = IncludeRenaming
  { includeProvidesRn :: ModuleRenaming
  , includeRequiresRn :: ModuleRenaming
  }
  deriving (Show, Read, Eq, Ord, Data, Generic)

instance Binary IncludeRenaming
instance Structured IncludeRenaming

instance NFData IncludeRenaming where rnf = genericRnf

-- | The 'defaultIncludeRenaming' applied when you only @build-depends@
-- on a package.
defaultIncludeRenaming :: IncludeRenaming
defaultIncludeRenaming = IncludeRenaming defaultRenaming defaultRenaming

-- | Is an 'IncludeRenaming' the default one?
isDefaultIncludeRenaming :: IncludeRenaming -> Bool
isDefaultIncludeRenaming (IncludeRenaming p r) = isDefaultRenaming p && isDefaultRenaming r

instance Pretty IncludeRenaming where
  pretty (IncludeRenaming prov_rn req_rn) =
    pretty prov_rn
      <+> ( if isDefaultRenaming req_rn
              then Disp.empty
              else text "requires" <+> pretty req_rn
          )

instance Parsec IncludeRenaming where
  parsec = do
    prov_rn <- parsec
    req_rn <- P.option defaultRenaming $ P.try $ do
      P.spaces -- no need to be space
      _ <- P.string "requires"
      P.spaces
      parsec
    -- Requirements don't really care if they're mentioned
    -- or not (since you can't thin a requirement.)  But
    -- we have a little hack in Configure to combine
    -- the provisions and requirements together before passing
    -- them to GHC, and so the most neutral choice for a requirement
    -- is for the "with" field to be False, so we correctly
    -- thin provisions.
    return (IncludeRenaming prov_rn req_rn)
