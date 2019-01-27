{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}

module Client where

import Servant
import Servant.API
import Servant.API.ContentTypes
import Data.Aeson
import Data.Text
import Data.Time.Calendar (Day(), fromGregorian)
import Network.Wai
import Network.Wai.Handler.Warp
import GHC.Generics
import Data.IORef
import Control.Concurrent
import Control.Monad.IO.Class
-- import Control.Concurrent.STM.TVar

type API = "get"  :>                          Get '[JSON,PlainText] String 
      :<|> "post" :> Capture "name" String :> Get '[JSON,PlainText] String

getServer x = liftIO $ readIORef x

postServer ref new = liftIO $ do
  old <- readIORef ref
  writeIORef ref new
  return old

server :: IORef String -> Server API
server var = getServer var :<|> postServer var

app :: IORef String -> Application
app = serve (Proxy :: Proxy API) . server

client :: IORef String -> IO ()
client = run 8000 . app
