{-# language PatternSynonyms #-}
{-# language TemplateHaskell #-}
{-# language BlockArguments #-}
{-# language QuasiQuotes #-}
-- |
-- Copyright :  (c) 2019 Edward Kmett
-- License   :  BSD-2-Clause OR Apache-2.0
-- Maintainer:  Edward Kmett <ekmett@gmail.com>
-- Stability :  experimental
-- Portability: non-portable
--
module Graphics.Harfbuzz.Version 
( version
, version_string
, pattern VERSION_MAJOR
, pattern VERSION_MINOR
, pattern VERSION_MICRO
) where

import Control.Monad.IO.Class
import Data.Version
import Foreign.C.String
import Foreign.Marshal.Array
import Foreign.Storable
import qualified Language.C.Inline as C
import qualified Language.C.Inline.Unsafe as U

import Graphics.Harfbuzz.Internal

C.context C.baseCtx
C.include "<hb.h>"

version :: MonadIO m => m Version
version = liftIO $ allocaArray 3 \abc -> do
  [U.block|void {
     unsigned int * abc = $(unsigned int * abc);
     hb_version(abc,abc+1,abc+2);
  }|]
  a <- peek abc
  b <- peek (advancePtr abc 1)
  c <- peek (advancePtr abc 2)
  pure $ makeVersion [fromIntegral a,fromIntegral b,fromIntegral c]

version_string :: MonadIO m => m String
version_string = liftIO do
  [U.exp|const char * { hb_version_string() }|] >>= peekCString
