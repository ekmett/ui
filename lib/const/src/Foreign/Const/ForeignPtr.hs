{-# language UndecidableSuperClasses #-}
{-# language ScopedTypeVariables #-}
{-# language FlexibleContexts #-}
{-# language TypeApplications #-}
{-# language ConstraintKinds #-}
{-# language TypeFamilies #-}
{-# language Trustworthy #-}
{-# language RankNTypes #-}
module Foreign.Const.ForeignPtr
  ( ConstForeignPtr
  , AForeignPtr

  -- * const foreign pointer operations

  , newConstForeignPtr
  , newConstForeignPtr_
  , castConstForeignPtr
  , plusConstForeignPtr
  , newConstForeignPtrEnv
  , withConstForeignPtr

  -- * const agnostic foreign pointer operations

  , addAForeignPtrFinalizer
  , addAForeignPtrFinalizerEnv
  , finalizeAForeignPtr
  , touchAForeignPtr

  -- * @Foreign.Concurrent@-style finalizers

  , newConstForeignPtrConcurrent
  , addAForeignPtrFinalizerConcurrent
  ) where

import Data.Coerce
import Data.Type.Coercion
import qualified Foreign.Concurrent as Concurrent
import Foreign.Const.Ptr
import Foreign.Const.Unsafe
import Foreign.ForeignPtr
import Foreign.Ptr

newConstForeignPtr :: forall p a. APtr p => FinalizerPtr a -> p a -> IO (ConstForeignPtr a)
newConstForeignPtr = gcoerceWith (unsafePtrCoercion @p @a) $ coerce $ newForeignPtr @a

newConstForeignPtr_ :: forall p a. APtr p => p a -> IO (ConstForeignPtr a)
newConstForeignPtr_ = gcoerceWith (unsafePtrCoercion @p @a) $ coerce $ newForeignPtr_ @a

addAForeignPtrFinalizer :: forall fp a. AForeignPtr fp => FinalizerPtr a -> fp a -> IO ()
addAForeignPtrFinalizer = gcoerceWith (unsafeForeignPtrCoercion @fp @a) $ coerce $ addForeignPtrFinalizer @a

newConstForeignPtrEnv :: forall p env a. APtr p => FinalizerEnvPtr env a -> Ptr env -> p a -> IO (ConstForeignPtr a)
newConstForeignPtrEnv = gcoerceWith (unsafePtrCoercion @p @a) $ coerce $ newForeignPtrEnv @env @a

addAForeignPtrFinalizerEnv :: forall fp env a. AForeignPtr fp => FinalizerEnvPtr env a -> Ptr env -> fp a -> IO ()
addAForeignPtrFinalizerEnv = gcoerceWith (unsafeForeignPtrCoercion @fp @a) $ coerce $ addForeignPtrFinalizerEnv @env @a

withConstForeignPtr :: forall fp a r. AForeignPtr fp => fp a -> (ConstPtr a -> IO r) -> IO r
withConstForeignPtr = gcoerceWith (unsafeForeignPtrCoercion @fp @a) $ coerce $ withForeignPtr @a @r

finalizeAForeignPtr :: forall fp a. AForeignPtr fp => fp a -> IO ()
finalizeAForeignPtr = gcoerceWith (unsafeForeignPtrCoercion @fp @a) $ coerce $ finalizeForeignPtr @a

touchAForeignPtr :: forall fp a. AForeignPtr fp => fp a -> IO ()
touchAForeignPtr = gcoerceWith (unsafeForeignPtrCoercion @fp @a) $ coerce $ touchForeignPtr @a

castConstForeignPtr :: forall fp a b. AForeignPtr fp => fp a -> ConstForeignPtr b
castConstForeignPtr = gcoerceWith (unsafeForeignPtrCoercion @fp @a) $ coerce $ castForeignPtr @a @b

plusConstForeignPtr :: forall fp a b. AForeignPtr fp => fp a -> Int -> ConstForeignPtr b
plusConstForeignPtr = gcoerceWith (unsafeForeignPtrCoercion @fp @a) $ coerce $ plusForeignPtr @a @b

-- | Analogous to Foreign.Concurrent.newForeignPtr
newConstForeignPtrConcurrent :: forall p a. APtr p => p a -> IO () -> IO (ConstForeignPtr a)
newConstForeignPtrConcurrent = gcoerceWith (unsafePtrCoercion @p @a) $ coerce $ Concurrent.newForeignPtr @a

addAForeignPtrFinalizerConcurrent :: forall fp a. AForeignPtr fp => fp a -> IO () -> IO ()
addAForeignPtrFinalizerConcurrent = gcoerceWith (unsafeForeignPtrCoercion @fp @a) $ coerce $ Concurrent.addForeignPtrFinalizer @a
