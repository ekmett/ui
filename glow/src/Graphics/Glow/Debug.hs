{-# language PatternSynonyms #-}
module Graphics.Glow.Debug
( installDebugHook
) where

import Control.Monad.IO.Class
import Foreign.C.String
import Foreign.Ptr
import Graphics.GL.Core33
import Graphics.GL.Ext.KHR.Debug
import Graphics.GL.Types
import Text.Printf

-- | This will install a synchronous debugging hook to allow OpenGL to notify us if we're doing anything deprecated, non-portable, undefined, etc. Returns True if successful
installDebugHook :: MonadIO m => m Bool
installDebugHook
  | gl_KHR_debug = do
    cb <- liftIO $ mkGLDEBUGPROC glCallback
    glDebugMessageCallback cb nullPtr
    True <$ glEnable GL_DEBUG_OUTPUT_SYNCHRONOUS
  | otherwise = return False

glCallback :: GLenum -> GLenum -> GLuint -> GLenum -> GLsizei -> Ptr GLchar -> Ptr () -> IO ()
glCallback source t ident severity _ message _ = do
  message' <- peekCString message
  putStrLn $ printf "opengl %s [%s] %s (%s): %s" t' severity' source' (show ident) message'
 where
  source' = case source of
    GL_DEBUG_SOURCE_API -> "API"
    GL_DEBUG_SOURCE_WINDOW_SYSTEM -> "Window System"
    GL_DEBUG_SOURCE_SHADER_COMPILER -> "Shader Compiler"
    GL_DEBUG_SOURCE_THIRD_PARTY -> "Third Party"
    GL_DEBUG_SOURCE_APPLICATION -> "Application"
    GL_DEBUG_SOURCE_OTHER -> "Other"
    _ -> "Unknown"

  t' = case t of
    GL_DEBUG_TYPE_ERROR -> "Error"
    GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR -> "Deprecated Behaviour"
    GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR -> "Undefined Behaviour"
    GL_DEBUG_TYPE_PORTABILITY -> "Portability"
    GL_DEBUG_TYPE_PERFORMANCE -> "Performance"
    GL_DEBUG_TYPE_OTHER -> "Other"
    GL_DEBUG_TYPE_MARKER -> "Marker"
    _ -> "Unknown"

  severity' = case severity of
    GL_DEBUG_SEVERITY_HIGH -> "High"
    GL_DEBUG_SEVERITY_MEDIUM -> "Medium"
    GL_DEBUG_SEVERITY_LOW -> "Low"
    GL_DEBUG_SEVERITY_NOTIFICATION -> "Notification"
    _ -> "Unknown"
