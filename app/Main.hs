-- {-# LANGUAGE DataKinds #-}
-- {-# LANGUAGE FlexibleInstances #-}
-- {-# LANGUAGE OverloadedStrings #-}
-- {-# LANGUAGE ScopedTypeVariables #-}
-- {-# LANGUAGE TypeOperators #-}

module Main where

import Brick
import TUI
import Client
import Control.Concurrent
import Data.IORef
import Control.Monad

main :: IO ()
main = do
  ref  <- newIORef ""
  tid1 <- forkIO . forever $ do
    val <- readIORef ref
    simpleMain $ ui val
  tid2 <- forkIO $ client ref
  threadDelay 300000000
  killThread tid1
  killThread tid2
  
  
